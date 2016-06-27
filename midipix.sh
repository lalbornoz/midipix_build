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
	read _;
	case "${_}" in
		[yY])	break; ;;
		*)	echo "Exiting."; exit 5; ;;
	esac;
	for _link_name in $(find ${MIDIPIX_PATH}/native/lib \
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
	for _fname in	native/bin/ntctty.exe	\
			native/bin/chroot	\
			native/bin/env		\
			native/bin/bash; do
		if [ ! -e ${MIDIPIX_PATH}/${_fname} ]; then
			return 1;
		fi;
	done;
};

prepend_path /bin;
if [ "${1}" = -h ]; then
	echo "usage: $0 [Cygwin pathname to Midipix root]"; exit 0;
elif [ "${1}" = -l ]; then
	TAILF_LOG=1; shift;
fi;
if [ ${#} -eq 0 ]; then
	MIDIPIX_PATH="$(cygpath -am .)" || exit 1;
else
	MIDIPIX_PATH="${1}";
fi;
UNAME_OS="$(uname -o)" || exit 2;
if [ "${MIDIPIX_PATH#*[ 	]*}" != "${MIDIPIX_PATH}" ]; then
	echo "Error: drive_letter/dirname must not contain SP (\` ') or VT (\`\\\t') characters.";
	exit 3;
fi;
if [ ! -d ${MIDIPIX_PATH} ]; then
	echo "Error: Midipix path non-existent or invalid (\`${MIDIPIX_PATH}'.)";
	exit 4;
elif [ -n "${NATIVE_LIB_LINKS:=$(find ${MIDIPIX_PATH}/native/lib -maxdepth 1 -name \*.so -type l -print -quit)}" ]; then
	convert_links_ask || exit 5;
else
	check_prereq_files || exit 6;
	if [ -f ${MIDIPIX_PATH}/native/bin/libpsxscl.log ]; then
		echo Found libpsxscl.log, copying to ${MIDIPIX_PATH}/native/bin/libpsxscl.last.
		cp ${MIDIPIX_PATH}/native/bin/libpsxscl.log	\
			${MIDIPIX_PATH}/native/bin/libpsxscl.last || exit 7;
	fi;
	echo "Absolute Midipix pathname: ${MIDIPIX_PATH}";
	if [ "${UNAME_OS}" = "Msys" ]; then
		export MSYS2_ARG_CONV_EXCL="*";
	fi;
	mintty -h always -s 120,80 -e /bin/sh -c "
		set -o errexit; stty raw -echo;
		cd ${MIDIPIX_PATH};				\
		env PATH=${MIDIPIX_PATH}/native/lib		\
		native/bin/ntctty.exe -e			\
			chroot native				\
			/bin/env PATH=/bin:/lib			\
			bash" &
	sleep 0.25;
	NTCTTY_PID="$(ps -W | awk '$NF ~ /ntctty\.exe$/{print $1}')";
	echo "ntctty PID               : ${NTCTTY_PID}";
	if [ ${TAILF_LOG:-0} -eq 1 ]; then
		tail -f ${MIDIPIX_PATH}/native/bin/libpsxscl.log;
	fi;
fi;
