> N.B. If you're interested in building Midipix using this script, please join
the project's IRC channel #midipix on Freenode and ask for the address of the
internal repositories required in order to build Midipix.

[//]: # "{{{ Table of contents"
# Table of Contents

1. [What is midipix, and how is it different?](#1-what-is-midipix-and-how-is-it-different)  
2. [Building, installing, and using a midipix distribution](#2-building-installing-and-using-a-midipix-distribution)  
	2.1. [Build-time dependencies](#21-build-time-dependencies)  
		2.1.1. [Alpine-specific notate bene](#211-alpine-specific-notate-bene)  
	2.2. [Deployment](#22-deployment)  
	2.3. [System requirements](#23-system-requirements)  
	2.4. [Troubleshooting](#24-troubleshooting)  
3. [Common tasks](#3-common-tasks)  
	3.1. [Fault-tolerant & highly optimised 3D laser show-equipped usage screen](#31-fault-tolerant--highly-optimised-3d-laser-show-equipped-usage-screen)  
	3.2. [Adding a package](#32-adding-a-package)  
	3.3. [Addressing build failure](#33-addressing-build-failure)  
	3.4. [Patches and ``vars`` files](#34-patches-and-vars-files)  
	3.5. [``pkgtool.sh``](#35-pkgtoolsh)  
		3.5.1. [``-s``: package build shell environment](#351-s-package-build-shell-environment)  
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
  
*(reproduced from &lbrack;[2](https://midipix.org/#sec-midipix)&rbrack;)*
  
[Back to top](#table-of-contents)

[//]: "}}}"

[//]: # "{{{ 2. Building, installing, and using a midipix distribution"
## 2. Building, installing and using a midipix distribution

A Midipix distribution consists of the following:
* the native Midipix toolchain, consisting of perk, gcc, its dependencies,
  and binutils,
* musl, a lightweight, fast, simple, and free libc&lbrack;[1](https://www.musl-libc.org/faq.html)&rbrack; used by Midipix,
* the Midipix runtime components that bridge the gap between the libc and the
  executive subsystems of all Windows NT-derived Windows OS starting with and
  including Windows XP, and
* a steadily increasing number of 3rd party open source packages, as expected in
  any modern POSIX-compliant \*nix environment, including GNU coreutils, shells,
  libraries such as ncurses, libressl, as well as Perl and Python.

Install the build-time dependencies listed in section [2.1](#21-build-time-dependencies),
clone this repository (e.g. ``git clone https://dev.midipix.org/build/midipix_build``)
and run the following command line:

```shell
./build.sh -a nt64 -b release -D zipdist -P -v
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
* **Debian/-derived Linux**: binutils bzip2 clzip cmake coreutils curl findutils g++ gawk
			     gcc git grep gzip hostname libc6-dev libxml-parser-perl lzma
			     make patch perl procps sed tar util-linux wget xz-utils zip
* **OpenSUSE Linux**: binutils bzip2 cmake coreutils curl findutils gawk gcc
		      gcc-c++ git grep gzip hostname linux-glibc-devel lzip make
		      patch perl perl-XML-Parser procps sed tar util-linux wget
		      xz zip
  
> N.B. Busybox is not supported. Awk implementations other than GNU Awk are not supported.
  
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
Create a directory on the target machine and extract the contents of the distribution
ZIP archive into it, run ``bash.bat``, and then ``/install.sh`` inside the resulting
self-contained Midipix installation shell window.  
  
> N.B. The pathname of the target directory containing ``bash.bat`` and all other
distribution files must not contain whitespaces.  
  
> N.B. The Midipix installer defaults to ``/dev/fs/c/midipix (C:\midipix)``. If left
unchanged, the distribution ZIP archive must not be extracted into a directory of the
same pathname.  
  
> N.B. The user installing and using Midipix must have been delegated the ``SeCreateSymbolicLinkPrivilege``
("Create symbolic links") privilege&lbrack;[3](https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/user-rights-assignment)&rbrack; and additionally be a non-administrator account
owing to the UAC-related filtering policy of tokens introduced by Windows Vista&lbrack;[4](https://docs.microsoft.com/en-us/previous-versions/dotnet/articles/bb530410%28v%3dmsdn%2e10%29)&rbrack;.  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.3. System requirements"
### 2.3. System requirements

The following build-time system requirements are assessed on build hosts
equipped with the following hardware at minimum:
* Intel(R) Xeon(R) CPU W3520 @ 2.67GHz (8 cores)
* 7200 RPM SATA 3.1 HDD
* 6 GB RAM

| Target architecture | Build kind | Distribution kinds selected | Average build time | Disk space required | Peak RAM usage |
| ------------------- | ---------- | --------------------------- | ------------------ | ------------------- | -------------- |
| nt64                | debug      | (none)                      | 2 hours            | 57.62 GB            | 3.55 GB        |
| nt64                | release    | (none)                      | 1 hours 45 minutes | 36.51 GB            | 3.21 GB        |

Package archive files and/or Git repositories additionally consume at least
1.82 GB.

*(last update: Thu, 05 Mar 2020 09:25:41 +0000)*

These are the Midipix distribution disk space system requirements:

| Target architecture | Build kind | Distribution | Installation directory | Archive file |
| ------------------- | ---------- | ------------ | ---------------------- | ------------ |
| nt64                | debug      | 7.3 GB       |  2.3 GB                | 2.1 GB       |
| nt64                | release    | 3.2 GB       |  913 MB                | 830 MB       |

The installation directory and archive file may be safely deleted post-installation.

*(last update: Thu, 07 Jan 2021 18:20:06 +0000)*
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.4. Troubleshooting"
### 2.4. Troubleshooting

Midipix presently provides, inter alia, strace-like functionality via
ntctty's logging capabilities. This is available both through the regular
``strace(1)`` command as distributed, which however **must** be provided
with an absolute pathname without consideration for ``${PATH}``, as well
as directly via ``ntctty.exe`` for a session by running ``ntctty.exe``
with the ``--log-level 7`` option, e.g.:

```shell
$ #strace ls -la /        # (incorrect, relative pathname)
$ strace /bin/ls -la /    # (correct, absolute pathname)
$ ntctty.exe --log-level 7 -e /bin/ls -la /
$ ntctty.exe --log-level=7 -e /bin/ls -la /
$ ntctty.exe --log-level 7 -e /bin/sh -c "ls -la /"
$ ntctty.exe --log-level=7 -e /bin/sh -c "ls -la /"
```

By default, ``ntctty.exe`` log files are written into the /var/log/ntctty
directory; this may be adjusted with the ``--log-dir`` and/or
``--log-file`` options. ``strace(1)`` logs to stderr by default.
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 3. Common tasks"
## 3. Common tasks

Rebuild set of packages in isolation:
```shell
./build.sh [ ... ] -r mc,zsh
```
  
Rebuild set of packages along w/ their dependencies, if any, as needed, or forcibly,
respectively:
```shell
./build.sh [ ... ] -r \*mc,zsh
./build.sh [ ... ] -r \*\*mc,zsh
```
  
Forcibly rebuild all reverse dependencies of a set of packages:
```shell
./build.sh [ ... ] -r \*\*\*glib,libflac
```
  
Restart the ``configure``, ``build``, and ``install`` steps of the ``coreutils``
package:
```shell
./build.sh -r coreutils:configure,build,install
```
  
Rebuild entire build groups including or excluding group dependencies, respectively:
```shell
./build.sh [ ... ] -r ALL native_runtime
./build.sh [ ... ] -r ALL =native_runtime
```
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.1. Fault-tolerant & highly optimised 3D laser show-equipped usage screen"
## 3.1. Fault-tolerant & highly optimised 3D laser show-equipped usage screen

```
usage: ./build.sh [-a nt32|nt64] [-b debug|release] [-C dir[,..]] [-d] [-D kind[,..]]
                  [-F ipv4|ipv6|offline]    [-h]    [-p jobs]    [-P]   [-r ALL|LAST]
                  [-r [*[*[*]]]name[,..][:step,..]]  [-R] [-v[v[v[v]]]] [--as-needed]
                  [--debug-minipix] [--dump-on-abort] [--roar]
                  [[=]<group>|<variable name>=<variable override>[ ..]]

        -a nt32|nt64      Selects 32-bit or 64-bit architecture; defaults to nt64.
        -b debug|release  Selects debug or release build kind; defaults to debug.
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
        --dump-on-abort   Produce package environment dump files on build failure to be
                          used in conjuction with pkg_shell.sh script (excludes -R.)
        <group>[ ..]      One of: dev_packages, dist, host_deps, host_deps_rpm,
                          host_toolchain, host_tools, minipix, native_packages,
                          native_runtime, native_toolchain, native_tools.

                          Prepend w/ `=' to inhibit group-group dependency expansion.

        <variable name>=<variable override>[ ..]
                          Override build or package variable.
```
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.2. Adding a package"
## 3.2. Adding a package

Packages are grouped into *build groups* according to sets of common package
variable defaults, such as ``${PKG_CFLAGS_CONFIGURE}, ${PKG_LDFLAGS_CONFIGURE}``
and ``${PKG_CONFIGURE_ARGS}``, and semantic interrelatedness, such as the
``native_runtime`` build group comprising the Midipix runtime components.
Packages may belong to more than one build group such as when subsumed by a shorthand
build group e.g. the ``dev_packages`` build group, as long as the default set of build
groups or as overriden on the command line does not entail group membership conflicts.  
  
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

During package build, standard error and output are redirected into a log file beneath
``${BUILD_WORKDIR}`` named ``${PKG_NAME}_stderrout.log``, following a package variable
dump. If ``-vv`` was specified, package logs will additionally be printed to standard
output. If ``-vvv`` was specified, ``xtrace`` will be set during package builds for
rudimentary debugging purposes. Additionally, packages using GNU autotools will, if
package configuration failed or appears relevant, log the configuration process in detail
in, most usually, ``${PKG_BUILD_DIR}/config.log``.  

If ``--dump-on-abort`` was specified, a subset of the variables set and environment
variables exported will be written to ``${BUILD_WORKDIR}/${PKG_NAME}.dump``, which may
subsequently be used in order to obtain a package build shell environment with the
``pkgtool.sh`` script (see sections [3.5](#35-pkgtoolsh)[3.5.1](#351-s-package-build-shell-environment).)
  
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
[//]: # "{{{ 3.5. ``pkgtool.sh``"
## 3.5. ``pkgtool.sh``

```
usage: ./pkgtool.sh [-a nt32|nt64] [-b debug|release] [-i|-r|-s|-t]
                    [<variable name>=<variable override>[ ..]] name

        -a nt32|nt64      Selects 32-bit or 64-bit architecture; defaults to nt64.
        -b debug|release  Selects debug or release build kind; defaults to debug.
        -i                List package variables and dependencies of single named package.
        -r                List reverse dependencies of single named package.
        -s                Enter interactive package build shell environment for single
                          named package; requires a package dump file. If the package
                          has not been built yet or built successfully, it will be rebuilt
                          at build steps up until, by default, the `build' build step and
                          forcibly aborted and dumped prior to enterting the shell.
        -t                Produce tarball of package build root directory and build log
                          file for the purpose of distribution given build failure.

        <variable name>=<variable override>[ ..]
                          Override build variable.
```
  
> N.B. When using ``pkgtool.sh`` on a build w/ build variables (see section [4](#4-build-variables))
overriden on the command line or via the environment, ensure that they are included in the
``pkgtool.sh`` command line, preceding the package name, or exported, respectively.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.5.1. -s: package build shell environment"
### 3.5.1. -s: package build shell environment

When ``build.sh`` is executed with the ``--dump-on-abort`` option, a subset of the
variables set and environment variables exported will be written to ``${BUILD_WORKDIR}/${PKG_NAME}.dump``
on build failure, which may subsequently be used in order to obtain a package build shell
environment with the ``pkgtool.sh`` script, e.g.:  
  
```
midipix_build@sandbox:(src/midipix_build)> $ ./pkgtool.sh -a nt64 -b debug -s mc
==> 2020/03/11 15:46:28 Launching shell `/usr/bin/zsh' within package environment and `/home/midipix_build/midipix/nt64/debug/tmp'.
==> 2020/03/11 15:46:28 Run $R to rebuild `mc'.
==> 2020/03/11 15:46:28 Run $RS <step> to restart the specified build step of `mc'
==> 2020/03/11 15:46:28 Run $D to automatically regenerate the patch for `mc'.
midipix_build@sandbox:(mc-native-x86_64-nt64-midipix/obj)> $
```
  
If a package build shell environment is desired for a package that has either not been
built at all or built successfully, ``pkgshell.sh`` will attempt to rebuild the package
at build steps up until, by default, ``build``, and then forcibly abort the build and
write ``${BUILD_WORKDIR}/${PKG_NAME}.dump`` as above prior to entering the shell.  
  
Consult sections [3.2](#32-adding-a-package), [3.4](#34-patches-and-vars-files), [4](#4-build-variables),
[4.1](#41-build-steps), and [4.2](#42-package-variables) for further information
concerning the package build process.  
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 4. Build variables"
## 4. Build variables

The following variables are primarily defined in ``midipix.env`` and may be
overriden on a per-build basis on the command-line, the environment, and/or
``${HOME}/midipix_build.vars``, ``${HOME}/.midipix_build.vars``, and/or
``../midipix_build.vars``, e.g.:

```shell
./build.sh -a nt64 -b release -D minipix,zipdist -P -v PREFIX_ROOT="${HOME}/midipix_tmp"
env ARCH=nt64 BUILD_KIND=release PREFIX_ROOT="${HOME}/midipix_tmp" ./build.sh -D minipix,zipdist -P -v
```

| Variable name    | Default value                        | Description                                                                   |
| ---------------- | ------------------------------------ | ----------------------------------------------------------------------------- |
| ARCH             | nt64                                 | Target 32-bit (nt32) or 64-bit (nt64) architecture                            |
| BUILD_DLCACHEDIR | ${PREFIX_ROOT}/dlcache               | Absolute pathname to package downloads cache root directory                   |
| BUILD_HNAME      | $(hostname)                          | Build system hostname                                                         |
| BUILD_KIND       | debug                                | Build w/ debugging (debug) or release compiler flags                          |
| BUILD_WORKDIR    | ${PREFIX}/tmp                        | Absolute pathname to temporary package build root directory                   |
| PREFIX           | ${PREFIX_ROOT}/${ARCH}/${BUILD_KIND} | Absolute pathname to architecture- & build type-specific build root directory |
| PREFIX_CROSS     | ${PREFIX}/${DEFAULT_TARGET}          | Absolute pathname to toolchain root directory                                 |
| PREFIX_MINGW32   | ${PREFIX}/x86_64-w64-mingw32         | Absolute pathname to MinGW toolchain root directory                           |
| PREFIX_MINIPIX   | ${PREFIX}/minipix                    | Absolute pathname to minipix distribution root directory                      |
| PREFIX_NATIVE    | ${PREFIX}/native                     | Absolute pathname to cross-compiled packages root directory                   |
| PREFIX_ROOT      | ${HOME}/midipix                      | Absolute pathname to top-level directory                                      |
| PREFIX_RPM       | ${PREFIX}/rpm                        | Absolute pathname to package RPM archive root directory                       |
  
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

| Name                | Description                                                                                                                                                                                                                                                                              |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                    |
| fetch_download      | Download package archive & verify w/ SHA-256 message digest and/or clone Git repository/ies                                                                                                                                                                                              |
| fetch_extract       | Extract package archive, if any                                                                                                                                                                                                                                                          |
| configure_patch_pre | Apply ``chainport`` patches and/or patches beneath ``patches/`` prior to (GNU autotools or similar) configuration                                                                                                                                                                        |
| configure_autotools | Bootstrap (GNU autools or similar) environment, and install ``config.sub`` and ``config.cache``                                                                                                                                                                                          |
| configure_patch     | Apply patches beneath ``patches/`` and/or set in ``${PKG_PATCHES_EXTRA}`` after (GNU autotools or similar) configuration                                                                                                                                                                 |
| configure           | Perform package (GNU autools or similar) configuration w/ configuration-time set of environment variables                                                                                                                                                                                |
| build               | Call ``make(1)`` w/ build-time set of make variables                                                                                                                                                                                                                                     |
| install_subdirs     | Create default directory hierarchy in ``${PKG_DESTDIR}``, optionally amended w/ ``${PKG_INSTALL_FILES_DESTDIR_EXTRA}``                                                                                                                                                                   |
| install_make        | Call ``make(1)`` w/ ``${PKG_INSTALL_TARGET}`` (defaults to ``install``) and installation-time set of make variables                                                                                                                                                                      |
| install_files       | Install ``${PKG_INSTALL_FILES}``, fix directory and file mode bits within ``${PKG_DESTDIR}`` and optionally ``${PKG_DESTDIR_HOST}``, ``pkgconf(1)`` package files, and/or stripped binaries within ``${PKG_DESTDIR}``                                                                    |
| install_libs        | Purge libtool ``.la`` files and install shared objects within ``${PKG_DESTDIR}`` w/ ``perk`` and corresponding symbolic links                                                                                                                                                            |
| install             | Install into ``${PKG_PREFIX}``, and optionally ``${PKG_DESTDIR_HOST}`` into ``${PREFIX}``, under mutex, and add package to ``${PREFIX}/pkglist.${PKG_BUILD_TYPE}`` (unless inhibited)                                                                                                    |
| install_rpm         | Build package RPM w/ auto-generated specifiation file based on ``etc/package.spec`` beneath ``${PREFIX_RPM}``                                                                                                                                                                            |
| clean               | Clean ``${PKG_BUILD_DIR}`` and/or ``${PKG_DESTDIR}`` and/or ``${PKG_DESTDIR_HOST}`` and/or ``${PKG_BASE_DIR}/${PKG_SUBDIR}`` as per ``-C build,dest,src``, resp., if any                                                                                                                 |
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.2. Package variables"
## 4.2. Package variables

The following variables are package-specific and receive their value from either
top-level defaults defined in ``midipix.env``, build group-specific defaults
from the build group the package pertains to and defined in its corresponding
file beneath ``groups/``, or package-specific overrides defined either in the
latter and/or in its corresponding file beneath ``vars/``, with one of the following
prefixes:

| Variable name prefix				|
| ---------------------------------------------	|
| DEFAULT					|
| DEFAULT_``${BUILD_TYPE}``			|
| DEFAULT_``${GROUP_NAME}``			|
| ``${GROUP_NAME}``				|
| PKG_``${INHERIT_FROM}``			|
| PKG_``${INHERIT_FROM}``_``${BUILD_KIND}``	|
| PKG_``${NAME}``				|
| PKG_``${NAME}``_``${BUILD_KIND}``		|

Additionally, overrides may be specified on a per-build basis on the command-
line, with each variable prefixed w/ ``PKG_``, e.g.:
``./build.sh [ ... ] PKG_ZSH_CC="/usr/bin/clang"``.  
  
The minimum set of package variables that must be provided is ``SHA256SUM, URL,
VERSION`` and/or ``URLS_GIT``, respectively.

| Package variable name       | Description                                                                                                                                 |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| AR                          | Command- or pathname of toolchain library archive editor ``ar(1)``                                                                          |
| BASE_DIR                    | Absolute pathname to package build root directory beneath ``${BUILD_WORKDIR}``                                                              |
| BUILD_DIR                   | Directory name of package build directory beneath ``${PKG_BASE_DIR}``                                                                       |
| BUILD_STEPS_DISABLE         | List of build steps to disable during package build                                                                                         |
| BUILD_TYPE                  | Cross-compiled toolchain (``cross``,) host (``host``,) or cross-compiled package (``native``) build type                                    |
| CC                          | Command- or pathname of toolchain C compiler ``cc(1)``                                                                                      |
| CFLAGS_BUILD                | C compiler flags during package ``make(1)``  build                                                                                          |
| CFLAGS_BUILD_EXTRA          | Additional C compiler flags during package ``make(1)``  build                                                                               |
| CFLAGS_CONFIGURE            | C compiler flags during package (GNU autotools or similar) configuration                                                                    |
| CFLAGS_CONFIGURE_EXTRA      | Additional C compiler flags during package (GNU autotools or similar) configuration                                                         |
| CONFIG_CACHE                | List of GNU autotools configuration cache variables                                                                                         |
| CONFIG_CACHE_EXTRA          | Additional list of GNU autotools configuration cache variables                                                                              |
| CONFIG_CACHE_LOCAL          | Additional list of GNU autotools configuration cache variables                                                                              |
| CONFIGURE                   | Command- or pathname to package (GNU autotools or similar) configuration script                                                             |
| CONFIGURE_ARGS              | List of arguments to package (GNU autotools or similar) configuration script                                                                |
| CONFIGURE_ARGS_EXTRA        | Additional list of arguments to package (GNU autotools or similar) configuration script                                                     |
| CXX                         | Command- or pathname of toolchain C++ compiler ``c++(1)``                                                                                   |
| CXXFLAGS_CONFIGURE          | List of C++ compiler flags during package (GNU autotools or similar) configuration                                                          |
| CXXFLAGS_CONFIGURE_EXTRA    | Additional list of C++ compiler flags during package (GNU autotools or similar) configuration                                               |
| DEPENDS                     | List of package-package dependencies                                                                                                        |
| DESTDIR                     | Directory name of package installation destination directory beneath ``${PKG_BASE_DIR}``                                                    |
| DESTDIR_HOST                | Directory name of optional host package installation destination directory beneath ``${PKG_BASE_DIR}``                                      |
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
| LDFLAGS_BUILD_EXTRA         | Additional linker flags during package ``make(1)``  build                                                                                   |
| LDFLAGS_CONFIGURE           | Linker flags during package (GNU autotools or similar) configuration                                                                        |
| LDFLAGS_CONFIGURE_EXTRA     | Additional linker flags during package (GNU autotools or similar) configuration                                                             |
| LIBTOOL                     | Command- or pathname of ``libtool(1)`` (defaults to ``slibtool``)                                                                           |
| MAKE                        | Command line of ``make(1)``                                                                                                                 |
| MAKE_SUBDIRS                | List of ``make(1)`` subdirectories to exclusively build                                                                                     |
| MAKEFLAGS_BUILD             | List of ``make(1)`` flags during package ``make(1)``  build                                                                                 |
| MAKEFLAGS_BUILD_EXTRA       | Additional list of ``make(1)`` flags during package ``make(1)``  build                                                                      |
| MAKEFLAGS_INSTALL           | List of ``make(1)`` flags during package ``make(1)``  installation                                                                          |
| MAKEFLAGS_INSTALL_EXTRA     | Additional list of ``make(1)`` flags during package ``make(1)``  installation                                                               |
| MAKEFLAGS_VERBOSITY         | Variable-value pair to pass to ``make(1)`` in order to force echo-back of command lines prior to execution                                  |
| MAKE_INSTALL_VNAME          | Variable name of ``make(1)`` installation destination directory variable during package ``make(1)``  installation                           |
| NO_CLEAN                    | Inhibit cleaning of package build directory beneath ``${PKG_BASE_DIR}`` pre-finish                                                          |
| NO_CLEAN_BASE_DIR           | Inhibit cleaning of package build root directory beneath ``${BUILD_WORKDIR}``                                                               |
| NO_LOG_VARS                 | Inhibit logging of build & package variables pre-package build                                                                              |
| PATCHES_EXTRA               | Additional list of patches to apply                                                                                                         |
| PKG_CONFIG                  | Command- or pathname of ``pkg-config(1)``                                                                                                   |
| PKG_CONFIG_LIBDIR           | ``pkg-config(1)`` search directory                                                                                                          |
| PKGLIST_DISABLE             | Inhibit inclusion into ``${PREFIX}/pkglist.${PKG_BUILD_TYPE}``                                                                              |
| PREFIX                      | Absolute pathname of top-level installation directory and package search path                                                               |
| PYTHON                      | Command- or pathname of Python                                                                                                              |
| RANLIB                      | Command- or pathname of toolchain library archive index generator ``ranlib(1)``                                                             |
| RPM_DISABLE                 | Inhibit creation of RPM archive                                                                                                             |
| SHA256SUM                   | SHA-256 message digest of package archive                                                                                                   |
| SUBDIR                      | Name of extracted archive or git-{clone,pull}(1)'d directory                                                                                |
| TARGET                      | Dash-separated {build,host,target} triplet                                                                                                  |
| URL                         | URL to package archive, optionally appended with whitespace-separated list of alternative URLs                                              |
| URLS_GIT                    | List of package Git URL(s) (``*name*=*URL*@*branch*``)                                                                                      |
| VERSION                     | Package version                                                                                                                             |
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 5. References"
## 5. References

* ``Sun, 25 Apr 2016 09:04:08 +0000 [1]`` <a href="https://www.musl-libc.org/faq.html" id="r1">musl FAQ</a>  
* ``Wed, 04 Mar 2020 13:36:19 +0000 [2]`` <a href="https://midipix.org/#sec-midipix" id="r2">midipix - what is midipix, and how is it different?</a>  
* ``Wed, 29 Apr 2020 23:33:34 +0100 [3]`` <a href="https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/user-rights-assignment" id="r3">User Rights Assignment (Windows 10) - Windows security | Microsoft Docs</a>  
* ``Wed, 29 Apr 2020 23:33:50 +0100 [4]`` <a href="https://docs.microsoft.com/en-us/previous-versions/dotnet/articles/bb530410%28v%3dmsdn%2e10%29" id="r4">Windows Vista Application Development Requirements for User Account Control Compatibility | Microsoft Docs</a>  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
  
[modeline]: # ( vim: set tw=0: )
