#!/bin/sh
# Copyright (c) 2016, 2017 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

for __ in $(find subr -name *.subr); do . "${__}"; done;
ex_setup_args "${@}"; ex_setup_env; ex_setup_checks; ex_setup_subdirs; ex_pkg_state_init;
ex_log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
ex_log_env_vars "build (global)" ${LOG_ENV_VARS};

for BUILD_TARGET_META in invariants ${BUILD_TARGETS_META:-world}; do
	for BUILD_TARGET_LC in $(ex_get_var_unsafe "$(ex_toupper "${BUILD_TARGET_META}")_TARGET"); do
		BUILD_TARGET="$(ex_toupper "${BUILD_TARGET_LC}")";
		BUILD_PACKAGES="$(ex_get_var_unsafe ${BUILD_TARGET}_PACKAGES)";
		if [ "${BUILD_TARGET}" != "INVARIANTS" ]\
		&& [ -n "${BUILD_PACKAGES_RESTART}" ]; then
			BUILD_PACKAGES="$(ex_lfilter "${BUILD_PACKAGES}" "${BUILD_PACKAGES_RESTART}")";
		fi;
		for PKG_NAME in ${BUILD_PACKAGES}; do
			ex_log_msg vnfo "Starting \`${PKG_NAME}' build...";
			ex_pkg_dispatch "${BUILD_TARGET}" "${PKG_NAME}"	\
				"${ARG_RESTART}" "${ARG_RESTART_AT}";
			BUILD_SCRIPT_RC=${?};
			case ${BUILD_SCRIPT_RC} in
			0) ex_log_msg succ "Finished \`${PKG_NAME}' build.";
			   : $((BUILD_NFINI+=1)); continue; ;;
			*) ex_log_msg fail "Build failed in \`${PKG_NAME}', check \`${WORKDIR}/${PKG_NAME}_std{err,out}.log' for details.";
			   : $((BUILD_NFAIL+=1));
			   if [ ${ARG_RELAXED:-0} -eq 1 ]; then
			   BUILD_PKGS_FAILED="${BUILD_PKGS_FAILED:+${BUILD_PKGS_FAILED} }${PKG_NAME}";
				continue;
			   else
				break;
			   fi; ;;
			esac;
		done;
		if [ "${BUILD_SCRIPT_RC:-0}" -ne 0 ]; then
			break;
		fi;
	done;
done;

ex_pkg_state_fini;
ex_log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
ex_log_msg info "Build time: ${BUILD_TIMES_HOURS} hour(s), ${BUILD_TIMES_MINUTES} minute(s), and ${BUILD_TIMES_SECS} second(s).";
if [ ${ARG_RELAXED:-0} -eq 1 ]\
&& [ -n "${BUILD_PKGS_FAILED}" ]; then
	ex_log_msg info "Build script failure(s) in: ${BUILD_PKGS_FAILED}.";
fi;
exit "${BUILD_SCRIPT_RC:-0}"

# vim:filetype=sh
