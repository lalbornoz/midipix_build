#!/bin/sh

set -eu

DEV_PACKAGES=\
musl_no_complex_host,musl_full_host,musl_full,\
psxtypes,pemagine,dalist,ldso,ntcon,ntapi,\
psxscl,psxscl_strace,ntctty,ntux,ptycon,u16ports,\
ntctty_minipix,ntux_minipix,ptycon_minipix

mb_project_dir=$(cd "$(dirname $0)" ; pwd)
cd "$mb_project_dir"

./build.sh -r ${DEV_PACKAGES}
./build.sh -D minipix
