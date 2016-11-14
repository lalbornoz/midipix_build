#!/bin/sh

set -o noglob;
if [ -z "${PATH##/bin:*}"					\
-a   -z "${PATH##*:/bin:*}"					\
-a   -z "${PATH##*:/bin}" ]; then
	export PATH="/bin${PATH:+:${PATH}}";
fi;
while getopts m __; do
case ${__} in
m)	MIDIPIX_DNAME_DIST=minipix; ;;
*)	echo "usage: $0 [-m] [Cygwin pathname to Midipix root]";
	echo "       -m: use Minipix distribution"; exit 0;
esac; done;
if [ -n "${1}" ]; then
	MIDIPIX_PATH=$(cygpath -am "${1}"); cd ${MIDIPIX_PATH} || exit 1;
else
	MIDIPIX_PATH=$(cygpath -am .);
fi;
printf "%-35s: %s\n" "Absolute Midipix pathname" "${MIDIPIX_PATH}";
printf "%-35s: %s\n" "Distribution name" "${MIDIPIX_DNAME_DIST:=native}";
if [ -f libpsxscl.log ]; then
	echo Found libpsxscl.log, copying to libpsxscl.last.
	if ! cp -p -- libpsxscl.log libpsxscl.last; then
		echo "(cp(1) returned ${?}, ignored.)";
	fi;
fi;
if [ "$(uname -o)" = "Msys" ]; then
	export MSYS2_ARG_CONV_EXCL="*";
fi;
mintty -h always -s 120,80 -e /bin/sh -c "
	set -o errexit;
	env PATH=${MIDIPIX_PATH}/${MIDIPIX_DNAME_DIST}/lib		\
	${MIDIPIX_DNAME_DIST}/bin/ntctty.exe -e				\
		${MIDIPIX_DNAME_DIST}/bin/chroot ${MIDIPIX_DNAME_DIST}	\
		/bin/env PATH=/bin:/lib bash" &
sleep ${SLEEP_DELAY:=0.25};
printf "%-35s: %s\n" "ntctty PID" "$(ps -W | awk '$NF ~ /ntctty\.exe$/{print $1}')";

# vim:filetype=sh
