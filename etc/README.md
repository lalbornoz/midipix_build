> N.B. If you're interested in building Midipix using this script, please join
the project's IRC channel #midipix on Freenode and ask for the address of the
internal repositories required in order to build Midipix.

[//]: # "{{{ Table of contents"
# Table of Contents  

1. [What is midipix, and how is it different?](#1-what-is-midipix-and-how-is-it-different)  
2. [Building a midipix distribution](#2-building-a-midipix-distribution)  
	2.1. [Build-time dependencies](#21-build-time-dependencies)  
		2.1.1. [Alpine-specific notate bene](#211-alpine-specific-notate-bene)  
	2.2. [Deployment](#22-deployment)  
	2.3. [System requirements](#23-system-requirements)  
3. [Common tasks](#3-common-tasks)  
	3.1. [Fault-tolerant & highly optimised 3D laser show-equipped usage screen](#31-fault-tolerant--highly-optimised-3d-laser-show-equipped-usage-screen)  
4. [Build variables](#4-build-variables)  
	4.1. [Package variables](#41-package-variables)  
5. [References](#5-references)  

[//]: "}}}"

[//]: # "{{{ 1. What is midipix, and how is it different?"
## 1. What is midipix, and how is it different?

midipix is a development environment that lets you create programs
for Windows using the standard C and POSIX APIs. No compromises made,
no shortcuts taken.  
  
If you are interested in cross-platform programming that reclaims
the notion of write once, compile everywhere; if you believe that the
'standard' in the C Standard Library should not be a null signifier;
and if you like cooking your code without #ifdef hell and low-level
minutiae, then this page is for you.  
  
midipix makes cross-platform programming better, simpler and faster,
specifically by bringing a modern, conforming C Runtime Library to the
Windows platform. While the idea itself is not new, the approach taken
in midipix to code portability is radically different from that found
in other projects.  
  
*(reproduced from [\[3](#r3)])*
  
[Back to top](#table-of-contents)

[//]: "}}}"

[//]: # "{{{ 2. Building a midipix distribution"
## 2. Building a midipix distribution

A Midipix distribution consists of the following:
* the native Midipix toolchain, consisting of perk, gcc, its dependencies,
  and binutils,
* musl, a lightweight, fast, simple, and free libc[\[1](#r1)] used by Midipix,
* the Midipix runtime components that bridge the gap between the libc and the
  executive subsystems of all Windows NT-derived Windows OS starting with and
  including Windows XP, and
* a steadily increasing number of 3rd party open source packages, as expected in
  any modern POSIX-compliant \*nix environment, including GNU coreutils, shells,
  libraries such as ncurses, libressl, as well as Perl and Python.

Install the build-time dependencies listed in section [2.1](#21-build-time-dependencies),
clone this repository, and run the following command line:

```shell
./build.sh -a nt64 -b release -P -v
```

By default, the build will take place within ``${HOME}/midipix/nt64/release``
and package archive files and/or Git repositores will be downloaded into
``${HOME}/midipix/dlcache``. Consult sections [3.1](#31-fault-tolerant--highly-optimised-3d-laser-show-equipped-usage-screen), [4](#4-build-variables), and [4.1](#41-package-variables)
for the list of available build variables and how to override them.  
Parallelisation is enabled by the above command line for both packages that
can be built independently of each other and make(1) child processes via ``-j``,
limited to the amount of logical processors on the build host divided by two
(2).
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.1. Build-time dependencies"
### 2.1. Build-time dependencies

* **Alpine Linux**: binutils bzip2 cmake coreutils curl findutils g++ gawk gcc
		    git grep gzip libc-dev linux-headers lzip make musl-dev
		    net-tools patch perl perl-xml-parser procps sed tar
		    util-linux wget xz zip
* **Debian/-derived Linux**: binutils bzip2 clzip cmake coreutils curl findutils
			     g++ gawk gcc git grep gzip hostname libc6-dev
			     libxml-parser-perl lzma make patch perl procps sed
			     tar util-linux wget xz-utils zip
* **OpenSUSE Linux**: binutils bzip2 cmake coreutils curl findutils gawk gcc
		      gcc-c++ git grep gzip hostname linux-glibc-devel lzip make
		      patch perl perl-XML-Parser procps sed tar util-linux wget
		      xz zip

> N.B. Busybox is not supported.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.1.1. Alpine-specific notate bene"
#### 2.1.1. Alpine-specific notate bene

Some packages (*coreutils*, *grep*, and *tar*, among others) override Alpine's
BusyBox utilities of the same name, as the latter are either non-conformant or
defective.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.2. Deployment"
### 2.2. Deployment

On successful completion of the build, a ZIP archive containing the Midipix
distribution will be created. Extract its contents on the target machine, run
``bash.bat``, and then ``/install.sh`` inside the resulting self-contained
Midipix installation shell window.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.3. System requirements"
### 2.3. System requirements

The following system requirements are assessed on build hosts equipped with the
following hardware at minimum:
* Intel(R) Xeon(R) CPU W3520 @ 2.67GHz (8 cores)
* 7200 RPM SATA 3.1 HDD
* 6 GB RAM

| Target architecture | Build type | Distribution kinds selected | Average build time | Disk space required |
| ------------------- | ---------- | --------------------------- | ------------------ | ------------------- |
| nt64                | debug      | (none)                      | 2 hours            | 57.60 GB            |
| nt64                | release    | (none)                      | 1 hours 45 minutes | 35.16 GB            |

Package archive files and/or Git repositories additionally consume at least
1.70 GB.

*(last update: Wed, 04 Mar 2020 14:07:26 +0000)*
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 3. Common tasks"
## 3. Common tasks

Rebuild set of packages in isolation, along w/ their dependencies, if any, as
needed, or forcibly, respectively:
```shell
./build.sh [ ... ] -r mc,zsh
./build.sh [ ... ] -r \*mc,zsh
./build.sh [ ... ] -r \*\*mc,zsh
```

Restart the ``configure``, ``build``, and ``install`` steps of the ``coreutils``
package.
```shell
./build.sh -r coreutils:configure,build,install
```

Rebuild entire build group:
```shell
./build.sh [ ... ] -r ALL native_runtime
```
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.1. Fault-tolerant & highly optimised 3D laser show-equipped usage screen"
## 3.1. Fault-tolerant & highly optimised 3D laser show-equipped usage screen

```
usage: ./build.sh [-a nt32|nt64] [-b debug|release] [-C dir[,..]] [-D kind[,..]] [-F ipv4|ipv6|offline]
                  [-h] [-p jobs] [-P] [-r [*[*]]ALL|LAST|name[,..][:step,..]] [-R] [-v[v[v[v]]]]
                  [--as-needed] [--debug-minipix] [<group>[ ..]]

        -a nt32|nt64      Selects 32-bit or 64-bit architecture; defaults to nt64.
        -b debug|release  Selects debug or release build; defaults to debug.
        -C dir[,..]       Clean build directory (build,) ${PREFIX} before processing build
                          scripts (prefix,) source directory (src,) and/or destination directory
                          (dest) after successful package builds.
        -D kind[,..]      Produce minimal midipix distribution directory (minipix,) RPM binary
                          packages (rpm,) and/or deployable distribution ZIP archive (zipdist.)
                          zipdist implies minipix.
        -F ipv4|ipv6|offline
                          Force IPv4 (ipv4) or IPv6 (ipv6) when downloading package archives
                          and/or Git repositories or don't download either at all (offline.)
        -h                Show this screen.
        -p jobs           Enables parallelisation at group-level, whenever applicable.
        -P                The maximum count of jobs defaults to the number of logical
                          processors on the host system divided by two (2.)
                          If -R is not specified and at least one (1) package fails to build,
                          all remaining package builds will be forcibly aborted for convenience.
        -r [*[*]]ALL[:step,..]|LAST|name[,..][:step,..]
                          Restart all packages/the specified comma-separated package(s)
                          completely or at optionally specified comma-separated step(s)
                          or restart the last failed package and resume build.
                          Prepend w/ `*' to automatically include dependencies and `**' to
                          forcibly rebuild all dependencies.

                          Currently defined steps are:
                          fetch_wget, fetch_git, fetch_extract,
                          configure_patch_pre, configure_autotools, configure_patch, configure,
                          build,
                          install_subdirs, install_make, install_files, install_libs, install, and install_rpm.
        -R                Ignore build failures, skip printing package logs, and continue
                          building (relaxed mode.)
        -v[v[v[v]]]       Be verbose; -vv: always print package logs; -vvv: set xtrace during package builds; -vvvv: logs fileops.
        --as-needed       Don't build unless the midipix_build repository has received new commits.
        --debug-minipix   Don't strip(1) minipix binaries to facilitate debugging minipix.
        <group>[ ..]      One of: dev_packages, dist, host_deps, host_deps_rpm, host_toolchain,
                          host_tools, minipix, native_packages, native_runtime, native_toolchain,
                          native_tools.
```
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 4. Build variables"
## 4. Build variables

The following variables are primarily defined in ``midipix.env`` and may be
overriden on a per-build basis on the command-line after the last argument,
if any, e.g.:

```shell
./build.sh -a nt64 -b release -D minipix,zipdist -P -v PREFIX_ROOT="${HOME}/midipix_tmp"
```

Furthermore, ``${HOME}/midipix_build.vars``, ``${HOME}/.midipix_build.vars``,
and/or ``../midipix_build.vars`` are sourced during build initialisation and
may contain additional overrides, particularly ``${DEFAULT_GITROOT_HEAD}``.

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
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.1. Package variables"
## 4.1. Package variables

The following variables are package-specific and receive their value from either
top-level defaults defined in ``midipix.env``, build group-specific defaults
from the build group the package pertains to and defined in its corresponding
file beneath ``groups/``, or package-specific overrides defined either in the
latter and/or in its corresponding file beneath ``vars/``. Additionally,
overrides may be specified on a per-build basis on the command-line after the
last argument, with each variable prefixed w/ ``PKG_``, e.g.: ``./build.sh
[ ... ] PKG_ZSH_CC="/bin/false"``.  
  
The minimum set of package variables that must be provided is ``SHA256SUM, URL,
VERSION`` and/or ``URLS_GIT``, respectively.

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
| FORCE_AUTORECONF            | Forcibly run autoreconf -fiv prior to package (GNU autotools or similar) configuration                                                  |
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
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 5. References"
## 5. References

* ``Sun, 25 Apr 2016 09:04:08 +0000 [1]`` <a href="https://www.musl-libc.org/faq.html" id="r1">musl FAQ</a>  
* ``Wed, 04 Mar 2020 12:57:39 +0000 [2]`` <a href="https://midipix.org/" id="r2">midipix</a>  
* ``Wed, 04 Mar 2020 13:36:19 +0000 [3]`` <a href="https://midipix.org/#sec-midipix" id="r3">midipix - what is midipix, and how is it different?</a>  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
  
[modeline]: # ( vim: set ff=dos tw=0: )
