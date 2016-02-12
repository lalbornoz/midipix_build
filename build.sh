#!/bin/sh
#
{
. ./build.subr;
parse_args_into_vars "${0}" build-scripts,build-steps,help,tarball "${@}";
[ -n "${ARG_HELP}" ] && { exec cat build.usage; } || . ./build.vars;
clear_env_with_except HOME PATH SHELL TERM USER;
check_path_vars PREFIX PREFIX_NATIVE WORKDIR;
check_prereqs git make mktemp openssl sed sort tar tr wget;
log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE:=$(date %Y-%m-%d-%H-%M-%S)}.";
log_env_vars ${LOG_ENV_VARS};
(mkdir -p ${PREFIX} ${PREFIX_NATIVE} ${PREFIX_TARGET} ${WORKDIR};
BUILD_NFINI=${BUILD_NSKIP:=${BUILD_NFAIL:=${BUILD_NBUILT:=0}}};
for BUILD_LVL in 0 1 2 3; do
	for BUILD_SCRIPT_FNAME in ${BUILD_LVL}[0-9][0-9].*.build; do
		if [ -n "${ARG_BUILD_SCRIPTS}" ]\
		&& [ "${ARG_BUILD_SCRIPTS}" != "ALL" ]\
		&& ! match_list "${ARG_BUILD_SCRIPTS}"	\
				, "${BUILD_SCRIPT_FNAME}"; then
			log_msg info "Skipped build script \`${BUILD_SCRIPT_FNAME}' (--build-scripts policy.)";
			continue;
		elif [ ! -f ${BUILD_SCRIPT_FNAME} ]; then
			log_msg info "Build script \`${BUILD_SCRIPT_FNAME}' non-existent or not a file.";
			continue;
		else
			unset BUILD_SCRIPT_RC; : $((BUILD_NBUILT+=1));
			if [ "x${ARG_BUILD_SCRIPTS}" != "xALL" ]\
			&& is_build_script_done finish "${BUILD_SCRIPT_FNAME%.build}"; then
				log_msg info "Skipped build script \`${BUILD_SCRIPT_FNAME}' (already built.)";
					: $((BUILD_NSKIP+=1)); BUILD_SCRIPT_RC=0; continue;
			fi;
			log_msg info "Invoking build script${ARG_BUILD_SCRIPTS:+ (forcibly)} \`${BUILD_SCRIPT_FNAME}'${ARG_BUILD_STEPS:+ at build step(s) ${ARG_BUILD_STEPS}}.";
			(set -o errexit -- $(split . ${BUILD_SCRIPT_FNAME%%.build*});	\
			 SCRIPT_FNAME=${BUILD_SCRIPT_FNAME};				\
			 SCRIPT_NAME=${SCRIPT_FNAME%%.build*};				\
			 export CFLAGS="$(eval echo \${CFLAGS_LVL${BUILD_LVL}})";	\
			 export PREFIX_LVL="$(eval echo \${PREFIX_LVL${BUILD_LVL}})";	\
			 _PWD=$(pwd); cd ${WORKDIR};					\
			 for SCRIPT_SOURCE in build.subr ${SCRIPT_NAME}.vars		\
					${BUILD_SCRIPT_FNAME}; do			\
			 	[ -r ${_PWD}/${SCRIPT_SOURCE} ] &&			\
					 . ${_PWD}/${SCRIPT_SOURCE};			\
			 done);
			case ${BUILD_SCRIPT_RC:=${?}} in
			0) log_msg succ "Finished build script \`${BUILD_SCRIPT_FNAME}'.";
				: $((BUILD_NFINI+=1)); continue; ;;
			*) log_msg fail "Build failed in build script \`${BUILD_SCRIPT_FNAME}' (last return code ${BUILD_SCRIPT_RC}.).";
				: $((BUILD_NFAIL+=1)); break; ;;
			esac;
		fi;
	done;
	if [ ${BUILD_SCRIPT_RC:-0} -ne 0 ]; then
		break;
	fi;
done;
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
if [ $(( ${BUILD_NFINI} + ${BUILD_NSKIP} )) -ge 0 ]\
&& [ ${BUILD_NFAIL} -eq 0 ]\
&& [ ${ARG_TARBALL:-0} -eq 1 ]; then
	log_msg info "Building distribution tarball.";
	(cd ${PREFIX};
	DISTRIB_FNAME=midipix.${BUILD_USER}@${BUILD_HNAME}-${BUILD_DATE}.tar.bz2;
	PREFIX_BASENAME=${PREFIX_NATIVE##*/}; WORKDIR_BASENAME=${WORKDIR##*/};
	rm_if_exists -m ${PREFIX_BASENAME}/lib.bak; rm_if_exists ${DISTRIB_FNAME};
	tar -C ${PREFIX_BASENAME}/lib -cpf - . | tar -C ${PREFIX_BASENAME}/lib.bak -xpf -;
	(cd native/lib &&
	 find . -maxdepth 1 -type l				\
	 	-exec sh -c 'dest=$(readlink -- "$0") && rm -- "$0" && ln -- "$dest" "$0"' {} \;);
	 wait;
	 find .	-maxdepth 2 -type d				\
	 	-not -path .					\
	 	-not -path ./${WORKDIR_BASENAME}		\
	 	-not -path ./${WORKDIR_BASENAME}/\*		\
	 	-not -path ./${PREFIX_BASENAME}			\
	 	-not -path ./${PREFIX_BASENAME}/lib.bak		|\
	 tar -T - -cpf - | bzip2 -9c - > ${DISTRIB_FNAME}
	 rm -rf ${PREFIX_BASENAME}/lib;
	 mv ${PREFIX_BASENAME}/lib.bak ${PREFIX_BASENAME}/lib); wait;
fi;
exit ${BUILD_SCRIPT_RC})} 2>&1 | tee build.log;

# vim:filetype=sh
