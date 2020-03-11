#!/bin/sh
# Copyright (c) 2016, 2017, 2018, 2019 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

buildp_ast() {
	local _param="${1}" _pids="" _pids_niter=0 _pkg_name="" RTL_KILL_TREE_PIDS="";
	if [ "${_param}" = "abort" ]; then
		rtl_log_msg failexit "Build aborted.";
	fi;
	if [ -n "${DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME}" ]; then
		rtl_fileop rm "${DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME}";
	fi;
	while [ "${_pids_niter}" -lt 8 ]; do
		_pids="$(rtl_lconcat "${_pids}" "${RTL_KILL_TREE_PIDS}")"; RTL_KILL_TREE_PIDS="";
		if ! rtl_kill_tree "${$}" "TERM"\
		|| [ -z "${RTL_KILL_TREE_PIDS}" ]; then
			break;
		else
			: $((_pids_niter+=1));
		fi;
	done;
	if [ -n "${_pids}" ]; then
		rtl_log_msg vnfo "Killed PIDs $(rtl_uniq ${_pids})";
	fi;
	if [ -n "${EX_PKG_DISPATCH_WAIT}" ]; then
		for _pkg_name in ${EX_PKG_DISPATCH_WAIT}; do
			rtl_state_clear "${BUILD_WORKDIR}" "${_pkg_name}";
		done;
		rtl_log_msg vnfo "Reset package state for: ${EX_PKG_DISPATCH_WAIT}";
	fi;
};

buildp_dispatch_fail_pkg() {
	local _group_name="${1}" _pkg_name="${2}";
	: $((BUILD_NFAIL+=1)); BUILD_PKGS_FAILED="$(rtl_lconcat "${BUILD_PKGS_FAILED}" "${_pkg_name}")";
	if [ "${ARG_RELAXED:-0}" -eq 1 ]; then
		rtl_log_msg fail "$(printf "Build failed in \`%s', check \`%s' for details." "${_pkg_name}" "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log")";
		if [ "${ARG_DUMP_ON_ABORT:-0}" -eq 1 ]; then
			rtl_log_msg vnfo "Logged environment dump for failed package \`${_pkg_name}' to \`${BUILD_WORKDIR}/${_pkg_name}.dump'.";
		fi;
	else	rtl_log_msg fail "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log:";
		cat "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
		if [ -n "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME}" ]; then
			printf "%s" "${_pkg_name}" > "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME}";
		fi;
		rtl_log_msg fail "$(printf "Build failed in \`%s', check \`%s' for details." "${_pkg_name}" "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log")";
		if [ "${ARG_DUMP_ON_ABORT:-0}" -eq 1 ]; then
			rtl_log_msg vnfo "Logged environment dump for failed package \`${_pkg_name}' to \`${BUILD_WORKDIR}/${_pkg_name}.dump'.";
			rtl_log_msg vnfo "Enter an interactive package build shell w/ the command line: ./pkgtool.sh -a ${ARCH} -b ${BUILD} ${_pkg_name} PREFIX=\"${PREFIX}\"";
		fi;
		exit 1;
	fi;
};

buildp_dispatch_group_state() {
	local _msg="${1}" _group_name="${2}";
	case "${_msg}" in
	finish_group)	rtl_log_msg suc2 "Finished \`${_group_name}' build group."; ;;
	start_group)	rtl_log_msg inf2 "Starting \`${_group_name}' build group..."; ;;
	esac;
};

buildp_dispatch_pkg_state() {
	local _msg="${1}" _group_name="${2}" _pkg_name="${3}";
	case "${_msg}" in
	disabled_pkg)	: $((BUILD_NSKIP+=1)); rtl_log_msg vnfo "$(printf "Skipping disabled package \`%s'." "${_pkg_name}")"; ;;
	missing_pkg)	rtl_log_msg failexit "Error: unknown package \`${_pkg_name}'."; ;;
	msg_pkg)	shift 3; rtl_log_msg vucc "$(printf "%s/%s: %s" "${_group_name}" "${_pkg_name}" "${*}")"; ;;
	skipped_pkg)	: $((BUILD_NSKIP+=1)); rtl_log_msg vnfo "$(printf "Skipping finished package \`%s'." "${_pkg_name}")"; ;;
	start_pkg)	rtl_log_msg info "$(printf "[%03d/%03d] Starting \`%s' build..." "${4}" "${5}" "${_pkg_name}")"; ;;
	step_pkg)	rtl_log_msg vucc "$(printf "Finished build step %s of package \`%s'." "${4}" "${_pkg_name}")"; ;;
	finish_pkg)
		: $((BUILD_NFINI+=1));
		if [ "${ARG_VERBOSE:-0}" -ge 2 ]; then
			cat "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
		fi;
		rtl_log_msg succ "$(printf "Finished \`%s' build." "${_pkg_name}")"; ;;
	start_pkg_child)
		if [ "${PKG_NO_LOG_VARS:-0}" -eq 0 ]; then
			rtl_log_env_vars "build" $(set | awk -F= '/^PKG_/{print $1}' | sort);
		fi;
		if [ "${ARG_VERBOSE:-0}" -ge 3 ]; then
			set -o xtrace;
		fi; ;;
	esac;
};

buildp_dispatch() {
	local _msg="${1}"; shift;
	case "${_msg}" in
	disabled_pkg|finish_pkg|missing_pkg|msg_pkg|skipped_pkg|start_pkg|start_pkg_child|step_pkg)
		buildp_dispatch_pkg_state "${_msg}" "${@}"; ;;
	finish_group|start_group)
		buildp_dispatch_group_state "${_msg}" "${@}"; ;;
	*)	if command -v "buildp_dispatch_${_msg}" >/dev/null 2>&1; then
			"buildp_dispatch_${_msg}" "${@}";
		fi; ;;
	esac;
};

build() {
	local	_build_time_hours=0 _build_time_mins=0 _build_time_secs=0 _pkg_name=""		\
		BUILD_DATE_START="" BUILD_NFAIL=0 BUILD_NFINI=0 BUILD_NSKIP=0			\
		BUILD_PKGS_FAILED="" EX_PKG_DISPATCH_UNKNOWN="";
	if ! cd "$(dirname "${0}")"; then
		printf "Error: failed to setup environment.\n"; exit 1;
	elif trap "buildp_ast abort" HUP INT TERM USR1 USR2\
	&&   trap "buildp_ast exit" EXIT\
	&&   . ./subr/build_init.subr && build_init "${@}"; then
		BUILD_DATE_START="$(rtl_date %Y-%m-%d-%H-%M-%S)"; _build_time_secs="$(rtl_date %s)";
		rtl_log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
		rtl_log_env_vars "build (global)" ${DEFAULT_LOG_ENV_VARS};
		if ! ex_pkg_dispatch "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"			\
				buildp_dispatch "${BUILD_GROUPS}" "${BUILD_GROUPS_INHIBIT_DEPS:-0}"	\
				"${ARG_PARALLEL:-1}" "${BUILD_WORKDIR}/build.fifo" "${ARG_RESTART}"	\
				"${ARG_RESTART_AT}" "${ARG_RESTART_RECURSIVE}" "${BUILD_WORKDIR}"; then
			for _pkg_name in ${EX_PKG_DISPATCH_UNKNOWN}; do
				rtl_log_msg fail "Error: package \`${_pkg_name}' unknown.";
			done; exit 1;
		else	: $((_build_time_secs=$(rtl_date %s)-${_build_time_secs}));
			: $((_build_time_hours=${_build_time_secs}/3600));
			: $((_build_time_minutes=(${_build_time_secs}%3600)/60));
			: $((_build_time_secs=(${_build_time_secs}%3600)%60));
			rtl_log_msg info "${BUILD_NFINI:-0} finished, ${BUILD_NSKIP:-0} skipped, and ${BUILD_NFAIL:-0} failed package(s).";
			rtl_log_msg info "Build time: ${_build_time_hours:-0} hour(s), ${_build_time_minutes:-0} minute(s), and ${_build_time_secs:-0} second(s).";
			if [ -n "${BUILD_PKGS_FAILED}" ]; then
				rtl_log_msg failexit "Build script failure(s) in: ${BUILD_PKGS_FAILED}.";
			fi;
		fi;
	fi;
};

set +o errexit -o noglob; build "${@}";

# vim:filetype=sh textwidth=0
