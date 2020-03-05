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
	3.2. [Adding a package](#32-adding-a-package)  
	3.3. [Addressing build failure](#33-addressing-build-failure)  
	3.4. [Patches and ``vars`` files](#34-patches-and-vars-files)  
4. [Build variables](#4-build-variables)  
	4.1. [Build steps](#41-build-steps)  
	4.2. [Package variables](#42-package-variables)  
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
  
*(reproduced from [\[2](#r2)])*
  
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
``${HOME}/midipix/dlcache``. Consult sections [3.1](#31-fault-tolerant--highly-optimised-3d-laser-show-equipped-usage-screen), [4](#4-build-variables), and [4.1](#42-package-variables)
for the list of available build variables and how to override them.  
Parallelisation is enabled by the above command line for both packages that can
be built independently of each other and ``make(1)`` via ``-j``, limited to the
amount of logical processors on the build host divided by two (2).
  
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
distribution will be created inside ``${PREFIX}`` (see section [4](#4-build-variables).)
Extract its contents on the target machine, run ``bash.bat``, and then
``/install.sh`` inside the resulting self-contained Midipix installation shell
window.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.3. System requirements"
### 2.3. System requirements

The following system requirements are assessed on build hosts equipped with the
following hardware at minimum:
* Intel(R) Xeon(R) CPU W3520 @ 2.67GHz (8 cores)
* 7200 RPM SATA 3.1 HDD
* 6 GB RAM

| Target architecture | Build type | Distribution kinds selected | Average build time | Disk space required | Peak RAM usage |
| ------------------- | ---------- | --------------------------- | ------------------ | ------------------- | -------------- |
| nt64                | debug      | (none)                      | 2 hours            | 57.62 GB            | 3.55 GB        |
| nt64                | release    | (none)                      | 1 hours 45 minutes | 36.51 GB            | 3.21 GB        |

Package archive files and/or Git repositories additionally consume at least
1.82 GB.

*(last update: Thu, 05 Mar 2020 09:25:41 +0000)*
  
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
usage: ./build.sh [-a nt32|nt64]   [-b debug|release]   [-C dir[,..]] [-D kind[,..]]
                  [-F ipv4|ipv6|offline]    [-h]    [-p jobs]   [-P]   [-r ALL|LAST]
                  [-r [*[*[*]]]name[,..][:step,..]] [-R] [-v[v[v[v]]]] [--as-needed]
                  [--debug-minipix] [[*]<group>|<variable name>=<variable override>[ ..]]

        -a nt32|nt64      Selects 32-bit or 64-bit architecture; defaults to nt64.
        -b debug|release  Selects debug or release build; defaults to debug.
        -C dir[,..]       Clean build directory (build,) ${PREFIX} before processing build
                          scripts (prefix,) source directory (src,) and/or destination
                          directory (dest) after successful package builds.
        -D kind[,..]      Produce minimal midipix distribution directory (minipix,) RPM
                          binary packages (rpm,) and/or deployable distribution ZIP
                          archive (zipdist.) zipdist implies minipix.
        -F ipv4|ipv6|offline
                          Force IPv4 (ipv4) or IPv6 (ipv6) when downloading package
                          archives and/or Git repositories or don't download either at all
                          (offline.)
        -h                Show this screen.
        -p jobs           Enables parallelisation at group-level, whenever applicable.
        -P                The maximum count of jobs defaults to the number of logical
                          processors on the host system divided by two (2.)

                          If -R is not specified and at least one (1) package fails to
                          build, all remaining package builds will be forcibly aborted.

        -r ALL|LAST       Restart all packages or the last failed package and resume
                          build, resp.
        -r [*[*[*]]]name[,..][:step,..]
                          Restart the specified comma-separated package(s) completely or
                          at optionally specified comma-separated list of build steps.

                          Prepend w/ `*' to automatically include dependencies, `**' to
                          forcibly rebuild all dependencies, and `***` to forcibly rebuild
                          all packages that depend on the specified package(s).

                          Currently defined build steps are:
                          fetch_wget, fetch_git, fetch_extract, configure_patch_pre,
                          configure_autotools, configure_patch, configure, build,
                          install_subdirs, install_make, install_files, install_libs,
                          install, and install_rpm.

        -R                Ignore build failures, skip printing package logs, and continue
                          building (relaxed mode.)
        -v[v[v[v]]]       Be verbose; -vv: always print package logs; -vvv: set xtrace
                          during package builds; -vvvv: logs fileops.
        --as-needed       Don't build unless the midipix_build repository has received
                          new commits.
        --debug-minipix   Don't strip(1) minipix binaries to facilitate debugging minipix.
        <group>[ ..]      One of: dev_packages, dist, host_deps, host_deps_rpm,
                          host_toolchain, host_tools, minipix, native_packages,
                          native_runtime, native_toolchain, native_tools.

                          Prepend w/ `*' to inhibit group-group dependency expansion.
```
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.2. Adding a package"
## 3.2. Adding a package

Packages are grouped into *build groups* according to sets of common package
variable defaults, such as ``${PKG_CFLAGS_CONFIGURE}, ${PKG_LDFLAGS_CONFIGURE}``
and ``${PKG_CONFIGURE_ARGS}``, and semantic associativity, such as the ``native_runtime``
build group comprising the Midipix runtime components. Packages may belong to
more than one build group such as when subsumed by a shorthand build group e.g.
the ``dev_packages`` build group, as long as the default set of build groups or
as overriden on the command line does not entail group membership conflicts.  
  
Build groups files beneath ``groups/`` named ``[0-9][0-9][0-9].<group name>.group``
contain package variable defaults, the alphabetically sorted list of contained
packages in ``<upper case group name>_PACKAGES``, and their package variables
sorted alphabetically with the exception of ``${PKG_DEPENDS}`` (if present,)
``${PKG_SHA256SUM}``, ``${PKG_URL}``, and ``${PKG_VERSION}``, and/or ``${PKG_URLS_GIT}``,
which are specified in this order.  
  
Pick a build group according to the criteria mentioned, add the package to the
build group's list of contained packages in its corresponding file, and add the
set of package variables required (see above and section [4.2](#42-package-variables).)  
Consult section [3.4](#34-patches-and-vars-files) if the package to be added
requires patches or additional code amending or replacing package build steps
or the entire package build. Consult section [4.1](#41-build-steps) for a list
of package build steps and how they are overriden.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.3. Addressing build failure"
## 3.3. Addressing build failure


  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.4. Patches and ``vars`` files"
## 3.4. Patches and ``vars`` files

Package patches are applied prior and/or subsequent to (GNU autotools or simular) package
configuration during the ``configure_patch_pre`` and/or ``configure_patch`` build steps,
respectively (see section [4.1](#41-build-steps).) Patch files are searched for beneath
``patches/`` with the following globs and in-order:
* ``${PKG_NAME}-${PKG_VERSION}_pre.local.patch``
  or ``${PKG_NAME}_pre.local.patch`` (for packages lacking ``${PKG_VERSION}``)
* ``${PKG_NAME}-${PKG_VERSION}_pre.local@${BUILD_HNAME}.patch``
  or ``${PKG_NAME}_pre.local@${BUILD_HNAME}.patch`` (for packages lacking ``${PKG_VERSION}``)
* ``${PKG_NAME}/*.patch``
* ``${PKG_NAME}-${PKG_VERSION}.local.patch``
  or ``${PKG_NAME}.local.patch`` (for packages lacking ``${PKG_VERSION}``)
* ``${PKG_NAME}-${PKG_VERSION}.local@${BUILD_HNAME}.patch``
  or ``${PKG_NAME}.local@${BUILD_HNAME}.patch`` (for packages lacking ``${PKG_VERSION}``)
* ``${PKG_PATCHES_EXTRA}`` (if set)
  
If the default set of package build steps does not suffice, such as if additional commands
must be executed after package configuration or prior to building, or if an entire or all
build step must be replaced, overrides may be specified in the form of functions in the
package's ``vars/${PKG_NAME}.vars`` ``vars`` file. Consult section [4.1](#41-build-steps)
for a list of package build steps and how they are overriden.
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 4. Build variables"
## 4. Build variables

The following variables are primarily defined in ``midipix.env`` and may be
overriden on a per-build basis on the command-line after the last option
argument, if any, e.g.:

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
[//]: # "{{{ 4.1. Build steps"
## 4.1. Build steps

Package builds are divided up into consecutively executed build steps until
completion or aborted on failure unless relaxed mode is enabled by passing
``-R``.  
  
Each build step corresponds to a function in the corresponding ``subr/pkg_*.subr``
script and may be overriden entirely by a function named ``pkg_<package name>_<build step>()``
or composed in terms of prior and/or subsequent execution by a function named
``pkg_<package name>_<build step>_pre()`` and/or ``pkg_<package name>_<build step>_post()``,
respectively, in the package's ``vars`` file. If a function named ``pkg_<package name>_all()``
exists, it will override all build steps.  
  
Build step status is tracked on a per-package basis by state files beneath
``${BUILD_WORKDIR}`` following the format ``.<package name>.<build step>``;
package build completion corresponds to the pseudo-build step ``finish``.

| Name                | Description                                                                                                                                                                           |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| fetch_download      | Download package archive & verify w/ SHA-256 message digest and/or clone Git repository/ies                                                                                           |
| fetch_extract       | Extract package archive, if any                                                                                                                                                       |
| configure_patch_pre | Apply ``chainport`` patches and/or patches beneath ``patches/`` prior to (GNU autotools or similar) configuration                                                                     |
| configure_autotools | Bootstrap (GNU autools or similar) environment, and install ``config.sub`` and ``config.cache``                                                                                       |
| configure_patch     | Apply patches beneath ``patches/`` and/or set in ``${PKG_PATCHES_EXTRA}`` after (GNU autotools or similar) configuration                                                              |
| configure           | Perform package (GNU autools or similar) configuration w/ configuration-time set of environment variables                                                                             |
| build               | Call ``make(1)`` w/ build-time set of make variables                                                                                                                                  |
| install_subdirs     | Create default directory hierarchy in ``${PKG_DESTDIR}``, optionally amended w/ ``${PKG_INSTALL_FILES_DESTDIR_EXTRA}``                                                                |
| install_make        | Call ``make(1)`` w/ ``${PKG_INSTALL_TARGET}`` (defaults to ``install``) and installation-time set of make variables                                                                   |
| install_files       | Install ``${PKG_INSTALL_FILES}``, ``pkgconf(1)`` package files, and/or stripped binaries within ``${PKG_DESTDIR}``                                                                    |
| install_libs        | Purge libtool ``.la`` files and install shared objects within ``${PKG_DESTDIR}`` w/ ``perk`` and corresponding symbolic links                                                         |
| install             | Fix directory and file mode bits within ``${PKG_DESTDIR}``, install into ``${PKG_PREFIX}`` under mutex, and add package to ``${PREFIX}/pkglist.${PKG_BUILD_TYPE}`` (unless inhibited) |
| install_rpm         | Build package RPM w/ auto-generated specifiation file based on ``etc/package.spec`` beneath ``${PREFIX_RPM}``                                                                         |
| clean               | Clean ``${PKG_BUILD_DIR}`` and/or ``${PKG_DESTDIR}`` and/or ``${PKG_BASE_DIR}/${PKG_SUBDIR}`` as per ``-C build,dest,src``, resp., if any                                             |
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.2. Package variables"
## 4.2. Package variables

The following variables are package-specific and receive their value from either
top-level defaults defined in ``midipix.env``, build group-specific defaults
from the build group the package pertains to and defined in its corresponding
file beneath ``groups/``, or package-specific overrides defined either in the
latter and/or in its corresponding file beneath ``vars/``.  
Additionally, overrides may be specified on a per-build basis on the command-
line after the last argument, with each variable prefixed w/ ``PKG_``, e.g.:
``./build.sh [ ... ] PKG_ZSH_CC="/usr/bin/clang"``.  
  
The minimum set of package variables that must be provided is ``SHA256SUM, URL,
VERSION`` and/or ``URLS_GIT``, respectively.

| Package variable name       | Description                                                                                                                                 |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| AR                          | Command- or pathname of toolchain library archive editor ``ar(1)``)                                                                         |
| BASE_DIR                    | Absolute pathname to package build root directory beneath ``${BUILD_WORKDIR}``                                                              |
| BUILD_DIR                   | Directory name of package build directory beneath ``${PKG_BASE_DIR}``                                                                       |
| BUILD_STEPS_DISABLE         | List of build steps to disable during package build                                                                                         |
| BUILD_TYPE                  | Cross-compiled toolchain (``cross``,) host (``host```,) or cross-compiled package (``native``) build type                                   |
| CC                          | Command- or pathname of toolchain C compiler ``cc(1)``)                                                                                     |
| CFLAGS_BUILD_EXTRA          | Additional C compiler flags during package ``make(1)``) build                                                                               |
| CFLAGS_CONFIGURE            | C compiler flags during package (GNU autotools or similar) configuration                                                                    |
| CFLAGS_CONFIGURE_EXTRA      | Additional C compiler flags during package (GNU autotools or similar) configuration                                                         |
| CONFIG_CACHE                | List of GNU autotools configuration cache variables                                                                                         |
| CONFIG_CACHE_EXTRA          | Additional list of GNU autotools configuration cache variables                                                                              |
| CONFIG_CACHE_LOCAL          | Additional list of GNU autotools configuration cache variables                                                                              |
| CONFIGURE                   | Command- or pathname to package (GNU autotools or similar) configuration script                                                             |
| CONFIGURE_ARGS              | List of arguments to package (GNU autotools or similar) configuration script                                                                |
| CONFIGURE_ARGS_EXTRA        | Additional list of arguments to package (GNU autotools or similar) configuration script                                                     |
| CXX                         | Command- or pathname of toolchain C++ compiler ``c++(1)``)                                                                                  |
| CXXFLAGS_CONFIGURE          | List of C++ compiler flags during package (GNU autotools or similar) configuration                                                          |
| CXXFLAGS_CONFIGURE_EXTRA    | Additional list of C++ compiler flags during package (GNU autotools or similar) configuration                                               |
| DEPENDS                     | List of package-package dependencies                                                                                                        |
| DESTDIR                     | Directory name of package installation destination directory beneath ``${PKG_BASE_DIR}``                                                    |
| DISABLED                    | Disable package                                                                                                                             |
| ENV_VARS_EXTRA              | List of double colon-separated environment variable equality sign-separated name-value pairs to set during package build                    |
| FNAME                       | Filename of package archive file                                                                                                            |
| FORCE_AUTORECONF            | Forcibly run ``autoreconf -fiv`` prior to package (GNU autotools or similar) configuration                                                  |
| GITROOT                     | midipix packages Git URL prefix                                                                                                             |
| INHERIT_FROM                | Inherit variables from named package                                                                                                        |
| INSTALL_FILES               | Whitespace-separated list of files to manually install into the package installation destination directory beneath ``${PKG_BASE_DIR}``      |
| INSTALL_FILES_DESTDIR       | Whitespace-separated list of files to initialise the package installation destination directory beneath ``${PKG_BASE_DIR}`` with            |
| INSTALL_FILES_DESTDIR_EXTRA | Additional whitespace-separated list of files to initialise the package installation destination directory beneath ``${PKG_BASE_DIR}`` with |
| INSTALL_TARGET              | Name of package build ``make(1)`` installation target                                                                                       |
| INSTALL_TARGET_EXTRA        | Additional name of package build ``make(1)`` installation target                                                                            |
| IN_TREE                     | Build package in-tree within ``${PKG_SUBDIR}``                                                                                              |
| LDFLAGS_BUILD_EXTRA         | Additional linker flags during package ``make(1)``) build                                                                                   |
| LDFLAGS_CONFIGURE           | Linker flags during package (GNU autotools or similar) configuration                                                                        |
| LDFLAGS_CONFIGURE_EXTRA     | Additional linker flags during package (GNU autotools or similar) configuration                                                             |
| LIBTOOL                     | Command- or pathname of ``libtool(1)`` (defaults to ``slibtool``)                                                                           |
| MAKE                        | Command line of ``make(1)``                                                                                                                 |
| MAKEFLAGS_BUILD             | List of ``make(1)`` flags during package ``make(1)``) build                                                                                 |
| MAKEFLAGS_BUILD_EXTRA       | Additional list of ``make(1)`` flags during package ``make(1)``) build                                                                      |
| MAKEFLAGS_INSTALL           | List of ``make(1)`` flags during package ``make(1)``) installation                                                                          |
| MAKEFLAGS_INSTALL_EXTRA     | Additional list of ``make(1)`` flags during package ``make(1)``) installation                                                               |
| MAKE_INSTALL_VNAME          | Variable name of ``make(1)`` installation destination directory variable during package ``make(1)``) installation                           |
| NO_CLEAN                    | Inhibit cleaning of package build directory beneath ``${PKG_BASE_DIR}`` pre-finish                                                          |
| NO_CLEAN_BASE_DIR           | Inhibit cleaning of package build root directory beneath ``${BUILD_WORKDIR}``                                                               |
| NO_LOG_VARS                 | Inhibit logging of build & package variables pre-package build                                                                              |
| PATCHES_EXTRA               | Additional list of patches to apply                                                                                                         |
| PKG_CONFIG                  | Command- or pathname of ``pkg-config(1)``                                                                                                   |
| PKG_CONFIG_PATH             | ``pkg-config(1)`` search path                                                                                                               |
| PKGLIST_DISABLE             | Inhibit inclusion into ``${PREFIX}/pkglist.${PKG_BUILD_TYPE}``                                                                              |
| PREFIX                      | Absolute pathname of top-level installation directory and package search path                                                               |
| PYTHON                      | Command- or pathname of Python                                                                                                              |
| RANLIB                      | Command- or pathname of toolchain library archive index generator ``ranlib(1)``)                                                            |
| RPM_DISABLE                 | Inhibit creation of RPM archive                                                                                                             |
| SHA256SUM                   | SHA-256 message digest of package archive                                                                                                   |
| SUBDIR                      | Name of extracted archive or git-{clone,pull}(1)'d directory                                                                                |
| TARGET                      | Dash-separated {build,host,target} triplet                                                                                                  |
| URL                         | URL to package archive                                                                                                                      |
| URLS_GIT                    | List of package Git URL(s) (``*name*=*URL*@*branch*``)                                                                                      |
| VERSION                     | Package version                                                                                                                             |
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 5. References"
## 5. References

* ``Sun, 25 Apr 2016 09:04:08 +0000 [1]`` <a href="https://www.musl-libc.org/faq.html" id="r1">musl FAQ</a>  
* ``Wed, 04 Mar 2020 13:36:19 +0000 [2]`` <a href="https://midipix.org/#sec-midipix" id="r2">midipix - what is midipix, and how is it different?</a>  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
  
[modeline]: # ( vim: set ff=dos tw=0: )
