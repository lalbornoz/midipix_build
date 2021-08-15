#!/bin/sh

dmp_lift() {
	local _rlist="${1#\$}" IFS="${2}" _IFS1="${3}";
	eval set -- '${'"${_rlist}"'}'; IFS="${_IFS1}"; eval ${_rlist}='${*}';
};

devbuild_midipix() {
	set -eu

	DEV_PACKAGES="							\
	musl_no_complex_host musl_full_host musl_full 			\
	psxtypes pemagine dalist ldso ntcon ntapi 			\
	psxscl psxscl_strace ntctty ntux ptycon toksvc u16ports 	\
	ntctty_minipix ntux_minipix ptycon_minipix toksvc_minipix";
	dmp_lift \$DEV_PACKAGES " 	" ",";

	mb_project_dir=$(cd "$(dirname $0)" ; pwd)
	cd "$mb_project_dir"

	./build.sh -r "${DEV_PACKAGES}" "${@}";
	./build.sh -D minipix "${@}";
};

devbuild_all() {
	./build.sh -a nt64 -b release -D minipix,rpm,zipdist -F ipv4 -p auto -v &&\
	./build.sh -a nt64 -b debug -D minipix,rpm,zipdist -F ipv4 -p auto -v;
};

case "${1:-}" in
--all)	shift; devbuild_all "${@}"; ;;
*)	devbuild_midipix "${@}"; ;;
esac;

# vim:filetype=sh textwidth=0
