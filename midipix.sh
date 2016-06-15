#!/bin/sh
#

prepend_path() {
	local _pname _pname_prepend="${1}" IFS=":";
	for _pname in ${PATH}; do
		if [ "${_pname}" = "${_pname_prepend}" ]; then
			return;
		fi;
	done; export PATH="${_pname_prepend}${PATH:+:${PATH}}";
};

prepend_path /bin;
if [ "${1}" = -h ]; then
	echo "usage: $0 [drive_letter [dirname]]"; exit 0;
elif [ ${#} -eq 0 ]; then
	PWD_ABSOLUTE="$(cygpath -am .)" || exit 1;
	MIDIPIX_DRIVE="${PWD_ABSOLUTE%:*}";
	MIDIPIX_PNAME="${PWD_ABSOLUTE#${MIDIPIX_DRIVE}:}";
	unset PWD_ABSOLUTE;
else
	MIDIPIX_DRIVE="${1}"; MIDIPIX_PNAME="${2}";
fi;
UNAME_OS="$(uname -o)" || exit 2;
if [ "${MIDIPIX_DRIVE#*[ 	]*}" != "${MIDIPIX_DRIVE}" ]\
|| [ "${MIDIPIX_PNAME#*[ 	]*}" != "${MIDIPIX_PNAME}" ]; then
	echo "Error: drive_letter/dirname must not contain SP (\` ') or VT (\`\\\t') characters.";
	exit 3;
fi;
MIDIPIX_PATH=/${MIDIPIX_DRIVE}${MIDIPIX_PNAME:+/${MIDIPIX_PNAME#/}};
MIDIPIX_PATH=${MIDIPIX_PATH%/};
if [ ! -d /proc/cygdrive${MIDIPIX_PATH} ]; then
	echo "Error: Midipix path non-existent or invalid (\`${MIDIPIX_PATH}'.)";
	exit 4;
else
	if [ -f /proc/cygdrive${MIDIPIX_PATH}/native/bin/libpsxscl.log ]; then
		echo Found libpsxscl.log, copying to /proc/cygdrive${MIDIPIX_PATH}/native/bin/libpsxscl.last.
		cp /proc/cygdrive${MIDIPIX_PATH}/native/bin/libpsxscl.log	\
			/proc/cygdrive${MIDIPIX_PATH}/native/bin/libpsxscl.last || exit 5;
	fi;
	echo "Midipix drive letter.....: ${MIDIPIX_DRIVE}";
	echo "Midipix pathname.........: ${MIDIPIX_PNAME}";
	echo "Absolute Midipix pathname: ${MIDIPIX_PATH}";
	if [ "${UNAME_OS}" = "Msys" ]; then
		export MSYS2_ARG_CONV_EXCL="*";
	fi;
	mintty -h always -e /bin/sh -c "
		set -o errexit; stty raw -echo;
		cd ${MIDIPIX_PATH}/native/bin;
		export PATH=/proc/cygdrive${MIDIPIX_PATH}/native/bin:/proc/cygdrive${MIDIPIX_PATH}/native/lib;
		./ntctty.exe -e chroot //${MIDIPIX_PATH#/}/native /bin/bash";
fi;
