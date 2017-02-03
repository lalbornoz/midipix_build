#!/bin/sh
# Copyright (c) 2016 Lucía Andrea Illanes Albornoz <lucia@luciaillanes.de>
#

#
#
#
for __ in subr/*.subr; do
	. ./${__};
done;
while [ ${#} -gt 0 ]; do
case ${1} in
-c)	ARG_CLEAN=1; ;;
-C)	ARG_CHECK_UPDATES=1; ;;
-N)	ARG_OFFLINE=1; ;;
-i)	ARG_IGNORE_SHA256SUMS=1; ;;
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
	fi;
	if [ -z "${ARG_RESTART_AT}" ]; then
		ARG_RESTART_AT=ALL;
	fi; shift; ;;
host_toolchain|native_toolchain|runtime|lib_packages|leaf_packages|devroot|world)
	BUILD_TARGETS_META="${BUILD_TARGETS_META:+${BUILD_TARGETS_META} }${1}"; ;;
*=*)	set_var_unsafe "${1%%=*}" "${1#*=}"; ;;
*)	exec cat etc/build.usage; ;;
esac; shift;
done;

#
#
#
if [ -z "${BUILD_CPUS}" ]\
&& [ -e /proc/cpuinfo ]; then
	BUILD_CPUS=$(awk '/^processor/{cpus++} END{print cpus}' /proc/cpuinfo);
fi;
for __ in ${HOME}/midipix_build.vars ../midipix_build.vars ./vars/build.vars; do
	[ -e ${__} ] && . ${__};
done;
for __ in $(export | sed -e 's/^export //' -e 's/=.*$//'); do
	if ! match_list "${CLEAR_ENV_VARS_EXCEPT}" " " "${__}"; then
		unset "${__}";
	fi;
done;

#
#
#
pre_prereqs;
pre_subdirs;
if [ -e ${BUILD_LOG_FNAME} ]; then
	mv -- ${BUILD_LOG_FNAME} ${BUILD_LOG_LAST_FNAME};
fi;
touch ${BUILD_STATUS_IN_PROGRESS_FNAME};
BUILD_DATE_START="$(date %Y-%m-%d-%H-%M-%S)";
BUILD_NFINI=${BUILD_NSKIP:=${BUILD_NFAIL:=${BUILD_NBUILT:=0}}};
BUILD_TIMES_SECS=$(command date +%s);

#
#
#
{(
if [ ${ARG_CHECK_UPDATES:-0} -eq 0 ]; then
	log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
	log_env_vars "build (global)" ${LOG_ENV_VARS};
else
	log_msg info "Version check run started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
fi;
for BUILD_TARGET_LC in $(subst_tgts invariants ${BUILD_TARGETS_META:-world}); do
	BUILD_TARGET=$(echo ${BUILD_TARGET_LC} | tr a-z A-Z);
	for BUILD_PACKAGE_LC in $(get_var_unsafe ${BUILD_TARGET}_PACKAGES); do
		BUILD_PACKAGE=$(echo ${BUILD_PACKAGE_LC} | tr a-z A-Z);

		#
		#
		#
		if [ "${BUILD_TARGET}" != "INVARIANTS" ]\
		&& [ -n "${ARG_RESTART}" ]; then
			if [ "${ARG_RESTART}" != "ALL" ] &&\
			! match_list ${ARG_RESTART} , ${BUILD_PACKAGE_LC}; then
				log_msg vnfo "Skipped \`${BUILD_PACKAGE_LC}' (-r specified.)";
				: $((BUILD_NSKIP+=1)); BUILD_SCRIPT_RC=0; continue;
			fi;
		fi;
		if [ ${ARG_CHECK_UPDATES:-0} -eq 1 ]\
		&& [ "${BUILD_PACKAGE#*.*}" = "${BUILD_PACKAGE}" ]; then
			mode_check_pkg_updates "${BUILD_PACKAGE_LC}"			\
				"$(get_var_unsafe PKG_${BUILD_PACKAGE}_VERSION)"	\
				"$(get_var_unsafe PKG_${BUILD_PACKAGE}_URL)"		\
				"$(get_var_unsafe PKG_${BUILD_PACKAGE}_URL_TYPE)";
			continue;
		fi;
		if [ "${BUILD_TARGET}" != "INVARIANTS" ]\
		&& [ -z "${ARG_RESTART}" ]\
		&& is_build_script_done finish "${BUILD_PACKAGE_LC}"; then
			log_msg vnfo "Skipped \`${BUILD_PACKAGE_LC}' (already built.)";
			: $((BUILD_NSKIP+=1)); BUILD_SCRIPT_RC=0; continue;
		elif [ -n "${ARG_RESTART}" ]; then
			log_msg vnfo "Forcing package \`${BUILD_PACKAGE_LC}'.";
		fi;

		#
		#
		#
		(set -o errexit -o noglob;
		PKG_PREFIX=$(get_vars_unsafe ${BUILD_TARGET}_PREFIX PKG_${BUILD_PACKAGE%%.*}_PREFIX);				
		parse_with_pkg_name ${BUILD_PACKAGE_LC%.*};
		for __ in ${BUILD_STEPS}; do
			case ${__#*:} in
			abstract)
				if test_cmd pkg_${PKG_NAME}_${__%:*}; then
					pkg_${PKG_NAME}_${__%:*}; exit 0;
				fi; ;;
			always)	pkg_${__%:*}; ;;
			main)	if ! is_build_script_done ${__%:*}; then
					if test_cmd pkg_${PKG_NAME}_${__%:*}; then
						pkg_${PKG_NAME}_${__%:*};
					else
						pkg_${__%:*};
					fi;
				fi; ;;
			esac;
		done;
		set_build_script_done finish); BUILD_SCRIPT_RC=${?};
		case ${BUILD_SCRIPT_RC} in
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
post_copy_etc; post_strip; post_tarballs;
: $((BUILD_TIMES_SECS=$(command date +%s)-${BUILD_TIMES_SECS}));
: $((BUILD_TIMES_HOURS=${BUILD_TIMES_SECS}/3600));
: $((BUILD_TIMES_MINUTES=(${BUILD_TIMES_SECS}%3600)/60));
: $((BUILD_TIMES_SECS=(${BUILD_TIMES_SECS}%3600)%60));
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
log_msg info "Build time: ${BUILD_TIMES_HOURS} hour(s), ${BUILD_TIMES_MINUTES} minute(s), and ${BUILD_TIMES_SECS} second(s).";
if [ -f "${BUILD_STATUS_IN_PROGRESS_FNAME}" ]; then
	build_fileop rm ${BUILD_STATUS_IN_PROGRESS_FNAME};
fi;
exit ${BUILD_SCRIPT_RC})} 2>&1 | tee ${BUILD_LOG_FNAME} &

#
#
#
TEE_PID=${!};
trap "rm -f ${BUILD_STATUS_IN_PROGRESS_FNAME};	\
	log_msg fail \"Build aborted.\";	\
	echo kill ${TEE_PID};			\
	kill ${TEE_PID}" HUP INT TERM USR1 USR2;
wait;

# vim:filetype=sh
