> N.B. If you're interested in building Midipix using this script, please join the project's
IRC channel #midipix on Freenode and ask for the address of the internal repositories.

> N.B. If in doubt, consult the fault-tolerant & highly optimised 3D laser show-equipped
usage screen w/ ./build.sh -h or a hungry lion might eat you alive.

## Building a midipix distribution
A Midipix distribution consists of the following:
* the native Midipix toolchain, consisting of perk, gcc, its dependencies,
  and binutils,
* musl, a lightweight, fast, simple, and free libc[1] used by Midipix,
* the Midipix runtime components that bridge the gap between the libc and the
  executive subsystems of all Windows NT-derived Windows OS starting with and
  including Windows XP, and
* a steadily increasing number of 3rd party open source packages, as expected in
  any modern POSIX-compliant \*nix environment, including GNU coreutils, shells,
  libraries such as ncurses, libressl, as well as Perl and Python.

Install the build-time dependencies listed below, clone this repository, and run the
following command line within the latter:  

```shell
./build.sh -a nt64 -b release -D minipix,zipdist -P -v
```

### Build-time dependencies
* **Alpine Linux**: binutils bzip2 cmake coreutils curl findutils g++ gawk gcc git grep gzip libc-dev linux-headers lzip make musl-dev net-tools patch perl perl-xml-parser procps sed tar util-linux wget xz zip
* **Debian/-derived Linux**: binutils bzip2 clzip cmake coreutils curl findutils g++ gawk gcc git grep gzip hostname libc6-dev libxml-parser-perl lzma make patch perl procps sed tar util-linux wget xz-utils zip
* **OpenSUSE Linux**: binutils bzip2 cmake coreutils curl findutils gawk gcc gcc-c++ git grep gzip hostname linux-glibc-devel lzip make patch perl perl-XML-Parser procps sed tar util-linux wget xz zip

> N.B. Busybox is not supported.

> N.B. Some packages (*coreutils*, *grep*, and *tar*, among others) override
Alpine's BusyBox utilities of the same name, as the latter are either non-
conformant or defective.

## Non-exhaustive list of build variables
The following variables are primarily defined in ``midipix.env`` and may be overriden
on a per-build basis on the command-line after the last argument, if any, e.g.:

```shell
./build.sh -a nt64 -b release -D minipix,zipdist -P -v PREFIX_ROOT="${HOME}/midipix_tmp"
```

Furthermore, ``${HOME}/midipix_build.vars``, ``${HOME}/.midipix_build.vars``, and/or
``../midipix_build.vars`` are sourced during build initialisation and may contain
additional overrides, particularly ``${DEFAULT_GITROOT_HEAD}``.

| Variable name    | Default value                   | Description                                                                   |
| ---------------- | ------------------------------- | ----------------------------------------------------------------------------- |
| ARCH             | nt64                            | Target 32-bit (nt32) or 64-bit (nt64) architecture                            |
| BUILD            | debug                           | Build w/ debugging (debug) or release compiler flags                          |
| BUILD_DLCACHEDIR | ${PREFIX_ROOT}/dlcache          | Absolute pathname to package downloads cache root directory                   |
| BUILD_WORKDIR    | ${PREFIX}/tmp                   | Absolute pathname to temporary package build root directory                   |
| PREFIX           | ${PREFIX_ROOT}/${ARCH}/${BUILD} | Absolute pathname to architecture- & build type-specific build root directory |
| PREFIX_CROSS     | ${PREFIX}/${DEFAULT_TARGET}     | Absolute pathname to toolchain root directory                                 |
| PREFIX_MINGW32   | ${PREFIX}/x86_64-w64-mingw32    | Absolute pathname to MinGW toolchain root directory                           |
| PREFIX_MINIPIX   | ${PREFIX}/minipix               | Absolute pathname to minipix distribution root directory                      |
| PREFIX_NATIVE    | ${PREFIX}/native                | Absolute pathname to cross-compiled packages root directory                   |
| PREFIX_ROOT      | ${HOME}/midipix                 | Absolute pathname to top-level directory                                      |
| PREFIX_RPM       | ${PREFIX}/rpm                   | Absolute pathname to package RPM archive root directory                       |

## Common tasks
Rebuild set of packages in isolation, along w/ their dependencies, if any, as needed,
or forcibly, respectively:
```shell
./build.sh [ ... ] -r mc,zsh
./build.sh [ ... ] -r \*mc,zsh
./build.sh [ ... ] -r \*\*mc,zsh
```

Rebuild entire build group:
```shell
./build.sh [ ... ] -r ALL native_runtime
```

## References
* ``Sun, 25 Apr 2016 09:04:08 +0000 [1]`` <a href="http://www.musl-libc.org/faq.html" id="r1">musl FAQ</a>  
  
vim:tw=0
