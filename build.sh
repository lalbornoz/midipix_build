#!/bin/sh
# Copyright (c) 2016 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

#
# Clear the environment.
# Source subroutine scripts.
# Source the build variables file and its local overrides, if any.
# Process command line arguments.
for __ in subr/*.subr; do
	. ./${__};
done;
check_cpuinfo;
while [ ${#} -gt 0 ]; do
case ${1} in
-c)	ARG_CLEAN=1; ;;
-C)	ARG_CHECK_UPDATES=1; ;;
-n)	ARG_DRYRUN=1 ARG_VERBOSE=1; ;;
-N)	ARG_OFFLINE=1; ;;
-t*)	ARG_TARBALL=1; [ "${1#-t.}" != "${1}" ] && TARBALL_SUFFIX=${1#-t.}; ;;
-v)	ARG_VERBOSE=1; ;;
-x)	ARG_XTRACE=1; set -o xtrace; ;;
-a)	[ -z "${2}" ] && exec cat etc/build.usage || ARCH=${2}; shift; ;;
-b)	[ -z "${2}" ] && exec cat etc/build.usage || BUILD=${2}; shift; ;;
-r)	if [ -z "${2}" ]; then
		exec cat build.usage;
	elif [ "${2%:*}" = "${2}" ]; then
		ARG_RESTART=${2};
	else
		ARG_RESTART=${2%:*}; ARG_RESTART_AT=${2#*:};
	fi; shift; ;;
host_toolchain|native_toolchain|runtime|lib_packages|leaf_packages|devroot|world)
	BUILD_TARGETS_META="${BUILD_TARGETS_META:+${BUILD_TARGETS_META} }${1}"; ;;
*=*)	set_var_unsafe "${1%%=*}" "${1#*=}"; ;;
*)	exec cat etc/build.usage; ;;
esac; shift;
done;
source_vars; clear_env;
if [ -z "${BUILD_TARGETS_META}" ]; then
	BUILD_TARGETS_META=world;
fi;

#
# Check whether the pathnames in build.vars contain non-empty valid values.
# Check whether all prerequisite command names resolve.
# Check whether all prerequisite pathnames resolve.
# Check whether all prerequisite Perl modules exist.
# Clean ${PREFIX} if requested.
# Create directory hierarchy and usr -> . symlinks.
check_paths; clean_prefix; create_dirs;
init_build_log; init_build_progress_file;
{(init_build_vars;
log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
log_env_vars "build (global)" ${LOG_ENV_VARS};
for BUILD_TARGET_LC in $(subst_tgts ${BUILD_TARGETS_META}); do
	BUILD_TARGET=$(echo ${BUILD_TARGET_LC} | tr a-z A-Z);
	for BUILD_PACKAGE_LC in $(get_var_unsafe ${BUILD_TARGET}_PACKAGES); do
		BUILD_PACKAGE=$(echo ${BUILD_PACKAGE_LC} | tr a-z A-Z);
		if [ -n "${ARG_RESTART}" ]; then
			if ! match_list ${ARG_RESTART} , ${BUILD_PACKAGE_LC}; then
				if [ ${ARG_VERBOSE:-0} -eq 1 ]; then
					log_msg info "Skipped \`${BUILD_PACKAGE_LC}' (-r specified.)";
				fi;
				: $((BUILD_NSKIP+=1)); BUILD_SCRIPT_RC=0; continue;
			fi;
		fi;
		if [ ${ARG_CHECK_UPDATES:-0} -eq 1 ]\
		&& [ "${BUILD_PACKAGE#*.*}" = "${BUILD_PACKAGE}" ]; then
			if [ ${ARG_DRYRUN:-0} -eq 1 ]; then
				echo check_pkg_updates "${BUILD_PACKAGE_LC}"			\
					"$(get_var_unsafe PKG_${BUILD_PACKAGE}_VERSION)"	\
					"$(get_var_unsafe PKG_${BUILD_PACKAGE}_URL)"		\
					"$(get_var_unsafe PKG_${BUILD_PACKAGE}_URL_TYPE)";
			else
				check_pkg_updates "${BUILD_PACKAGE_LC}"			\
					"$(get_var_unsafe PKG_${BUILD_PACKAGE}_VERSION)"	\
					"$(get_var_unsafe PKG_${BUILD_PACKAGE}_URL)"		\
					"$(get_var_unsafe PKG_${BUILD_PACKAGE}_URL_TYPE)";
			fi;
			continue;
		fi;
		if is_build_script_done finish "${BUILD_PACKAGE_LC}"; then
			if [ ${ARG_VERBOSE:-0} -eq 1 ]; then
				log_msg info "Skipped \`${BUILD_PACKAGE_LC}' (already built.)";
			fi;
			: $((BUILD_NSKIP+=1)); BUILD_SCRIPT_RC=0; continue;
		fi;
		if [ -e build/${BUILD_PACKAGE_LC}.build ]; then
			BUILD_SCRIPT_FNAME=build/${BUILD_PACKAGE_LC}.build;
		else
			BUILD_SCRIPT_FNAME=build/pkg.build;
		fi;
		if [ ${ARG_VERBOSE:-0} -eq 1 ]; then
			log_msg info "Invoking build script \`${BUILD_SCRIPT_FNAME}'${ARG_RESTART:+ (forcibly)} for package \`${BUILD_PACKAGE_LC}'.";
		fi;
		(set -o errexit -o noglob;
		 MIDIPIX_BUILD_PWD=$(pwd); PKG_BUILD=${BUILD}; PKG_TARGET=${TARGET};
		 PKG_PREFIX=$(get_vars_unsafe ${BUILD_TARGET}_PREFIX			\
			PKG_${BUILD_PACKAGE%.*}_PREFIX);				
		 cd ${WORKDIR}; source_scripts);
		BUILD_SCRIPT_RC=${?}; case ${BUILD_SCRIPT_RC} in
		0) log_msg succ "Finished \`${BUILD_PACKAGE_LC}' build.";
			: $((BUILD_NFINI+=1)); continue; ;;
		*) log_msg fail "Build failed in \`${BUILD_PACKAGE_LC}' (last return code ${BUILD_SCRIPT_RC}.).";
			: $((BUILD_NFAIL+=1)); break; ;;
		esac;
	done;
	if [ ${BUILD_SCRIPT_RC:-0} -ne 0 ]; then
		break;
	fi;
done;
copy_etc; do_strip; do_tarballs; fini_build_vars;
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
log_msg info "Build time: ${BUILD_TIMES_HOURS} hour(s), ${BUILD_TIMES_MINUTES} minute(s), and ${BUILD_TIMES_SECS} second(s).";
fini_build_progress_file;
exit ${BUILD_SCRIPT_RC})} 2>&1 | tee ${BUILD_LOG_FNAME} &
TEE_PID=${!};
trap "rm -f ${BUILD_STATUS_IN_PROGRESS_FNAME};	\
	log_msg fail \"Build aborted.\";	\
	echo kill ${TEE_PID};			\
	kill ${TEE_PID}" HUP INT TERM USR1 USR2;
wait;

# vim:filetype=sh
