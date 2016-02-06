#!/bin/sh

{
unset AR ARFLAGS CC CFLAGS CXX CXXFLAGS LD LDFLAGS;
. ./build.vars; . ./build.subr;
check_prereqs git make openssl sed tar tr wget;
log_msg info "Build started by ${USER}@$(hostname).";
#trap
(set -o errexit; mkdir -p ${PREFIX} ${WORKDIR});
BUILD_NFINI=${BUILD_NSKIP:=${BUILD_NFAIL:=${_nbuild:=0}}};
for BUILD_LVL in 0 1 2; do
	for BUILD_SCRIPT_FNAME in ${BUILD_LVL}[0-9][0-9].*.build; do
		if [ -n "${DEBUG_SCRIPT}" ]\
		&& [ "x${DEBUG_SCRIPT}" != "x${BUILD_SCRIPT_FNAME}" ]; then
			continue;
		elif [ ! -f ${BUILD_SCRIPT_FNAME} ]; then
			continue;
		else
			unset BUILD_SCRIPT_RC; : $((_nbuild+=1));
			log_msg info "Invoking build script \`${BUILD_SCRIPT_FNAME}'";
			(set -o errexit -- $(split . ${BUILD_SCRIPT_FNAME%.build});	\
			 SCRIPT_FNAME=${BUILD_SCRIPT_FNAME}; _pwd=$(pwd);		\
			 cd ${WORKDIR}; . ${_pwd}/build.subr;				\
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
log_msg info "${BUILD_NFINI} finished, ${BUILD_NSKIP} skipped, and ${BUILD_NFAIL} failed builds in ${_nbuild} build script(s).";
exit ${BUILD_SCRIPT_RC};
} 2>&1 | tee build.log;

# vim:filetype=sh
