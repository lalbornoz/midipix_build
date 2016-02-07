#!/bin/sh

{
unset AR ARFLAGS CC CFLAGS CXX CXXFLAGS LD LDFLAGS;
. ./build.vars; . ./build.subr;
check_path_vars PREFIX PREFIX_NATIVE WORKDIR;
check_prereqs git make openssl sed sort tar tr wget;
set_env_vars "" LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS \
LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION LC_ALL;
log_msg info "Build started by ${BUILD_USER:=${USER}}@${BUILD_HNAME:=$(hostname)} at ${BUILD_DATE:=$(date %Y-%m-%d-%H-%M-%S)}.";
#trap
(set -o errexit; mkdir -p ${PREFIX} ${WORKDIR});
BUILD_NFINI=${BUILD_NSKIP:=${BUILD_NFAIL:=${BUILD_NBUILT:=0}}};
for BUILD_LVL in 0 1 2 3; do
	for BUILD_SCRIPT_FNAME in ${BUILD_LVL}[0-9][0-9].*.build; do
		if [ -n "${DEBUG_SCRIPT}" ]\
		&& [ "x${DEBUG_SCRIPT}" != "x${BUILD_SCRIPT_FNAME}" ]; then
			continue;
		elif [ ! -f ${BUILD_SCRIPT_FNAME} ]; then
			continue;
		else
			unset BUILD_SCRIPT_RC; : $((BUILD_NBUILT+=1));
			log_msg info "Invoking build script \`${BUILD_SCRIPT_FNAME}'";
			(set -o errexit -- $(split . ${BUILD_SCRIPT_FNAME%.build});	\
			 SCRIPT_FNAME=${BUILD_SCRIPT_FNAME}; _pwd=$(pwd);		\
			 export CFLAGS="$(eval echo \${CFLAGS_LVL${BUILD_LVL}})";	\
			 cd ${WORKDIR}; . ${_pwd}/build.subr;				\
			 [ -f ${_pwd}/${SCRIPT_FNAME%.build}.vars ] &&			\
			 	. ${_pwd}/${SCRIPT_FNAME%.build}.vars;			\
			 . ${_pwd}/${BUILD_SCRIPT_FNAME});
			case ${BUILD_SCRIPT_RC:=${?}} in
			0) log_msg succ "Finished build script \`${BUILD_SCRIPT_FNAME}'.";
				: $((BUILD_NFINI+=1)); continue; ;;
			212) log_msg info "Skipped build script \`${BUILD_SCRIPT_FNAME}' (already built.)";
				: $((BUILD_NSKIP+=1)); BUILD_SCRIPT_RC=0; continue; ;;
			*) log_msg fail "Build failed in build script \`${BUILD_SCRIPT_FNAME}' (last return code ${BUILD_SCRIPT_RC}.).";
				: $((BUILD_NFAIL+=1)); break; ;;
			esac;
		fi;
	done;
	if [ ${BUILD_SCRIPT_RC:-0} != 0 ]; then
		break;
	fi;
done;
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${BUILD_NBUILT} build script(s).";
if [ $(( ${BUILD_NFINI} + ${BUILD_NSKIP} )) -ge 0 ]\
&& [ ${BUILD_NFAIL} -eq 0 ]; then
	log_msg info "Building distribution tarball.";
	(cd ${PREFIX};
	DISTRIB_FNAME=midipix.${BUILD_USER}@${BUILD_HNAME}-${BUILD_DATE}.tar.bz2;
	rm_if_exists -m ${PREFIX_NATIVE##*/}/lib.bak; rm_if_exists ${DISTRIB_FNAME};
	tar -C ${PREFIX_NATIVE##*/}/lib -cpf - . |\
	tar -C ${PREFIX_NATIVE##*/}/lib.bak -xpf -;
	(cd native/lib &&
	 find . -maxdepth 1 -type l				\
		-exec sh -c 'dest=$(readlink -- "$0") && rm -- "$0" && ln -- "$dest" "$0"' {} \;);
	wait;
	find .	-maxdepth 2 -type d				\
		-not -path .					\
		-not -path ./${WORKDIR##*/}			\
		-not -path ./${WORKDIR##*/}/\*			\
		-not -path ./${PREFIX_NATIVE##*/}		\
		-not -path ./${PREFIX_NATIVE##*/}/lib.bak	|\
	tar -T - -cpf - | bzip2 -9c - > ${DISTRIB_FNAME}
	rm -rf ${PREFIX_NATIVE##*/}/lib;
	mv ${PREFIX_NATIVE##*/}/lib.bak ${PREFIX_NATIVE##*/}/lib); wait;
fi;
exit ${BUILD_SCRIPT_RC};
} 2>&1 | tee build.log;

# vim:filetype=sh
