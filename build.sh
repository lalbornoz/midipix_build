#!/bin/sh
# Copyright (c) 2016, 2017 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

for __ in $(find subr -name *.subr); do . "${__}"; done;
pre_setup_args "${@}"; pre_setup_env; pre_check; pre_subdirs;
build_files_init; {(
log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
log_env_vars "build (global)" ${LOG_ENV_VARS};
for BUILD_TARGET_LC in $(subst_tgts invariants ${BUILD_TARGETS_META:-world}); do
	BUILD_TARGET="$(toupper "${BUILD_TARGET_LC}")";
	BUILD_PACKAGES="$(get_var_unsafe ${BUILD_TARGET}_PACKAGES)";
	if [ "${BUILD_TARGET}" != "INVARIANTS" ]\
	&& [ -n "${BUILD_PACKAGES_RESTART}" ]; then
		BUILD_PACKAGES="$(lfilter "${BUILD_PACKAGES}" "${BUILD_PACKAGES_RESTART}")";
	fi;
	for PKG_NAME in ${BUILD_PACKAGES}; do
		pkg_setup_dispatch "${BUILD_TARGET}" "${PKG_NAME}" "${ARG_RESTART}" "${ARG_RESTART_AT}";
		case "${BUILD_SCRIPT_RC:=${?}}" in
		0) log_msg succ "Finished \`${PKG_NAME}' build.";
			: $((BUILD_NFINI+=1)); continue; ;;
		*) log_msg fail "Build failed in \`${PKG_NAME}' (last return code ${BUILD_SCRIPT_RC}.).";
			: $((BUILD_NFAIL+=1));
			if [ ${ARG_RELAXED:-0} -eq 1 ]; then
				BUILD_PKGS_FAILED="${BUILD_PKGS_FAILED:+${BUILD_PKGS_FAILED} }${PKG_NAME}";
				continue;
			else
				break;
			fi;
		esac;
	done;
	if [ "${BUILD_SCRIPT_RC:-0}" -ne 0 ]; then
		break;
	fi;
done; build_files_fini;
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
log_msg info "Build time: ${BUILD_TIMES_HOURS} hour(s), ${BUILD_TIMES_MINUTES} minute(s), and ${BUILD_TIMES_SECS} second(s).";
if [ ${ARG_RELAXED:-0} -eq 1 ]\
&& [ -n "${BUILD_PKGS_FAILED}" ]; then
	log_msg info "Build script failure(s) in: ${BUILD_PKGS_FAILED}.";
fi;
exit "${BUILD_SCRIPT_RC:-0}")} 2>&1 | tee "${BUILD_LOG_FNAME}" & TEE_PID="${!}";

trap "rm -f ${BUILD_STATUS_IN_PROGRESS_FNAME};	\
	log_msg fail \"Build aborted.\";	\
	echo kill ${TEE_PID};			\
	kill ${TEE_PID}" HUP INT TERM USR1 USR2; wait;

# vim:filetype=sh
