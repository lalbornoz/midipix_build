#!/bin/sh -f
# Prepend /bin to ${PATH} if it does not contain it.
if [ -z "${PATH##/bin:*}" -a -z "${PATH##*:/bin:*}" -a -z "${PATH##*:/bin}" ]; then
	export PATH="/bin${PATH:+:${PATH}}";
fi;

#
# Process -h/${#} > 1. Set and cd into ${MIDIPIX_PATH} from either
# ${1} or `native,' prepended w/ ${PWD}.
if [ "x${1}" = "x-h" ]\
|| [ ${#} -gt 1 ]; then
	echo "usage: $0 [-h] [path]";
	echo "path: absolute or relative Cygwin pathname to Midipix root, e.g. minipix or native.";
	exit 0;
fi;
MIDIPIX_PATH="${1:-native}";
if [ "${1#/}" = "${1}" ]; then
	MIDIPIX_PATH="${PWD}/${MIDIPIX_PATH}";
fi;
cd ${MIDIPIX_PATH} || exit 1;

#
# Log variables and backup the last libpsxscl.log to libpsxscl.last.
# Launch chroot(1)ed bash(1) inside ntctty and mintty. Obtain and
# log the PID of the ntctty process for convenience.
printf "%-35s: %s\n" "Absolute Midipix pathname" "${MIDIPIX_PATH}";
if [ -f libpsxscl.log ]; then
	echo Found libpsxscl.log, copying to libpsxscl.last.
	if ! cp -p -- libpsxscl.log libpsxscl.last; then
		echo "(cp(1) returned ${?}, ignored.)";
	fi;
fi;
if [ "$(uname -o)" = "Msys" ]; then
	# MingW workaround (via Elieux.)
	export MSYS2_ARG_CONV_EXCL="*";
fi;
mintty -h always -s 120,80 -e /bin/sh -c "
	set -o errexit;
	env PATH=${MIDIPIX_PATH}/lib		\
	bin/ntctty.exe -e			\
		bin/chroot .			\
		/bin/env PATH=/bin:/lib bash" &
sleep ${SLEEP_DELAY:=0.25};
printf "%-35s: %s\n" "ntctty PID" "$(ps -W | awk '$NF ~ /ntctty\.exe$/{print $1}')";

# vim:filetype=sh
