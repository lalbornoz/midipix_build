#!/bin/sh

set -o errexit -o noglob;
if [ "${1}" = "-m" ]; then
	MIDIPIX_DNAME_DIST=minipix; shift;
fi;
if [ -n "${1}" ]; then
	MIDIPIX_PATH=$(cygpath -am "${1}");
else
	MIDIPIX_PATH=$(cygpath -am .);
fi;
: ${MIDIPIX_DNAME_DIST:=native};
echo "Absolute Midipix pathname: ${MIDIPIX_PATH}";
echo "Distribution name        : ${MIDIPIX_DNAME_DIST}";
printf "%-85s" "Checking if all binaries are present...";
for __ in chroot env ntctty.exe; do
	if [ ! -e ${MIDIPIX_PATH}/${MIDIPIX_DNAME_DIST}/bin/${__} ]; then
		printf "\nerror: missing file ${MIDIPIX_PATH}/${MIDIPIX_DNAME_DIST}/bin/${__}\n";
		exit 2;
	fi;
done;
printf "\033[97m[  \033[92mOK  \033[97m]\033[0m\n";
printf "%-85s" "Checking ${MIDIPIX_PATH}/${MIDIPIX_DNAME_DIST}/lib for symbolic links...";
if [ -n "$(find ${MIDIPIX_DNAME_DIST}/lib					\
		-maxdepth 1 -name \*.so -type l -print -quit)" ]; then
	echo;
	echo "Warning: ${MIDIPIX_PATH}/${MIDIPIX_DNAME_DIST}/lib contains shared objects (library"
	echo "images) that are symbolic links. This is not supported by Midipix at"
	echo "present and commonly occurs if the binary distribution tarball was"
	echo "extracted by an application that does not support symbolic links"
	echo "correctly. This also occurs when a binary distribution was built locally."
	printf "Convert all shared object symbolic links to hard links? (y|N) ";
	read __;
	case "${__}" in
		[yY])	break; ;;
		*)	echo "Exiting."; exit 3; ;;
	esac;
	for LINK_NAME in $(find ${MIDIPIX_PATH}/${MIDIPIX_DNAME_DIST}/lib	\
			-maxdepth 1 -name \*.so -type l); do
		LINK_TARGET="$(readlink -- "${LINK_NAME}")";
		if [ -f "${MIDIPIX_PATH}/native/lib/${LINK_TARGET}" ]; then
			echo rm -f -- "${LINK_NAME}";
			rm -f -- "${LINK_NAME}";
			echo ln -f -- "${LINK_TARGET}" "${LINK_NAME}";
			ln -f -- "${LINK_TARGET}" "${LINK_NAME}";
		fi;
	done;
fi;
printf "\033[97m[  \033[92mOK  \033[97m]\033[0m\n";

# vim:filetype=sh
