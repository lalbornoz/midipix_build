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

convert_links_ask() {
	local _ _link_name _link_target;
	echo "Warning: ${MIDIPIX_PATH}/native/lib contains shared objects (library"
	echo "images) that are symbolic links. This is not supported by Midipix at"
	echo "present and commonly occurs if the binary distribution tarball was"
	echo "extracted by an application that does not support symbolic links"
	echo "correctly. This also occurs when a binary distribution was built locally."
	printf "Convert all shared object symbolic links to hard links? (y|N) ";
	read __;
	case "${__}" in
		[yY])	break; ;;
		*)	echo "Exiting."; exit 6; ;;
	esac;
	for _link_name in $(find ${MIDIPIX_PATH}/native/lib		\
			-maxdepth 1 -name \*.so -type l); do
		_link_target="$(readlink -- "${_link_name}")";
		if [ -f "${MIDIPIX_PATH}/native/lib/${_link_target}" ]; then
			echo rm -f -- "${_link_name}";
			rm -f -- "${_link_name}";
			echo ln -f -- "${_link_target}" "${_link_name}";
			ln -f -- "${_link_target}" "${_link_name}";
		fi;
	done;
};

check_prereq_files() {
	local _fname;
	for _fname in	${MIDIPIX_DNAME_ROOT}/bin/ntctty.exe		\
			${MIDIPIX_DNAME_ROOT}/bin/chroot		\
			${MIDIPIX_DNAME_ROOT}/bin/env			\
			${MIDIPIX_DNAME_ROOT}/bin/bash; do
		if [ ! -e ${MIDIPIX_PATH}/${_fname} ]; then
			return 1;
		fi;
	done;
};

prepend_path /bin;
while [ ${#} -gt 0 ]; do
	if [ "${1}" = -h ]; then
		echo "usage: $0 [-h] [-l] [-m] [Cygwin pathname to Midipix root]";
		echo "       -l: tail(1) -f libpsxscl.log";
		echo "       -m: use Minipix root";
		exit 0;
	elif [ "${1}" = -l ]; then
		ARG_TAILF_LOG=1; shift;
	elif [ "${1}" = -m ]; then
		ARG_MINIPIX=1; shift;
		MIDIPIX_DNAME_ROOT=minipix;
	elif [ "${1#-}" = "${1}" ]; then
		MIDIPIX_PATH="${1}";
	fi;
done;
if [ -z "${MIDIPIX_PATH}" ]; then
	MIDIPIX_PATH="$(cygpath -am .)" || exit 1;
fi;
UNAME_OS="$(uname -o)" || exit 2;
if [ "${MIDIPIX_PATH#*[ 	]*}" != "${MIDIPIX_PATH}" ]; then
	echo "Error: drive_letter/dirname must not contain SP (\` ') or VT (\`\\\t') characters.";
	exit 3;
elif [ ! -d ${MIDIPIX_PATH} ]; then
	echo "Error: Midipix path non-existent or invalid (\`${MIDIPIX_PATH}'.)";
	exit 4;
elif [ -z "${MIDIPIX_DNAME_ROOT}" ]; then
	if [ -e ${MIDIPIX_PATH}/native ]; then
		MIDIPIX_DNAME_ROOT=native;
	elif [ -e ${MIDIPIX_PATH}/minipix ]; then
		MIDIPIX_DNAME_ROOT=minipix;
	else
		echo "Error: neither \`${MIDIPIX_PATH}/native' nor \`${MIDIPIX_PATH}/minipix' exist.";
		exit 5;
	fi;
fi;
if [ \( "${ARG_MINIPIX:-0}" -eq 0 \) -a				\
		\( -n "${NATIVE_LIB_LINKS:=$(find ${MIDIPIX_PATH}/native/lib -maxdepth 1 -name \*.so -type l -print -quit)}" \) ]; then
	convert_links_ask || exit 7;
else
	check_prereq_files || exit 8;
	if [ -f ${MIDIPIX_PATH}/libpsxscl.log ]; then
		echo Found libpsxscl.log, copying to ${MIDIPIX_PATH}/libpsxscl.last.
		cp -p -- ${MIDIPIX_PATH}/libpsxscl.log			\
			${MIDIPIX_PATH}/libpsxscl.last || exit 9;
	fi;
	echo "Absolute Midipix pathname: ${MIDIPIX_PATH}";
	if [ "${UNAME_OS}" = "Msys" ]; then
		export MSYS2_ARG_CONV_EXCL="*";
	fi;
	mintty -h always -s 120,80 -e /bin/sh -c "
		set -o errexit; stty raw -echo;
		cd ${MIDIPIX_PATH};					\
		env PATH=${MIDIPIX_PATH}/${MIDIPIX_DNAME_ROOT}/lib	\
		${MIDIPIX_DNAME_ROOT}/bin/ntctty.exe -e			\
			chroot ${MIDIPIX_DNAME_ROOT}			\
			/bin/env PATH=/bin:/lib				\
			bash" &
	sleep 0.25;
	NTCTTY_PID="$(ps -W | awk '$NF ~ /ntctty\.exe$/{print $1}')";
	echo "ntctty PID               : ${NTCTTY_PID}";
	if [ ${ARG_TAILF_LOG:-0} -eq 1 ]; then
		tail -f ${MIDIPIX_PATH}/${MIDIPIX_DNAME_ROOT}/bin/libpsxscl.log;
	fi;
fi;
