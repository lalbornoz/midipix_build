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

The following variables are package-specific and receive their value from either
top-level defaults defined in ``midipix.env``, build group-specific defaults from
the build group the package pertains to and defined in its corresponding file beneath
``groups/``, or package-specific overrides defined either in the latter and/or in
its corresponding file beneath ``vars/``. Additionally, overrides may be specified
on a per-build basis on the command-line after the last argument, with each variable
prefixed w/ ``PKG_``, e.g.: ``./build.sh [ ... ] PKG_ZSH_CC="/bin/false"``.
The minimum set of package variables that must be provided is ``SHA256SUM, URL, VERSION``
and ``URLS_GIT``, respectively.

| Package variable name       | Description                                                                                                                             |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| AR                          | Command- or pathname of toolchain library archive editor (ar(1))                                                                        |
| BASE_DIR                    | Absolute pathname to package build root directory beneath ${BUILD_WORKDIR}                                                              |
| BUILD_DIR                   | Directory name of package build directory beneath ${PKG_BASE_DIR}                                                                       |
| BUILD_STEPS_DISABLE         | List of build steps to disable during package build                                                                                     |
| BUILD_TYPE                  | Cross-compiled toolchain (cross,) host (host,) or cross-compiled package build type                                                     |
| CC                          | Command- or pathname of toolchain C compiler (cc(1))                                                                                    |
| CFLAGS_BUILD_EXTRA          | Additional C compiler flags during package (make(1)) build                                                                              |
| CFLAGS_CONFIGURE            | C compiler flags during package (autotools or similar) configuration                                                                    |
| CFLAGS_CONFIGURE_EXTRA      | Additional C compiler flags during package (GNU autotools or similar) configuration                                                     |
| CONFIG_CACHE                | List of GNU autotools configuration cache variables                                                                                     |
| CONFIG_CACHE_EXTRA          | Additional list of GNU autotools configuration cache variables                                                                          |
| CONFIG_CACHE_LOCAL          | Additional list of GNU autotools configuration cache variables                                                                          |
| CONFIGURE                   | Command- or pathname to package (GNU autotools or similar) configuration script                                                         |
| CONFIGURE_ARGS              | List of arguments to package (GNU autotools or similar) configuration script                                                            |
| CONFIGURE_ARGS_EXTRA        | Additional list of arguments to package (GNU autotools or similar) configuration script                                                 |
| CXX                         | Command- or pathname of toolchain C++ compiler (c++(1))                                                                                 |
| CXXFLAGS_CONFIGURE          | List of C++ compiler flags during package (autotools or similar) configuration                                                          |
| CXXFLAGS_CONFIGURE_EXTRA    | Additional list of C++ compiler flags during package (autotools or similar) configuration                                               |
| DEPENDS                     | List of package-package dependencies                                                                                                    |
| DESTDIR                     | Directory name of package installation destination directory beneath ${PKG_BASE_DIR}                                                    |
| DISABLED                    | Disable package                                                                                                                         |
| ENV_VARS_EXTRA              | List of double colon-separated environment variable equality sign-separated name-value pairs to set during package build                |
| FNAME                       | Filename of package archive file                                                                                                        |
| GITROOT                     | midipix packages Git URL prefix                                                                                                         |
| INHERIT_FROM                | Inherit variables from named package                                                                                                    |
| INSTALL_FILES               | Whitespace-separated list of files to manually install into the package installation destination directory beneath ${PKG_BASE_DIR}      |
| INSTALL_FILES_DESTDIR       | Whitespace-separated list of files to initialise the package installation destination directory beneath ${PKG_BASE_DIR} with            |
| INSTALL_FILES_DESTDIR_EXTRA | Additional whitespace-separated list of files to initialise the package installation destination directory beneath ${PKG_BASE_DIR} with |
| INSTALL_TARGET              | Name of package build make(1) installation target                                                                                       |
| INSTALL_TARGET_EXTRA        | Additional name of package build make(1) installation target                                                                            |
| IN_TREE                     | Build package in-tree within ${PKG_SUBDIR}                                                                                              |
| LDFLAGS_BUILD_EXTRA         | Additional linker flags during package (make(1)) build                                                                                  |
| LDFLAGS_CONFIGURE           | Linker flags during package (autotools or similar) configuration                                                                        |
| LDFLAGS_CONFIGURE_EXTRA     | Additional linker flags during package (autotools or similar) configuration                                                             |
| LIBTOOL                     | Command- or pathname of libtool                                                                                                         |
| MAKE                        | Command line of make(1)                                                                                                                 |
| MAKEFLAGS_BUILD             | List of make(1) flags during package (make(1)) build                                                                                    |
| MAKEFLAGS_BUILD_EXTRA       | Additional list of make(1) flags during package (make(1)) build                                                                         |
| MAKEFLAGS_INSTALL           | List of make(1) flags during package (make(1)) installation                                                                             |
| MAKEFLAGS_INSTALL_EXTRA     | Additional list of make(1) flags during package (make(1)) installation                                                                  |
| MAKE_INSTALL_VNAME          | Variable name of make(1) installation destination directory variable during package (make(1)) installation                              |
| NO_CLEAN                    | Inhibit cleaning of package build directory beneath ${PKG_BASE_DIR} pre-finish                                                          |
| NO_CLEAN_BASE_DIR           | Inhibit cleaning of package build root directory beneath ${BUILD_WORKDIR}                                                               |
| NO_LOG_VARS                 | Inhibit logging of build & package variables pre-package build                                                                          |
| PATCHES_EXTRA               | Additional list of patches to apply                                                                                                     |
| PKG_CONFIG                  | Command- or pathname of pkg-config(1)                                                                                                   |
| PKG_CONFIG_PATH             | pkg-config(1) search path                                                                                                               |
| PKGLIST_DISABLE             | Inhibit inclusion into ${PREFIX}/pkglist.${PKG_BUILD_TYPE}                                                                              |
| PREFIX                      | Absolute pathname of top-level installation directory and package search path                                                           |
| PYTHON                      | Command- or pathname of Python                                                                                                          |
| RANLIB                      | Command- or pathname of toolchain library archive index generator (ranlib(1))                                                           |
| RPM_DISABLE                 | Inhibit creation of RPM archive                                                                                                         |
| SHA256SUM                   | SHA-256 message digest of package archive                                                                                               |
| SUBDIR                      | Name of extracted archive or git-{clone,pull}(1)'d directory                                                                            |
| TARGET                      | Dash-separated {build,host,target} triplet                                                                                              |
| URL                         | URL to package archive                                                                                                                  |
| URLS_GIT                    | List of package Git URL(s) (*name*=*URL*@*branch*)                                                                                      |
| VERSION                     | Package version                                                                                                                         |

## References
* ``Sun, 25 Apr 2016 09:04:08 +0000 [1]`` <a href="http://www.musl-libc.org/faq.html" id="r1">musl FAQ</a>  
  
vim:tw=0
