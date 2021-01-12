#!/bin/sh

devbuild_midipix() {
	set -eu

	DEV_PACKAGES=\
	musl_no_complex_host,musl_full_host,musl_full,\
	psxtypes,pemagine,dalist,ldso,ntcon,ntapi,\
	psxscl,psxscl_strace,ntctty,ntux,ptycon,toksvc,u16ports,\
	ntctty_minipix,ntux_minipix,ptycon_minipix,toksvc_minipix

	mb_project_dir=$(cd "$(dirname $0)" ; pwd)
	cd "$mb_project_dir"

	./build.sh -r ${DEV_PACKAGES}
	./build.sh -D minipix
};

devbuild_all() {
	./build.sh -a nt64 -b release -D minipix,rpm,zipdist -F ipv4 -p 6 -v && ./build.sh -a nt64 -b debug -D minipix,rpm,zipdist -F ipv4 -p 6 -v;
};

case "${1:-}" in
--all)	devbuild_all; ;;
*)	devbuild_midipix; ;;
esac;

# vim:filetype=sh textwidth=0
