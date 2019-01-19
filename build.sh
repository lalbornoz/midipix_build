#!/bin/sh
# Copyright (c) 2016, 2017 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

buildp_dispatch() {
	local _msg="${1}" _pkg_name="${2}" _tgt_name="${3}"					\
		_build_tgt_meta="" _build_tgt_lc="" _build_tgts_lc=""_pkg_restart="" PKGS_FOUND;
	case "${_msg}" in
	# Top-level
	start_build)	shift; build_args "${@}"; build_init;
			ex_rtl_log_set_vnfo_lvl "${ARG_VERBOSE:-0}";
			ex_rtl_log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
			ex_rtl_log_env_vars "build (global)" ${DEFAULT_LOG_ENV_VARS};
			_build_tgts_lc="${BUILD_TARGETS:-${TARGETS_DEFAULT}}";
			if ! ex_rtl_lmatch "${ARG_DIST}" , rpm; then
				_build_tgts_lc="$(ex_rtl_lfilter_not "${_build_tgts_lc}" "host_tools_rpm")";
			fi;
			PKGS_FOUND="";
			for _build_tgt_lc in ${_build_tgts_lc}; do
				ex_pkg_dispatch "${_build_tgt_lc}"				\
						"${ARG_RESTART}" "${ARG_RESTART_AT}"		\
						buildp_dispatch PKGS_FOUND;
				if [ ${?} -ne 0 ]; then
					break;
				fi;
			done;
			for _pkg_restart in ${ARG_RESTART}; do
				if ! ex_rtl_lmatch "ALL LAST" " " "${_pkg_restart}"		\
				&& ! ex_rtl_lmatch "${PKGS_FOUND}" " " "${_pkg_restart}"; then
					ex_rtl_log_msg failexit "Error: package \`${_pkg_restart}' unknown.";
				fi;
			done;
			if ! ex_pkg_dispatch "invariants" "ALL" "ALL" buildp_dispatch ""; then
				break;
			fi;
			buildp_dispatch finish_build; ;;
	finish_build)	build_fini;
			ex_rtl_log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
			ex_rtl_log_msg info "Build time: ${BUILD_TIMES_HOURS} hour(s), ${BUILD_TIMES_MINUTES} minute(s), and ${BUILD_TIMES_SECS} second(s).";
			if [ -n "${BUILD_PKGS_FAILED}" ]; then
				ex_rtl_log_msg failexit "Build script failure(s) in: ${BUILD_PKGS_FAILED}.";
			fi; ;;

	# Target build
	start_target)	ex_rtl_log_msg inf2 "Starting \`${_tgt_name}' build target..."; ;;
	finish_target)	ex_rtl_log_msg suc2 "Finished \`${_tgt_name}' build target."; ;;

	# Package build
	start_pkg)	ex_rtl_log_msg info "Starting \`${_pkg_name}' build..."; ;;
	finish_pkg)	: $((BUILD_NFINI+=1));
			if [ "${ARG_VERBOSE:-0}" -ge 2 ]; then
				cat "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
			fi;
			ex_rtl_log_msg succ "Finished \`${_pkg_name}' build."; ;;
	fail_pkg)	: $((BUILD_NFAIL+=1));
			BUILD_PKGS_FAILED="${BUILD_PKGS_FAILED:+${BUILD_PKGS_FAILED} }${_pkg_name}";
			if [ "${ARG_RELAXED:-0}" -eq 1 ]; then
				ex_rtl_log_msg fail "Build failed in \`${_pkg_name}', check \`${BUILD_WORKDIR}/${_pkg_name}_stderrout.log' for details.";
			else
				ex_rtl_log_msg fail "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log:";
				cat "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
				if [ -n "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME}" ]; then
					echo "${_pkg_name}" > "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME}";
				fi;
				ex_rtl_log_msg fail "Build failed in \`${_pkg_name}'.";
				if [ "${ARG_PARALLEL:-0}" -eq 1 ]; then
					ex_rtl_log_msg fail "Terminating pending builds...";
					pkill -P "${$}";
				fi;
				exit 1;
			fi; ;;
	disabled_pkg)	ex_rtl_log_msg vnfo "Skipping disabled package \`${_pkg_name}.'"; ;;
	skipped_pkg)	ex_rtl_log_msg vnfo "Skipping finished package \`${_pkg_name}.'"; ;;
	step_pkg)	ex_rtl_log_msg vucc "Finished build step ${4} of package \`${_pkg_name}'."; ;;

	# Child process
	exec_finish)	;;
	exec_missing)	ex_rtl_log_msg failexit "Error: package \`${_pkg_name}' missing in build.vars."; ;;
	exec_start)	if [ "${PKG_NO_LOG_VARS:-0}" -eq 0 ]; then
				ex_rtl_log_env_vars "build"		\
					$(set | awk -F= '/^PKG_/{print $1}' | sort);
			fi;
			if [ "${ARG_VERBOSE:-0}" -ge 3 ]; then
				set -o xtrace;
			fi; ;;
	exec_step)	ex_rtl_log_msg info "Finished build step ${4} of package \`${_pkg_name}'."; ;;
	esac; return 0;
};

for __ in $(find subr -name *.subr); do
	. "${__}"; done; buildp_dispatch start_build "${@}";

# vim:filetype=sh
