#!/bin/sh
# Copyright (c) 2016 Lucio Andrés Illanes Albornoz <l.illanes@gmx.de>
#

#
#
#
for __ in subr/*.subr; do . "${__}"; done;
set -o noglob;
while [ ${#} -gt 0 ]; do
case ${1} in
-c)	ARG_CLEAN=1; ;;
-C)	ARG_CHECK_UPDATES=1; ;;
-N)	ARG_OFFLINE=1; ;;
-i)	ARG_IGNORE_SHA256SUMS=1; ;;
-t*)	ARG_TARBALL=1; [ "${1#-t.}" != "${1}" ] && TARBALL_SUFFIX="${1#-t.}"; ;;
-v)	ARG_VERBOSE=1; ;;
-x)	ARG_XTRACE=1; set -o xtrace; ;;
-a)	[ -z "${2}" ] && exec cat etc/build.usage || ARCH="${2}"; shift; ;;
-b)	[ -z "${2}" ] && exec cat etc/build.usage || BUILD="${2}"; shift; ;;
-r)	if [ -z "${2}" ]; then
		exec cat build.usage;
	elif [ "${2%:*}" = "${2}" ]; then
		ARG_RESTART="${2}";
	else
		ARG_RESTART="${2%:*}"; ARG_RESTART_AT="${2#*:}";
	fi;
	BUILD_PACKAGES_RESTART="$(echo ${ARG_RESTART} | sed "s/,/ /g")";
	shift; ;;
host_toolchain|native_toolchain|runtime|lib_packages|leaf_packages|devroot|world)
	BUILD_TARGETS_META="${BUILD_TARGETS_META:+${BUILD_TARGETS_META} }${1}"; ;;
*=*)	set_var_unsafe "${1%%=*}" "${1#*=}"; ;;
*)	exec cat etc/build.usage; ;;
esac; shift; done;
pre_setup_env; pre_prereqs; pre_subdirs; pre_build_files;

#
#
#
{(
if [ "${ARG_CHECK_UPDATES:-0}" -eq 0 ]; then
	log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
	log_env_vars "build (global)" ${LOG_ENV_VARS};
else
	log_msg info "Version check run started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
fi;
for BUILD_TARGET_LC in $(subst_tgts invariants ${BUILD_TARGETS_META:-world}); do
	BUILD_TARGET="$(echo ${BUILD_TARGET_LC} | tr a-z A-Z)";
	BUILD_PACKAGES="$(get_var_unsafe ${BUILD_TARGET}_PACKAGES)";
	if [ "${BUILD_TARGET}" != "INVARIANTS" ]\
	&& [ -n "${BUILD_PACKAGES_RESTART}" ]; then
		BUILD_PACKAGES="$(lfilter "${BUILD_PACKAGES}" "${BUILD_PACKAGES_RESTART}")";
	fi;
	for PKG_NAME in ${BUILD_PACKAGES}; do
		#
		#
		#
		if [ "${ARG_CHECK_UPDATES:-0}" -eq 1 ]\
		&& [ "${BUILD_PACKAGE#*.*}" = "${BUILD_PACKAGE}" ]; then
			(mode_check_pkg_updates "${PKG_NAME}" "${BUILD_PACKAGE}");
			continue;
		else
			unset BUILD_SCRIPT_RC;
		fi;
		(set -o errexit -o noglob;
		if [ -n "${BUILD_PACKAGES_RESTART}" ]\
		|| ! is_build_script_done "${PKG_NAME}" finish; then
			PKG_BUILD_STEPS="$(get_var_unsafe PKG_$(echo ${PKG_NAME} | tr a-z A-Z)_BUILD_STEPS)";
			set -- ${PKG_BUILD_STEPS:-${BUILD_STEPS}};
			while [ ${#} -gt 0 ]; do
				_pkg_step_cmds=""; _pkg_step_cmd_args="";
				case "${1#*:}" in
				abstract) _pkg_step_cmds="pkg_${PKG_NAME}_${1%:*}";
					  _pkg_step_cmd_args="${ARG_RESTART_AT}"; ;;
				always)	  _pkg_step_cmds="pkg_${1%:*}"; ;;
				main)	if [ -n "${BUILD_PACKAGES_RESTART}" ]; then
						if [ -z "${ARG_RESTART_AT}" ]\
						|| lmatch "${ARG_RESTART_AT}" , "${1%:*}"; then
							_pkg_step_cmds="pkg_${PKG_NAME}_${1%:*} pkg_${1%:*}";
						fi;
					elif ! is_build_script_done ${PKG_NAME} ${1%:*}; then
						_pkg_step_cmds="pkg_${PKG_NAME}_${1%:*} pkg_${1%:*}";
					fi; ;;
				optional)
					if lmatch "${ARG_RESTART_AT}" "," "${1%:*}"; then
						_pkg_step_cmds="pkg_${PKG_NAME}_${1%:*} pkg_${1%:*}";
					fi; ;;
				esac;
				for __ in ${_pkg_step_cmds}; do
					if test_cmd "${__}"; then
						test_cmd "${__}_pre" && "${__}_pre";
						"${__}" ${_pkg_step_cmd_args};
						test_cmd "${__}_post" && "${__}_post";
						set_build_script_done "${PKG_NAME}" "${1%:*}"	\
							${2:+-${2%:*}}; break;
					fi;
				done;
			shift; done;
		fi);
		case "${BUILD_SCRIPT_RC:=${?}}" in
		0) log_msg succ "Finished \`${PKG_NAME}' build.";
			: $((BUILD_NFINI+=1)); continue; ;;
		*) log_msg fail "Build failed in \`${PKG_NAME}' (last return code ${BUILD_SCRIPT_RC}.).";
			: $((BUILD_NFAIL+=1)); break; ;;
		esac;
	done;
	if [ "${BUILD_SCRIPT_RC:-0}" -ne 0 ]; then
		break;
	fi;
done;
if [ "${BUILD_SCRIPT_RC:-0}" -eq 0 ]; then
	post_copy_etc; post_strip; post_tarballs;
fi;
post_build_files;
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
log_msg info "Build time: ${BUILD_TIMES_HOURS} hour(s), ${BUILD_TIMES_MINUTES} minute(s), and ${BUILD_TIMES_SECS} second(s).";
exit "${BUILD_SCRIPT_RC}")} 2>&1 | tee "${BUILD_LOG_FNAME}" & TEE_PID="${!}";
trap "rm -f ${BUILD_STATUS_IN_PROGRESS_FNAME};	\
	log_msg fail \"Build aborted.\";	\
	echo kill ${TEE_PID};			\
	kill ${TEE_PID}" HUP INT TERM USR1 USR2;
wait;

# vim:filetype=sh
