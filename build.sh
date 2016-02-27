#!/bin/sh
# Copyright (c) 2016 Lucio Andrés Illanes Albornoz <l.illanes@gmx.de>
#

. ./build.subr;

while [ ${#} -gt 0 ]; do
case ${1} in
-c)	ARG_CLEAN=1; ;;
-nd)	ARG_NO_DOWNLOAD=1; ;;
-r)	[ -n "${ARG_RESTART_SCRIPT}" ] && exec cat build.usage;
	match_any "${2}" :								\
		&& { ARG_RESTART_SCRIPT="${2%%:*}"; ARG_RESTART_SCRIPT_AT="${2##*:}"; }	\
		|| { ARG_RESTART_SCRIPT="${2}"; ARG_RESTART_SCRIPT_AT=ALL; };
	shift; ;;
-t)	[ ${ARG_TARBALL:-0} -eq 1 ] && exec cat build.usage || ARG_TARBALL=1; ;;
-x)	set -o xtrace; ;;
-X)	set -o xtrace; ARG_DEBUG_TARBALL=1; ;;
*=*)	set_var_unsafe "$(get_prefix_lrg "${1}" =)"					\
			"$(get_postfix "${1}" =)"; ;;
*)	exec cat build.usage; ;;
esac; shift; done;

. ./build.vars;
clear_env_with_except ${CLEAR_ENV_VARS_EXCEPT};
check_path_vars ${CHECK_PATH_VARS}; check_prereqs ${PREREQ_CMDS};
mkdir -p ${PREFIX} ${PREFIX_NATIVE} ${PREFIX_TARGET} ${WORKDIR};
trap clean_build_status HUP INT TERM USR1 USR2;

{(
update_build_status build_start; build_times_init;
log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE_START}.";
log_env_vars ${LOG_ENV_VARS}; [ ${ARG_CLEAN:-0} -eq 1 ] && clean_prefix;
BUILD_NFINI=${BUILD_NSKIP:=${BUILD_NFAIL:=${BUILD_NBUILT:=0}}};
for BUILD_LVL in 0 1 2 3; do
	for BUILD_SCRIPT_FNAME in ${BUILD_LVL}[0-9][0-9].*.build; do
		if [ -n "${ARG_RESTART_SCRIPT}" ]					\
		&& [ "${ARG_RESTART_SCRIPT}" != "ALL" ]					\
		&& ! match_list "${ARG_RESTART_SCRIPT}"					\
				, "${BUILD_SCRIPT_FNAME}"; then
			log_msg info "Skipped build script \`${BUILD_SCRIPT_FNAME}' (--build-scripts policy.)";
			continue;
		elif [ ! -f ${BUILD_SCRIPT_FNAME} ]; then
			log_msg info "Build script \`${BUILD_SCRIPT_FNAME}' non-existent or not a file.";
			continue;
		else
			unset BUILD_SCRIPT_RC; : $((BUILD_NBUILT+=1));
			if [ "${ARG_RESTART_SCRIPT}" != ALL ]\
			&& is_build_script_done finish "${BUILD_SCRIPT_FNAME%.build}"; then
				log_msg info "Skipped build script \`${BUILD_SCRIPT_FNAME}' (already built.)";
					: $((BUILD_NSKIP+=1)); BUILD_SCRIPT_RC=0; continue;
			fi;
			log_msg info "Invoking build script${ARG_RESTART_SCRIPT:+ (forcibly)} \`${BUILD_SCRIPT_FNAME}'${ARG_RESTART_SCRIPT_AT:+ at build step ${ARG_RESTART_SCRIPT_AT}}.";
			(set -o errexit -- $(split . ${BUILD_SCRIPT_FNAME%%.build*});	\
			 SCRIPT_FNAME=${BUILD_SCRIPT_FNAME};				\
			 SCRIPT_NAME=${SCRIPT_FNAME%%.build*};				\
			 export CFLAGS="$(eval echo \${CFLAGS_LVL${BUILD_LVL}})";	\
			 export PREFIX_LVL="$(eval echo \${PREFIX_LVL${BUILD_LVL}})";	\
			 _PWD=$(pwd); cd ${WORKDIR};					\
			 for SCRIPT_SOURCE in build.subr ${SCRIPT_NAME}.vars		\
					${BUILD_SCRIPT_FNAME}; do			\
			 	[ -f ${_PWD}/${SCRIPT_SOURCE} ] &&			\
					 . ${_PWD}/${SCRIPT_SOURCE};			\
			 done);
			case ${BUILD_SCRIPT_RC:=${?}} in
			0) log_msg succ "Finished build script \`${BUILD_SCRIPT_FNAME}'.";
				: $((BUILD_NFINI+=1)); continue; ;;
			*) log_msg fail "Build failed in build script \`${BUILD_SCRIPT_FNAME}' (last return code ${BUILD_SCRIPT_RC}.).";
				if [ ${ARG_DEBUG_TARBALL:-0} -eq 1 ]; then
					log_msg info "-X specified, creating debug tarball.";
					SCRIPT_NAME=${BUILD_SCRIPT_FNAME%%.build};
					SCRIPT_NAME=${SCRIPT_NAME#*.};
					SCRIPT_NAME=$(echo "${SCRIPT_NAME}" | tr a-z A-Z);
					if [ -z ${PKG_SUBDIR=$(get_var_unsafe PKG_${SCRIPT_NAME}_SUBDIR)} ]; then
						PKG_URL=$(get_var_unsafe PKG_${SCRIPT_NAME}_URL);
						PKG_FNAME=${PKG_URL##*/};
					 	PKG_SUBDIR=${PKG_FNAME%%.tar*};
					fi;
					BUILD_DEBUG_TARBALL_FNAME=${PREFIX}/midipix-debug-${BUILD_USER}@${BUILD_HNAME}_$(date %Y-%m-%d-%H-%M-%S).tar.bz2;
					tar -C ${PREFIX} -cpf - build.log $(cd ${PREFIX} && find ${WORKDIR#${PREFIX}/} -mindepth 1 -maxdepth 1 -type d -iname ${PKG_SUBDIR}-*) |\
						bzip2 -c - > ${BUILD_DEBUG_TARBALL_FNAME};
					log_msg info "Please upload ${BUILD_DEBUG_TARBALL_FNAME} and provide an URL to it in <irc://irc.freenode.net/midipix>.";
					exit 1;
				fi;
				: $((BUILD_NFAIL+=1)); break; ;;
			esac;
		fi;
	done;
	if [ ${BUILD_SCRIPT_RC:-0} -ne 0 ]; then
		break;
	fi;
done;
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
build_times_get; log_msg info "Build time: ${BUILD_TIMES_HOURS} hour(s), ${BUILD_TIMES_MINUTES} minute(s), and ${BUILD_TIMES_SECS} second(s).";
update_build_status build_finish tarball_start;
if [ $(( ${BUILD_NFINI} + ${BUILD_NSKIP} )) -ge 0 ]					\
&& [ ${BUILD_NFAIL} -eq 0 ]								\
&& [ ${ARG_TARBALL:-0} -eq 1 ]; then
	log_msg info "Building distribution tarball...";
	(cd ${PREFIX}; PREFIX_BASENAME=${PREFIX_NATIVE##*/};
	rm_if_exists -m ${PREFIX_BASENAME}/lib.bak;
	tar -C ${PREFIX_BASENAME}/lib -cpf - . | tar -C ${PREFIX_BASENAME}/lib.bak -xpf -;
	log_msg info "Backed up ${PREFIX_BASENAME}/lib.";
	(cd native/lib &&
	 find . -maxdepth 1 -type l							\
	 	-exec sh -c 'DEST=$(readlink -- "${0}") &&				\
			rm -f -- "${0}" && ln -- "${DEST}" "${0}"' {} \;); wait;
	 log_msg info "Converted symbolic links in ${PREFIX_BASENAME}/lib to hard links.";
	 tar -cpf - $(find .								\
		-mindepth 1 -maxdepth 1 -type d						\
		$(echo ${TARBALL_EXCLUDE_PATHS} lib | sed 's/\(^\| \)/ -not -path /g'))	|\
	 bzip2 -9c - > ${TARBALL_FNAME_PREFIX}${BUILD_USER}@${BUILD_HNAME}-${BUILD_DATE_START}${TARBALL_FNAME_SUFFIX};
	 rm -rf ${PREFIX_BASENAME}/lib; mv ${PREFIX_BASENAME}/lib.bak ${PREFIX_BASENAME}/lib);
	wait; log_msg info "Finished building distribution tarball.";
	update_build_status tarball_finish;
fi;
update_build_status finish;
exit ${BUILD_SCRIPT_RC})} 2>&1 | tee ${PREFIX}/build.log;

# vim:filetype=sh
