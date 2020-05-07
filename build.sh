#!/bin/sh
# Copyright (c) 2016, 2017, 2018, 2019 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

buildp_ast() {
	trap '' HUP INT TERM USR1 USR2;
	local _param="${1}" _pids="" _pids_niter=0 _pkg_name="" RTL_KILL_TREE_PIDS="";
	if [ "${_param}" = "abort" ]; then
		rtl_log_msg fatalexit "Build aborted.";
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
		rtl_log_msg notice "Killed PID(s): %s" "$(rtl_uniq ${_pids})";
	fi;
	if [ -n "${EX_PKG_DISPATCH_WAIT}" ]; then
		for _pkg_name in ${EX_PKG_DISPATCH_WAIT}; do
			rtl_state_clear "${BUILD_WORKDIR}" "${_pkg_name}";
		done;
		rtl_log_msg notice "Reset package state for: %s" "${EX_PKG_DISPATCH_WAIT}";
	fi;
	if [ -n "${DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME}" ]; then
		rtl_fileop rm "${DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME}";
	fi;
};

buildp_dispatch_fail_pkg() {
	local _group_name="${1}" _pkg_name="${2}";
	: $((BUILD_NFAIL+=1)); BUILD_PKGS_FAILED="$(rtl_lconcat "${BUILD_PKGS_FAILED}" "${_pkg_name}")";
	if [ "${ARG_RELAXED:-0}" -eq 0 ]; then
		rtl_log_msg fatal "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log:";
		cat "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
		if [ -n "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME}" ]; then
			printf "%s" "${_pkg_name}" > "${DEFAULT_BUILD_LAST_FAILED_PKG_FNAME}";
		fi;
		rtl_log_msg fatal "Build failed in \`%s', check \`%s' for details." "${_pkg_name}" "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
	else	rtl_log_msg warning "Build failed in \`%s', check \`%s' for details." "${_pkg_name}" "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
	fi;
	if [ "${ARG_DUMP_ON_ABORT:-0}" -eq 1 ]; then
		rtl_log_msg info "Logged environment dump for failed package \`%s' to \`%s'." "${_pkg_name}" "${BUILD_WORKDIR}/${_pkg_name}.dump";
		rtl_log_msg info "Enter an interactive package build shell w/ the command line: ./pkgtool.sh -a %s -b %s \"%s\" PREFIX=\"%s\""\
				"${ARCH}" "${BUILD_KIND}" "${_pkg_name}" "${PREFIX}";
	fi;
	if [ "${ARG_RELAXED:-0}" -eq 0 ]; then
		exit 1;
	fi;
};

buildp_dispatch_group_state() {
	local _msg="${1}" _group_name="${2}";
	case "${_msg}" in
	finish_group)	rtl_log_msg success_end "Finished \`%s' build group." "${_group_name}"; ;;
	start_group)	rtl_log_msg success "Starting \`%s' build group..." "${_group_name}"; ;;
	esac;
};

buildp_dispatch_pkg_state() {
	local _msg="${1}" _group_name="${2}" _pkg_name="${3}";
	case "${_msg}" in
	disabled_pkg)	: $((BUILD_NSKIP+=1)); rtl_log_msg verbose "Skipping disabled package \`%s'." "${_pkg_name}"; ;;
	missing_pkg)	rtl_log_msg fatalexit "Error: unknown package \`%s'." "${_pkg_name}"; ;;
	msg_pkg)	shift 3; rtl_log_msg verbose "%s/%s: %s" "${_group_name}" "${_pkg_name}" "${*}"; ;;
	skipped_pkg)	: $((BUILD_NSKIP+=1)); rtl_log_msg verbose "Skipping finished package \`%s'." "${_pkg_name}"; ;;
	start_pkg)	rtl_log_msg info "[% 3d%%] [%03d/%03d] Starting \`%s' build..." "$(((100*${4} + ${5}/2)/${5}))" "${4}" "${5}" "${_pkg_name}"; ;;
	step_pkg)	rtl_log_msg verbose "Finished build step %s of package \`%s'." "${4}" "${_pkg_name}"; ;;
	finish_pkg)
		: $((BUILD_NFINI+=1));
		if [ "${ARG_VERBOSE:-0}" -ge 2 ]; then
			cat "${BUILD_WORKDIR}/${_pkg_name}_stderrout.log";
		fi;
		rtl_log_msg info_end "[% 3d%%] [%03d/%03d] Finished \`%s' build." "$(((100*${4} + ${5}/2)/${5}))" "${4}" "${5}" "${_pkg_name}"; ;;
	start_pkg_child)
		if [ "${PKG_NO_LOG_VARS:-0}" -eq 0 ]; then
			rtl_log_env_vars "build" $(rtl_get_vars_fast "^PKG_");
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

buildp_time_init() {
	BUILD_DATE_START="$(rtl_date %Y-%m-%d-%H-%M-%S)";
	_build_time_secs="$(rtl_date %s)";
};

buildp_time_update() {
	: $((_build_time_secs=$(rtl_date %s)-${_build_time_secs}));
	: $((_build_time_hours=${_build_time_secs}/3600));
	: $((_build_time_minutes=(${_build_time_secs}%3600)/60));
	: $((_build_time_secs=(${_build_time_secs}%3600)%60));
};

build() {
	local	_build_time_hours=0 _build_time_mins=0 _build_time_secs=0 _pkg_name="" _rc=0 _status=""			\
		BUILD_DATE_START="" BUILD_GROUPS="" BUILD_GROUPS_INHIBIT_DEPS=0 BUILD_HNAME="" BUILD_IS_PARENT=1	\
		BUILD_NFAIL=0 BUILD_NFINI=0 BUILD_NSKIP=0 BUILD_PKGS_FAILED="" BUILD_TARGET="" BUILD_USER=""		\
		DEFAULT_BUILD_CPUS=1 DEFAULT_BUILD_LAST_FAILED_PKG_FNAME="" DEFAULT_BUILD_LOG_FNAME=""			\
		DEFAULT_BUILD_STEPS="" DEFAULT_BUILD_VARS="" DEFAULT_CLEAR_PREFIX_PATHS="" DEFAULT_GIT_ARGS=""		\
		DEFAULT_GITROOT_HEAD="" DEFAULT_LOG_ENV_VARS=""	DEFAULT_TARGET="" DEFAULT_WGET_ARGS=""			\
		MIDIPIX_BUILD_PWD=""; DEFAULT_BUILD_STATUS_IN_PROGRESS_FNAME="";
	if ! . "${0%/*}/subr/build_init.subr"; then
		_rc=1; printf "Error: failed to source \`${0%/*}/subr/build_init.subr'." >&2;
	elif ! build_init "${@}"; then
		_rc=1; _status="${_status}";
	elif [ -n "${_status}" ]; then
		_rc=0; _status="${_status}";
	else	trap "buildp_ast exit" EXIT; trap "buildp_ast abort" HUP INT TERM USR1 USR2;
		buildp_time_init;
		rtl_log_msg info "Build started by %s@%s at %s." "${BUILD_USER}" "${BUILD_HNAME}" "${BUILD_DATE_START}";
		rtl_log_env_vars "build (global)" ${DEFAULT_LOG_ENV_VARS};
		ex_pkg_dispatch "${DEFAULT_BUILD_STEPS}" "${DEFAULT_BUILD_VARS}"			\
				buildp_dispatch "${BUILD_GROUPS}" "${BUILD_GROUPS_INHIBIT_DEPS}"	\
				"${ARG_PARALLEL}" "${BUILD_WORKDIR}/build.fifo" "${ARG_RESTART}"	\
				"${ARG_RESTART_AT}" "${ARG_RESTART_RECURSIVE}" "${BUILD_WORKDIR}";
		buildp_time_update;
		rtl_log_msg info "%s finished, %s skipped, and %s failed package(s)." "${BUILD_NFINI:-0}" "${BUILD_NSKIP:-0}" "${BUILD_NFAIL:-0}";
		rtl_log_msg info "Build time: %s hour(s), %s minute(s), and %s second(s)." "${_build_time_hours:-0}" "${_build_time_minutes:-0}" "${_build_time_secs:-0}";
		if [ -n "${BUILD_PKGS_FAILED}" ]; then
			_rc=1; _status="Build script failure(s) in: ${BUILD_PKGS_FAILED}.";
		fi;
	fi;
	if [ "${_rc}" -ne 0 ]; then
		rtl_log_msg fatalexit "${_status}";
	elif [ -n "${_status}" ]; then
		rtl_log_msg info "${_status}";
	fi;
};

set +o errexit -o noglob -o nounset; build "${@}";

# vim:filetype=sh textwidth=0
