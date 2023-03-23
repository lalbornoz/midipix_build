> N.B. If you're interested in building Midipix using this script, please join
the project's IRC channel #midipix on Libera and ask for the address of the
internal repositories required in order to build Midipix.

> N.B. Due to the present state of the (largely) automated package upstream
updates integration script and, despite frequent contributions, lack of
human resources, it bears mentioning that the 3rd party packages built
and distributed by this script are often not up to date with their resp.
upstream and *may* hence be **insecure**. It is advised that this be taken
into account when deploying and using Midipix distributions.

[//]: # "{{{ Table of contents"
# Table of Contents

1. [What is Midipix, and how is it different?](#1-what-is-midipix-and-how-is-it-different)  
2. [Building and deployment](#2-building-and-deployment)  
	2.1. [Building, installing, and using a Midipix distribution](#21-building-installing-and-using-a-midipix-distribution)  
		2.1.1. [Build-time dependencies](#211-build-time-dependencies)  
			2.1.1.1. [Alpine-specific notate bene](#2111-alpine-specific-notate-bene)  
	2.2. [Deployment](#22-deployment)  
	2.3. [System requirements](#23-system-requirements)  
	2.4. [Troubleshooting](#24-troubleshooting)  
3. [Common concepts and tasks](#3-common-concepts-and-tasks)  
	3.1. [Common tasks](#31-common-tasks)  
	3.2. [Adding a package](#32-adding-a-package)  
	3.3. [Addressing build failure](#33-addressing-build-failure)  
	3.4. [Package archive files and Git repositories](#34-package-archive-files-and-git-repositories)  
	3.5. [Patches and ``vars`` files](#35-patches-and-vars-files)  
4. [Reference](#4-reference)  
	4.1. [Build steps](#41-build-steps)  
	4.2. [Build variables](#42-build-variables)  
	4.3. [File installation DSL](#43-file-installation-dsl)  
	4.4. [Package variables](#44-package-variables)  
		4.4.1. [Package variable types](#441-package-variable-types)  
		4.4.2. [Package variables](#442-package-variables)  
	4.5. [Fault-tolerant & highly optimised 3D laser show-equipped usage screen](#45-fault-tolerant--highly-optimised-3d-laser-show-equipped-usage-screen)  
	4.6. [``pkgtool.sh``](#46-pkgtoolsh)  
	4.7. [Bourne shell coding rules](#47-bourne-shell-coding-rules)  
5. [References](#5-references)  

[//]: "}}}"

[//]: # "{{{ 1. What is Midipix, and how is it different?"
## 1. What is Midipix, and how is it different?

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

[//]: # "{{{ 2. Building and deployment"
## 2. Building and deployment
[//]: # "}}}"
[//]: # "{{{ 2.1. Building, installing, and using a Midipix distribution"
### 2.1. Building, installing and using a Midipix distribution

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

Install the build-time dependencies listed in section [2.1.1](#211-build-time-dependencies),
clone this repository (e.g. ``git clone https://dev.midipix.org/build/midipix_build``)
and run the following command line:

```shell
./build.sh -a nt64 -b release -D zipdist -P -v
```

By default, the build will take place within ``${HOME}/midipix/nt64/release``
and package archive files and/or Git repositores will be downloaded into
``${HOME}/midipix/dlcache``. Consult sections [4.2](#42-build-variables) and
[4.4](#44-package-variables) for the list of available build/package variables
and how to override them.  
Parallelisation is enabled by the above command line for both packages that can
be built independently of each other and ``make(1)`` via ``-j``, limited to the
amount of logical processors on the build host divided by two (2).
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.1.1. Build-time dependencies"
### 2.1.1. Build-time dependencies

* **Alpine Linux**:
  binutils bison bzip2 cmake coreutils curl findutils g++ gawk gcc git grep gzip libc-dev linux-headers lzip m4 make musl-dev net-tools patch perl perl-xml-parser procps sed tar util-linux wget xz zip
* **Arch Linux**:
  binutils bison bzip2 cmake coreutils curl findutils gawk gcc git grep gzip lzip m4 make net-tools patch perl perl-xml-parser procps-ng sed tar util-linux wget xz zip
* **Debian/-derived Linux**:
  binutils bison bzip2 cmake coreutils curl findutils g++ gawk gcc git grep gzip hostname libc6-dev libxml-parser-perl lzip m4 make patch perl procps sed tar util-linux wget xz-utils zip
* **Gentoo Linux**:
  binutils bison bzip2 cmake coreutils curl findutils gawk =gcc-7.5.0-r1 dev-vcs/git grep gzip lzip m4 make patch perl dev-perl/XML-Parser procps sed tar util-linux wget xz-utils zip
* **OpenSUSE Linux**:
  binutils bison bzip2 cmake coreutils curl findutils gawk gcc gcc-c++ git grep gzip hostname linux-glibc-devel lzip m4 make patch perl perl-XML-Parser procps sed tar util-linux wget xz zip
  
#### The distro matrix:

|  Alpine Linux:  |    Arch Linux:     |   Debian/-derived Linux:   |    Gentoo Linux:    |  OpenSUSE Linux:  |
| --------------- | ------------------ | -------------------------- | ------------------- | ----------------- |
| binutils        | binutils           | binutils                   | binutils            | binutils          |
| bison           | bison              | bison                      | bison               | bison             |
| bzip2           | bzip2              | bzip2                      | bzip2               | bzip2             |
| cmake           | cmake              | cmake                      | cmake               | cmake             |
| coreutils       | coreutils          | coreutils                  | coreutils           | coreutils         |
| curl            | curl               | curl                       | curl                | curl              |
| findutils       | findutils          | findutils                  | findutils           | findutils         |
| g++             | -                  | g++                        | -                   | gcc-c++           |
| gawk            | gawk               | gawk                       | gawk                | gawk              |
| gcc             | gcc                | gcc                        | =gcc-7.5.0-r1       | gcc               |
| git             | git                | git                        | dev-vcs/git         | git               |
| grep            | grep               | grep                       | grep                | grep              |
| gzip            | gzip               | gzip                       | gzip                | gzip              |
| -               | -                  | hostname                   | -                   | hostname          |
| libc-dev        | -                  | libc6-dev                  | -                   | linux-glibc-devel |
| linux-headers   | -                  | -                          | -                   | -                 |
| lzip            | lzip               | lzip                       | lzip                | lzip              |
| m4              | m4                 | m4                         | m4                  | m4                |
| make            | make               | make                       | make                | make              |
| musl-dev        | -                  | -                          | -                   | -                 |
| net-tools       | net-tools          | -                          | -                   | -                 |
| patch           | patch              | patch                      | patch               | patch             |
| perl            | perl               | perl                       | perl                | perl              |
| perl-xml-parser | perl-xml-parser    | libxml-parser-perl         | dev-perl/XML-Parser | perl-XML-Parser   |
| procps          | procps-ng          | procps                     | procps              | procps            |
| sed             | sed                | sed                        | sed                 | sed               |
| tar             | tar                | tar                        | tar                 | tar               |
| util-linux      | util-linux         | util-linux                 | util-linux          | util-linux        |
| -               | vi                 | -                          | -                   | -                 |
| wget            | wget               | wget                       | wget                | wget              |
| xz              | xz                 | xz-utils                   | xz-utils            | xz                |
| zip             | zip                | zip                        | zip                 | zip               |

> N.B. Busybox is not supported. Awk implementations other than GNU Awk are not supported.  
  
> N.B. clang is not supported.  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.1.1.1. Alpine-specific notate bene"
#### 2.1.1.1. Alpine-specific notate bene

Some packages (*coreutils*, *grep*, and *tar*, among others) override Alpine's
BusyBox utilities of the same name, as the latter are either non-conformant or
defective.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 2.2. Deployment"
### 2.2. Deployment

On successful completion of the build, a ZIP archive containing the Midipix
distribution will be created inside ``${PREFIX}`` (see section [4.2](#42-build-variables).)
Create a directory on the target machine and extract the contents of the distribution
ZIP archive into it, run ``bash.bat``, and then ``/install.sh`` inside the resulting
self-contained Midipix installation shell window.  
  
Make sure to consult the notate bene below:  
  
> N.B. The pathname of the target directory containing ``bash.bat`` and all other
distribution files must not contain whitespaces.  
  
> N.B. The Midipix installer defaults to ``/dev/fs/c/midipix (C:\midipix)``. If left
unchanged, the distribution ZIP archive must not be extracted into a directory of the
same pathname.  
  
> N.B. The user installing and using Midipix must have been delegated the ``SeCreateSymbolicLinkPrivilege``
("Create symbolic links") privilege&lbrack;[3](https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/user-rights-assignment)&rbrack; and additionally be a non-administrator account
owing to the UAC-related filtering policy of tokens introduced by Windows Vista&lbrack;[4](https://docs.microsoft.com/en-us/previous-versions/dotnet/articles/bb530410%28v%3dmsdn%2e10%29)&rbrack;.  
  
> N.B. On Windows 10 and 11, Windows Defender as well as SmartScreen must be disabled.
  
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

[//]: # "{{{ 3. Common concepts and tasks"
## 3. Common concepts and tasks
[//]: # "}}}"
[//]: # "{{{ 3.1. Common tasks"
### 3.1. Common tasks

Rebuild set of packages in isolation:
```shell
./build.sh [ ... ] -r mc,zsh
```
  
Restart the ``@install`` (shorthand alias) step, with implicit ``finish``, of the
``mc`` and ``zsh`` packages.
```shell
./build.sh [ ... ] -r mc,zsh:@install
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
  
Restart the ``@configure``, ``@build``, and ``@install`` (shorthand alias) steps of the
``coreutils`` package:
```shell
./build.sh -r coreutils:@configure,@build,@install
```
  
Rebuild entire build groups including or excluding group dependencies, respectively:
```shell
./build.sh [ ... ] -r ALL native_runtime
./build.sh [ ... ] -r ALL =native_runtime
```
  
Forcibly (re)download all archive files and/or Git repositories associated with all packages:
```shell
./build.sh [ ... ] -r ALL:@fetch
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
set of package variables required (see above and section [4.4](#44-package-variables).)  
Consult section [3.5](#35-patches-and-vars-files) if the package to be added
requires patches or additional code amending or replacing package build steps
or the entire package build. Consult section [4.1](#41-build-steps) for a list
of package build steps and how they are overriden.
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.3. Addressing build failure"
## 3.3. Addressing build failure

During package build, standard error and output are redirected into a log file beneath
``${BUILD_WORKDIR}`` named ``${PKG_NAME}_stderrout.log``, following a package variable
dump. If ``-V build`` was specified, package logs will additionally be printed to standard
output. If ``-V xtrace`` was specified, ``xtrace`` will be set during package builds for
rudimentary debugging purposes. Additionally, packages using GNU autotools will, if
package configuration failed or appears relevant, log the configuration process in detail
in, most usually, ``${PKG_BUILD_DIR}/config.log``.  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.4. Package archive files and Git repositories"
### 3.4. Package archive files and Git repositories

Packages may have either or both of a SHA-256 message digest checked and to be extracted tarball
(set in ``${PKG_URL}``, ``${PKG_FNAME}``, and ``${PKG_SHA256SUM}``) and/or Git repository or set
thereof (set in ``${PKG_URLS_GIT}``.) Complementing these, an implicitly inferred or, in the
presence of both, explicit primary source directory is specified for each package in ``${PKG_SUBDIR}``.
Furthermore, these may be subject to download caching and/or setting up as well as maintaining
mirrors, including automatic cleanup as well as deduplication in both cases.  
  
A list of pertinent package variables and their formats follows:  

| Name           | Format                                          |
| -------------- | ----------------------------------------------- |
| PKG_FNAME      | ``<single file name>``                          |
| PKG_SHA256SUM  | ``<SHA-256 message digest>``                    |
| PKG_SUBDIR     | ``<relative or single directory name>``         |
| PKG_URL        | ``scheme:[//authority]path[?query][#fragment]`` |
| PKG_URLS_GIT   | ``[subdir=]URL[@branch]``                       |
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 3.5. Patches and ``vars`` files"
## 3.5. Patches and ``vars`` files

Package patches are applied prior and/or subsequent to (GNU autotools or similar) package
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

[//]: # "{{{ 4. Reference"
## 4. Reference
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
  
Build step functions receive the following arguments in the order specified:
  
| Name          | Description                                              |
| ------------- | -------------------------------------------------------- |
| \_group\_name | Package name                                             |
| \_pkg\_name   | Group name                                               |
| \_restart\_at | Optional list of build steps to restart package build at |
  
Build step status is tracked on a per-package basis by state files beneath
``${BUILD_WORKDIR}`` following the format ``.<package name>.<build step>``;
package build completion corresponds to the pseudo-build step ``finish``.

| Name                | Description                                                                                                                                                                                                                                              |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| fetch_clean         | Delete and create ``${PKG_SUBDIR}''                                                                                                                                                                                                                      |
| fetch_download      | Download package archive & verify w/ SHA-256 message digest and/or clone Git repository/ies                                                                                                                                                              |
| fetch_extract       | Extract package archive, if any                                                                                                                                                                                                                          |
| configure_clean     | Delete and create ``${PKG_BUILD_DIR}''                                                                                                                                                                                                                   |
| configure_patch_pre | Apply ``chainport`` patches and/or patches beneath ``patches/`` prior to (GNU autotools or similar) configuration                                                                                                                                        |
| configure_autotools | Bootstrap (GNU autools or similar) environment, and install ``config.sub`` and ``config.cache``                                                                                                                                                          |
| configure_patch     | Apply patches beneath ``patches/`` and/or set in ``${PKG_PATCHES_EXTRA}`` after (GNU autotools or similar) configuration                                                                                                                                 |
| configure           | Perform package (GNU autools or similar or CMake) configuration w/ configuration-time set of environment variables                                                                                                                                       |
| build_clean         | Clean ``${PKG_BUILD_DIR}'' w/ ``make clean'' invocation                                                                                                                                                                                                  |
| build               | Call ``make(1)`` w/ build-time set of make variables                                                                                                                                                                                                     |
| install_clean       | Delete and create ``${PKG_DESTDIR}''                                                                                                                                                                                                                     |
| install_subdirs     | Create default directory hierarchy in ``${PKG_DESTDIR}``, optionally amended w/ ``${PKG_INSTALL_FILES_DESTDIR_EXTRA}``                                                                                                                                   |
| install_make        | Call ``make(1)`` w/ ``${PKG_INSTALL_TARGET}`` (defaults to ``install``) and installation-time set of make variables                                                                                                                                      |
| install_files       | Install ``${PKG_INSTALL_FILES}`` and/or ``${PKG_INSTALL_FILES_V2}``, fix directory and file mode bits within ``${PKG_DESTDIR}`` and optionally ``${PKG_DESTDIR_HOST}``, ``pkgconf(1)`` package files, and/or stripped binaries within ``${PKG_DESTDIR}`` |
| install_libs        | Purge libtool ``.la`` files and install shared objects within ``${PKG_DESTDIR}`` w/ ``perk`` and corresponding symbolic links                                                                                                                            |
| install             | Install into ``${PKG_PREFIX}``, and optionally ``${PKG_DESTDIR_HOST}`` into ``${PREFIX}``, under mutex, and add package to ``${PREFIX}/pkglist.${PKG_BUILD_TYPE}`` (unless inhibited)                                                                    |
| install_rpm         | Build package RPM w/ auto-generated specifiation file based on ``etc/package.spec`` beneath ``${PREFIX_RPM}``                                                                                                                                            |
| clean               | Clean ``${PKG_BUILD_DIR}`` and/or ``${PKG_DESTDIR}`` and/or ``${PKG_DESTDIR_HOST}`` and/or ``${PKG_BASE_DIR}/${PKG_SUBDIR}`` as per ``-C build,dest,src``, resp., if any                                                                                 |
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.2. Build variables"
## 4.2. Build variables

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
[//]: # "{{{ 4.3. File installation DSL"
## 4.3. File installation DSL

File and directory installation, comprising e.g. copying, moving, creating
symbolic links, setting owner and/or permission metadata, are expressed in
a descriptive domain-specific language and integrated with package building
via the package variable ``${PKG_INSTALL_FILES_V2}``, applying during
``install_files`` after the ``install_make`` build step, and ``${PKG_INSTALL_FILES_DESTDIR}``
and ``${PKG_INSTALL_FILES_DESTDIR_EXTRA}`` during ``install_subdirs``. The
``${PKG_INSTALL_FILES_V2}`` must adhere to the following syntax specified in EBNF:  

```
(*
SH_GLOB_PATTERN      = any valid portable shell pattern (see sh(1)); superset of PATHNAME
SH_SUBSTRING_PATTERN = any valid portable substring processing shell pattern (see sh(1));
                       superset of PATHNAME
PARAMETER            = any valid portable shell variable name except that [0-9] may occur
                       the beginning
PATHNAME             = any valid filename, directory name, relative or absolute pathname
                       excluding the characters NUL and NL
 *)

spec                 = { op_flag, } op_unary, "=", op_spec, "\n", { spec } ;
                     | { op_flag, } op_binary, op_spec, "=" op_spec, "\n", { spec } ;
                     | "#" COMMENT ;
op_unary             = "-" | "/" | "t" ;
op_binary            = ":" | "!" | "@" | "+" | "g" | "m" | "o" | "T" ;
op_flag              = "?" ;
op_spec              = pattern_spec | PATHNAME | expr_spec | op_spec ;

pattern_spec         = "%<", SH_GLOB_PATTERN, ">" ;

expr_spec            = "%[", expr, { sexpr_spec }, "%]" ;
expr                 = [ "@" ], "0" .. "9" | "DNAME" | "FNAME" | "ITEM" | PARAMETER ;

sexpr_spec           = sexpr_op_unary, SH_SUBSTRING_PATTERN, { sexpr } ;
sexpr_op_unary       = "##" | "#" | "%%" | "%" ;
```
  
Single ``"="`` characters in ``spec``, the ``"%<"`` and ``"%["`` character
sequences in ``pattern_spec`` and ``expr_spec``, resp., and the ``sexpr_op_unary``
as well as ``sexpr_op_binary`` characters or character sequences may be
escaped with a single backslash (``"\"``.) ``SH_SUBSTRING_PATTERN`` differs
from ``SH_GLOB_PATTERN`` solely in that any of ``sexpr_op_unary`` and
``sexpr_op_binary`` occuring at the beginning of or in the former must
be escaped with a single backslash (``"\"``,) e.g. ``"#\#pattern"`` and
``"%\%pattern"``, etc. and ``"#pat\%ern"`` and ``%patt\#ern", etc., resp.  
  
Named parameters (``PARAMETER``) are supplied via the ``-p name=value``
argument to ``rtl_install()``, whereas numbered parameters are for
internal usage only; the ``"DNAME"``, ``"FNAME"``, and ``"ITEM"`` parameters
lazily evaluate to the directory name, file (aka base) name, and full
pathname of the current item being processed relative to a specification
with a pattern in it.
  
The following parameters are defined by default during ``install_files``:

| Name           | Value                                  |
| -------------  | -------------------------------------- |
| _builddir      | ${PKG_BUILD_DIR}                       |
| _destdir       | ${PKG_BASE_DIR}/${PKG_DESTDIR}         |
| _destdir_host  | ${PKG_BASE_DIR}/${PKG_DESTDIR_HOST}    |
| _files         | ${MIDIPIX_BUILD_PWD}/files/${PKG_NAME} |
| _name          | ${PKG_NAME}                            |
| _prefix        | ${PKG_PREFIX}                          |
| _prefix_host   | ${PREFIX}                              |
| _prefix_native | ${PREFIX_NATIVE}                       |
| _subdir        | ${PKG_BASE_DIR}/${PKG_SUBDIR}          |
| _target        | ${PKG_TARGET}                          |
| _version       | ${PKG_VERSION:-}                       |
| _workdir       | ${BUILD_WORKDIR}                       |
  
The following operation flags are defined:

| Flag      | Description              |
| --------- | ------------------------ |
| ``?``     | Continue on soft failure |
  
The following operations are defined:

| Operation      | Arity  | Description                                                      |
| -------------- | ------ | ---------------------------------------------------------------- |
| ``-``          | Unary  | Remove directories and/or files                                  |
| ``/``          | Unary  | Create directories or trees thereof                              |
| ``t``          | Unary  | touch(1) files and/or directories                                |
| ``:``          | Binary | Copy directories and/or files                                    |
| ``!``          | Binary | Move/rename directories and/or files                             |
| ``@``          | Binary | Create/update symbolic links                                     |
| ``+``          | Binary | Copy directories and/or files if newer and follow symbolic links |
| ``g``          | Binary | Set group owner of files and/or directories                      |
| ``m``          | Binary | Set mode bits of files and/or directories                        |
| ``o``          | Binary | Set user and/or group owner of files and/or directories          |
| ``T``          | Binary | touch(1) files and/or directories with timestamp                 |
  
The following expression modifiers are defined:

| Modifier       | Description                               |
| -------------- | ----------------------------------------- |
| ``@``          | Recursively reevaluate after substituting |
  
The following subexpression operators are defined:

| Operation      | Arity  | Description                                                      |
| -------------- | ------ | ---------------------------------------------------------------- |
| ``##``         | Unary  | Remove largest prefix from left-hand side                        |
| ``#``          | Unary  | Remove prefix from left-hand side                                |
| ``%%``         | Unary  | Remove largest postfix from right-hand side                      |
| ``%``          | Unary  | Remove postfix from right-hand side                              |
  
```shell
#
# Examples:
# 

#
# Create directory %[_minipix]/bin and copy all files
# in %[_minipix_dist]/bin/ to %[_minipix]/bin/ with
# identical file names.
/=%[_minipix]/bin
?%[_minipix_dist]/bin/%<*>=%[_minipix]/bin/%[FNAME]

#
# Rename all files in share/info/ matching *.info to
# their filenames with the `.info' postfix removed and
# `-2.64.info' appended and all files in share/man/man1/
# matching *.1 with the `.1' postfix removed and -2.64.1
# appended.
!share/info/%<*.info>=share/info/%[FNAME%.info]-2.64.info
!share/man/man1/%<*.1>=share/man/man1/%[FNAME%.1]-2.64.1

#
# Create/update symbolic links named include/ffi.h and
# include/ffitarget.h with ../lib/libffi-3.2.1/include/ffi.h
# and ../lib/libffi-3.2.1/include/ffitarget.h as targets, resp.
@../lib/libffi-3.2.1/include/ffi.h=include/ffi.h
@../lib/libffi-3.2.1/include/ffitarget.h=include/ffitarget.h

#
# Manual invocation:
PKG_INSTALL_FILES_V2="
        [ ... ]
";
rtl_install                                                     \
                -p "_builddir=${PKG_BASE_DIR}/${PKG_BUILD_DIR}" \
                -p "_minipix=${PREFIX_MINIPIX##*/}"             \
                -p "_minipix_dist=${PREFIX}/minipix_dist"       \
                -p "_native=${PREFIX_NATIVE##*/}"               \
                -p "_subdir=${PKG_BASE_DIR}/${PKG_SUBDIR}"      \
                -p "_target=${PKG_TARGET}"                      \
                -n -- "${PREFIX}"                               \
                "${PKG_INSTALL_FILES_V2}"; then
        return 1;
fi;

#
# Usage screen:
usage: rtl_install [-i] [-I ifs] [-n] [-p name=val] [-v] prefix spec_list
       -i...........: continue on soft errors
       -I ifs.......: process spec_list with ifs instead of NL
       -n...........: perform dry run
       -p name=val..: set named parameter
       -v...........: increase verbosity
       prefix.......: pathname prefix
       spec_list....: ifs-separated list of specs
```
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.4. Package variables"
### 4.4. Package variables

The following variables are package-specific and receive their value from either
top-level defaults defined in ``midipix.env``, build group-specific defaults from the
build group the package pertains to and defined in its corresponding file beneath
``groups/``, or package-specific overrides defined either in the latter and/or in its
corresponding file beneath ``vars/``, with one of the following prefixes:

| Variable name prefix					|
| ----------------------------------------------------- |
| DEFAULT						|
| DEFAULT_``${BUILD_TYPE}``				|
| DEFAULT_``${GROUP_NAME}``				|
| ``${GROUP_NAME}``					|
| [PKG_``${RELATED_PACKAGE(S)}``]			|
| [PKG_``${RELATED_PACKAGE(S)}``_``${BUILD_KIND}``]	|
| PKG_``${NAME}``					|
| PKG_``${NAME}``_``${BUILD_KIND}``			|

Additionally, overrides may be specified on a per-build basis on the command-
line, with each variable prefixed w/ ``PKG_``, e.g.:
``./build.sh [ ... ] PKG_ZSH_CC="/usr/bin/clang"``.  
  
The minimum set of package variables that must be provided is ``SHA256SUM, URL,
VERSION`` and/or ``URLS_GIT``, respectively.

[//]: # "{{{ 4.4.1 Package variable types"
## 4.4.1 Package variable types

| Type definition               | Description                                                                                                                                  |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| DirName(Abs)			| Absolute pathname to directory                                                                                                               |
| DirName(Rel)			| Relative pathname to director                                                                                                                |
| DirName(Unit)			| Single non-{absolute,relative} directory nam                                                                                                 |
| DirName			| Absolute or relative pathname to director                                                                                                    |
| CmdName			| Absolute or relative pathname to comman                                                                                                      |
| FileName(Abs)			| Absolute pathname to file                                                                                                                    |
| FileName(Rel)			| Relative pathname to file                                                                                                                    |
| FileName(Unit)		| Single non-{absolute,relative} file name                                                                                                     |
| FileName			| Absolute or relative pathname to file                                                                                                        |
| Flag(<type>,<default>)	| Boolean flag of type <type>, e.g. Flag(Boolean) (``true``, ``false``,) Flag(UInt) (0, 1,) Flag(ExitStatus) (>=1, 0) with default or ``auto`` |
| FlagLine			| String of {SP,VT}-separated flags, arguments, options, etc. pp. to a command                                                                 |
| List(<sep>[,<sep\|type>..])	| \<sep\>-separated list, optionally recursively and/or sub-typing, e.g.: ``List(:,=,String)`` and ``"name=value:name2=value"``                |
| PkgName			| Single name of package                                                                                                                       |
| PkgRelation			| Single, possibly parametrised, package-package relation; see section [3.5](#35-package-package-and-packagegroup-group-relationships)         |
| PkgVersion			| Single version of package                                                                                                                    |
| Set(<type>)			| Set of alternatives of <type>, e.g. one of ``cross``, ``host``, ``native``                                                                   |
| String			| Semantically generic string                                                                                                                  |
| URL				| URL in standard format; see section [3.4](#34-package-archive-files-and-git-repositories)                                                    |
| URL(Git)			| Git URL in the format ``[subdir=]URL[@branch]``; see section [3.4](#34-package-archive-files-and-git-repositories)                           |

[//]: # "}}}"
[//]: # "{{{ 4.4.2 Package variables"
## 4.4.2 Package variables

| Package variable name        | Type             | Description                                                                                                                                |
| ---------------------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| AR                           | CmdName          | Toolchain library archive editor ``ar(1)``                                                                                                 |
| AUTOCONF_CONFIG_GUESS        | String           | Either of ``midipix`` (copy Midipix ``config.guess`` from ``etc/config.guess``) or ``keep``; defaults to ``midipix``                       |
| BASE_DIR                     | DirName(Abs)     | Package build root directory beneath ``${BUILD_WORKDIR}``                                                                                  |
| BUILD_DIR                    | DirName(Unit)    | Package build directory beneath ``${PKG_BASE_DIR}``                                                                                        |
| BUILD_STAGES_DISABLE         | List( )          | Build stages to disable during package build                                                                                               |
| BUILD_TYPE                   | Set(String)      | ``cross``: Cross-compiled toolchain, ``host``: host, ``native``: cross-compiled package                                                    |
| CC                           | FileName         | Toolchain C compiler ``cc(1)``                                                                                                             |
| CFLAGS_BUILD_EXTRA           | FlagLine         | Additional C compiler flags during package ``make(1)`` build                                                                               |
| CFLAGS_BUILD                 | FlagLine         | C compiler flags during package ``make(1)``  build                                                                                         |
| CFLAGS_CONFIGURE_EXTRA       | FlagLine         | Additional C compiler flags during package (GNU autotools in implementation and/or interface) configuration                                |
| CFLAGS_CONFIGURE             | FlagLine         | C compiler flags during package (GNU autotools in implementation and/or interface) configuration                                           |
| CMAKE_ARGS_EXTRA             | FlagLine         | Additional arguments to ``cmake(1)``                                                                                                       |
| CMAKE_ARGS                   | FlagLine         | Arguments to ``cmake(1)``                                                                                                                  |
| CMAKE                        | CmdName          | ``cmake(1)`` executable                                                                                                                    |
| CMAKE_LISTFILE               | FileName         | ``cmake(1)`` listfile                                                                                                                      |
| CONFIG_CACHE_EXTRA           | List(\n)         | Additional GNU autotools configuration cache variables                                                                                     |
| CONFIG_CACHE                 | List(\n)         | GNU autotools configuration cache variables                                                                                                |
| CONFIG_CACHE_LOCAL           | List(\n)         | Additional GNU autotools configuration cache variables                                                                                     |
| CONFIGURE_ARGS               | FlagLine         | Arguments to package (GNU autotools in implementation and/or interface) configuration script                                               |
| CONFIGURE_ARGS_EXTRA         | FlagLine         | Additional arguments to package (GNU autotools in implementation and/or interface) configuration script                                    |
| CONFIGURE_ARGS_LIST          | List(:)          | Arguments to package (GNU autotools in implementation and/or interface) configuration script                                               |
| CONFIGURE_ARGS_EXTRA_LIST    | List(:)          | Additional arguments to package (GNU autotools in implementation and/or interface) configuration script                                    |
| CONFIGURE                    | CmdName          | Package's (GNU autotools in implementation and/or interface) configuration script                                                          |
| CONFIGURE_TYPE               | String           | Either of ``autotools`` (GNU autotools or similar) or ``sofort`` or ``cmake`` (CMake)                                                      |
| CXX                          | CmdName          | Toolchain C++ compiler ``c++(1)``                                                                                                          |
| CXXFLAGS_CONFIGURE_EXTRA     | FlagLine         | Additional C++ compiler flags during package (GNU autotools in implementation and/or interface) configuration                              |
| CXXFLAGS_CONFIGURE           | FlagLine         | C++ compiler flags during package (GNU autotools in implementation and/or interface) configuration                                         |
| DEPENDS                      | List( )          | Mandatory package-package dependencies                                                                                                     |
| DESTDIR                      | DirName(Unit)    | Package installation destination directory beneath ``${PKG_BASE_DIR}``                                                                     |
| DESTDIR_HOST                 | DirName(Unit)    | Optional host package installation destination directory beneath ``${PKG_BASE_DIR}``                                                       |
| DISABLED                     | Flag(UInt,0)     | Disable package                                                                                                                            |
| ENV_VARS_EXTRA               | List(:,=)        | Name-value pairs of environment variables to set during package build                                                                      |
| FNAME                        | FileName(Unit)   | Filename of package archive file                                                                                                           |
| FORCE_AUTORECONF             | Flag(UInt,0)     | Forcibly run ``autoreconf -fiv`` prior to package (GNU autotools in implementation and/or interface) configuration                         |
| GITROOT                      | URL              | midipix packages Git URL prefix                                                                                                            |
| INHERIT_FROM                 | String           | Inherit variables from named package                                                                                                       |
| INSTALL_FILES_DESTDIR_EXTRA  | List( )          | Additional files to initialise the package installation destination directory beneath ``${PKG_BASE_DIR}`` with                             |
| INSTALL_FILES_DESTDIR        | List( )          | Files to initialise the package installation destination directory beneath ``${PKG_BASE_DIR}`` with                                        |
| INSTALL_FILES                | List( )          | Files to manually install into the package installation destination directory beneath ``${PKG_BASE_DIR}``                                  |
| INSTALL_FILES_V2             | List( )          | Files to manually install into the package installation destination directory beneath ``${PKG_BASE_DIR}``                                  |
| INSTALL_TARGET_EXTRA         | String           | Additional name of package build ``make(1)`` installation target                                                                           |
| INSTALL_TARGET               | String           | Name of package build ``make(1)`` installation target                                                                                      |
| IN_TREE                      | Flag(UInt,auto)  | Build package in-tree within ``${PKG_SUBDIR}``                                                                                             |
| LDFLAGS_BUILD_EXTRA          | FlagLine         | Additional linker flags during package ``make(1)``  build                                                                                  |
| LDFLAGS_CONFIGURE_EXTRA      | FlagLine         | Additional linker flags during package (GNU autotools in implementation and/or interface) configuration                                    |
| LDFLAGS_CONFIGURE            | FlagLine         | Linker flags during package (GNU autotools in implementation and/or interface) configuration                                               |
| LIBTOOL                      | CmdName          | ``libtool(1)`` implementation (defaults to ``slibtool``)                                                                                   |
| MAKE                         | CmdLine          | Command line of ``make(1)``                                                                                                                |
| MAKEFLAGS_BUILD              | FlagLine         | ``make(1)`` flags during package ``make(1)``  build; subject to field splitting w/ ``:``                                                   |
| MAKEFLAGS_BUILD_EXTRA        | FlagLine         | Additional ``make(1)`` flags during package ``make(1)``  build; subject to field splitting w/ ``:``                                        |
| MAKEFLAGS_BUILD_LIST         | List(:)          | ``make(1)`` flags during package ``make(1)``  build; subject to field splitting w/ ``:``                                                   |
| MAKEFLAGS_BUILD_EXTRA_LIST   | List(:)          | Additional ``make(1)`` flags during package ``make(1)``  build; subject to field splitting w/ ``:``                                        |
| MAKEFLAGS_INSTALL            | FlagLine         | ``make(1)`` flags during package ``make(1)``  installation; subject to field splitting w/ ``:``                                            |
| MAKEFLAGS_INSTALL_EXTRA      | FlagLine         | ``make(1)`` flags during package ``make(1)``  installation; subject to field splitting w/ ``:``                                            |
| MAKEFLAGS_INSTALL_LIST       | List(:)          | ``make(1)`` flags during package ``make(1)``  installation; subject to field splitting w/ ``:``                                            |
| MAKEFLAGS_INSTALL_EXTRA_LIST | List(:)          | ``make(1)`` flags during package ``make(1)``  installation; subject to field splitting w/ ``:``                                            |
| MAKEFLAGS_PARALLELISE        | FlagLine         | ``make(1)`` parallelisation (e.g. -l, -j) flags                                                                                            |
| MAKEFLAGS_VERBOSITY          | String           | Variable-value pair to pass to ``make(1)`` in order to force echo-back of command lines prior to execution                                 |
| MAKE_INSTALL_VNAME           | String           | Variable name of ``make(1)`` installation destination directory variable during package ``make(1)``  installation                          |
| MAKE_SUBDIRS                 | List( )          | ``make(1)`` subdirectories to exclusively build                                                                                            |
| MIRRORS_GIT                  | List( )          | Package Git repository mirror base URLs to attempt cloning from; cf. ``pkgtool.sh -m <dname>``                                             |
| MIRRORS                      | List( )          | Package archive mirror base URLs to attempt downloading from; cf. ``pkgtool.sh -m <dname>``                                                |
| NO_CLEAN_BASE_DIR            | Flag(UInt,0)     | Inhibit cleaning of package build root directory beneath ``${BUILD_WORKDIR}``                                                              |
| NO_CLEAN                     | Flag(UInt,0)     | Inhibit cleaning of package build directory beneath ``${PKG_BASE_DIR}`` pre-finish                                                         |
| NO_LOG_VARS                  | Flag(UInt,0)     | Inhibit logging of build & package variables pre-package build                                                                             |
| PATCHES_EXTRA                | List( )          | Additional patches to apply                                                                                                                |
| PKG_CONFIG                   | CmdName          | ``pkg-config(1)`` implementation                                                                                                           |
| PKG_CONFIG_LIBDIR            | DirName          | ``pkg-config(1)`` search directory                                                                                                         |
| PKGLIST_DISABLE              | Flag(UInt,0)     | Inhibit inclusion into ``${PREFIX}/pkglist.${PKG_BUILD_TYPE}``                                                                             |
| PREFIX                       | DirName(Abs)     | Top-level installation directory and package search path                                                                                   |
| PYTHON                       | CmdName          | Python >=3.x interpreter                                                                                                                   |
| RANLIB                       | CmdName          | Toolchain library archive index generator ``ranlib(1)``                                                                                    |
| RELATES                      | Set(PkgRelation) | Package-package relationships                                                                                                              |
| RPM_DISABLE                  | Flag(UInt,0)     | Inhibit creation of RPM archive                                                                                                            |
| SHA256SUM                    | String           | SHA-256 message digest of package archive                                                                                                  |
| SOFORT_NATIVE_CC             | FileName         | ``sofort`` variable during ``native`` build: Toolchain C compiler ``cc(1)``                                                                |
| SOFORT_NATIVE_CFLAGS_EXTRA   | FlagLine         | ``sofort`` variable during ``native`` build: Additional C compiler flags during package (GNU autotools or similar) configuration           |
| SOFORT_NATIVE_CFLAGS         | FlagLine         | ``sofort`` variable during ``native`` build: C compiler flags during package (GNU autotools or similar) configuration                      |
| SOFORT_NATIVE_CXXFLAGS_EXTRA | FlagLine         | ``sofort`` variable during ``native`` build: Additional list of C++ compiler flags during package (GNU autotools or similar) configuration |
| SOFORT_NATIVE_CXXFLAGS       | FlagLine         | ``sofort`` variable during ``native`` build: List of C++ compiler flags during package (GNU autotools or similar) configuration            |
| SOFORT_NATIVE_CXX            | FlagLine         | ``sofort`` variable during ``native`` build: Command- or pathname of toolchain C++ compiler ``c++(1)``                                     |
| SOFORT_NATIVE_LDFLAGS_EXTRA  | FlagLine         | ``sofort`` variable during ``native`` build: Additional linker flags during package (GNU autotools or similar) configuration               |
| SOFORT_NATIVE_LDFLAGS        | FlagLine         | ``sofort`` variable during ``native`` build: Linker flags during package (GNU autotools or similar) configuration                          |
| SOFORT_NATIVE_LD             | FileName         | ``sofort`` variable during ``native`` build: Command- or pathname of toolchain C compiler ``cc(1)``                                        |
| SUBDIR                       | DirName(Rel)     | Extracted archive or git-{clone,pull}(1)'d directory                                                                                       |
| TARGET                       | String           | Dash-separated {build,host,target} triplet                                                                                                 |
| URL                          | List( ,URL)      | URL to package archives w/ optional alternatives; see section [3.4](#34-package-archive-files-and-git-repositories)                        |
| URLS_GIT                     | List( ,URL(Git)) | Package Git URL(s) (format: ``[subdir=]URL[@branch]``, see section [3.4](#34-package-archive-files-and-git-repositories))                  |
| VARS_FILE                    | FileName         | Optional package variables file (defaults to ``vars/${PKG_NAME}.vars``)                                                                    |
| VERSION                      | PkgVersion       | Package version                                                                                                                            |

[//]: # "}}}"
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.5. Fault-tolerant & highly optimised 3D laser show-equipped usage screen"
## 4.5. Fault-tolerant & highly optimised 3D laser show-equipped usage screen

```
usage: ./build.sh [-a nt32|nt64]  [-b debug|release]    [-C dir[,..]]  [-D kind[,..]]
                  [-F ipv4|ipv6|offline]    [-h|--help] [-p jobs|-P]    [-r ALL|LAST]
                  [-r [*[*[*]]]name[,..][:ALL|LAST|[^|<|<=|>|>=]step,..]]        [-R]
                  [-v] [-V [+]tag|pat[,..]]

                  [--as-needed] [--ccache]  [--debug-minipix]  [--reset-state] [--roar]
                  [--theme theme] [[=]<group>|<variable name>=<variable override>[ ..]]

        -a nt32|nt64        Selects 32-bit or 64-bit architecture; defaults to nt64.
        -b debug|release    Selects debug or release build kind; defaults to debug.
        -C dir[,..]         Clean build directory (build,) ${PREFIX} before processing build
                            scripts (prefix,) source directory (src,) and/or destination
                            directory (dest) after successful package builds.
        -D kind[,..]        Produce minimal midipix distribution directory (minipix,) RPM
                            binary packages (rpm,) and/or deployable distribution ZIP
                            archive (zipdist.) zipdist implies minipix.
        -F ipv4|ipv6|offline
                            Force IPv4 (ipv4) or IPv6 (ipv6) when downloading package
                            archives and/or Git repositories or don't download either at all
                            (offline.)
        -h|--help           Show short/full help screen, respectively.
        -p jobs|-P          Enables parallelisation at group-level, whenever applicable.
                            The maximum count of jobs defaults to the number of logical
                            processors on the host system divided by two (2.)

                            If -R is not specified and at least one (1) package fails to
                            build, all remaining package builds will be forcibly aborted.

        -r ALL|LAST         Restart all packages or the last failed package and resume
                            build, resp.
        -r [*[*[*]]]name[,..][:ALL|LAST|[^|<|<=|>|>=]step,..]
                            Restart the specified comma-separated package(s) w/ inhibition
                            of package build step state resetting completely (`ALL',) starting
                            at the resp. last successfully executed build steps (`LAST',) or the
                            specified comma-separated list of build steps, optionally subject
                            concerning package name(s) and/or build step(s) to the below modifiers:

                            Prepend name w/ `*' to automatically include dependencies, `**'
                            to forcibly rebuild all dependencies, and `***' to forcibly
                            rebuild all packages that depend on the specified package(s).

                            Prepend step w/ `^' to filter build steps with, `<' or `<='
                            to constrain build steps to below or below or equal with, resp.,
                            `>' or `>=' to constrain build steps to above or above or equal
                            with, resp.

                            Currently defined build steps are:
                            fetch_clean, fetch_download, fetch_extract, configure_clean,
                            configure_patch_pre, configure_autotools, configure_patch,
                            configure, build_clean, build, install_clean, install_subdirs,
                            install_make, install_files, install_libs, install, install_rpm,
                            and clean.

                            Additionally, the following virtual steps are provided:
                            @fetch, @configure, @build, @install, @clean, and finish.

        -R                  Ignore build failures, skip printing package logs, and continue
                            building (relaxed mode.)

        -v                  Increase logging verbosity.
        -V [+]tag|pat[,..]  Enable logging for messages with tag or pattern matching tags of:
                            + (prefix)..: initialise tags with normal verbosity (implies normal) (see etc/build.theme,)
                            all.........: log everything (see etc/build.theme,)
                            clear|none..: log nothing,
                            normal......: log at normal verbosity (see etc/build.theme,)
                            verbose.....: log at increased verbosity (implies normal) (see etc/build.theme) (-v,)

                            build.......: log package build logs,
                            fileops.....: log RTL file operations,
                            install.....: log RTL installation DSL operations,
                            zipdist.....: log deployable distribution ZIP archive operations,
                            xtrace......: set xtrace during package builds,

                            fatal.......: fatal, unrecoverable errors,
                            info........: informational messages,
                            verbose.....: verbose informational messages,
                            warning.....: warning messages possibly relating to imminent fatal, unrecoverable errors,

                            build_*.....: general build messages (viz.: begin, finish, finish_time, vars,)
                            group_*.....: build group messages (viz.: begin, finish,)
                            pkg_*.......: package build messages (viz.: begin, finish, msg, skip, step, strip.)

        --as-needed         Don't build unless the midipix_build repository has received
                            new commits.
        --ccache            Build w/ ccache(1) in $PATH.
        --debug-minipix     Don't strip(1) minipix binaries to facilitate debugging minipix.
        --reset-state       Reset package build step state on exit.
        --theme theme       Set theme.

        <group>[ ..]        One of: dev_packages, dist, host_deps, host_deps_rpm,
                            host_toolchain, host_tools, minipix, native_packages,
                            native_runtime, native_toolchain, native_tools.

                            Prepend w/ `=' to inhibit group-group dependency expansion.

        <variable name>=<variable override>[ ..]
                            Override build or package variable.
```
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.6. ``pkgtool.sh``"
## 4.6. ``pkgtool.sh``

```
usage: ./pkgtool.sh [-a nt32|nt64] [-b debug|release] [-i|-m <dname> -M <dname>|-p|-r|-R|-t]
                    [--theme theme] [-v]
                    [<variable name>=<variable override>[ ..]] name

        -a nt32|nt64      Selects 32-bit or 64-bit architecture; defaults to nt64.
        -b debug|release  Selects debug or release build kind; defaults to debug.
        -i                List package variables and dependencies of single named package.
        -m <dname>        Setup package archives mirror in <dname> and/or
        -M <dname>        Setup Git repositories mirror in <dname>
                          Specify "" or '' as <dname> to default to the defaults in
                          ${HOME}/pkgtool.vars, if present.
        -p <log_fname>    Profile last build.
        -r                List reverse dependencies of single named package.
        -R                List recursive reverse dependencies of single named package.
        -t                Produce tarball of package build root directory and build log
                          file for the purpose of distribution given build failure.
        -v                Increase verbosity.

        <variable name>=<variable override>[ ..]
                          Override build or package variable.
```
  
> N.B. When using ``pkgtool.sh`` on a build w/ build variables (see section [4.2](#42-build-variables))
overriden on the command line or via the environment, ensure that they are included in the
``pkgtool.sh`` command line, preceding the package name, or exported, respectively.  
  
> N.B. ``pkgtool.sh`` will source the ``${HOME}/pkgtool.vars`` file, if present, on startup where the
following option arguments may be set: ``-a nt32|nt64`` by setting ``ARCH=...``, ``-b debug|release``
by setting ``BUILD_KIND=...``, ``-m <dname>`` by setting ``ARG_MIRROR_DNAME=...``, and ``-M <dname>``
by setting ``ARG_MIRROR_DNAME_GIT=...``.  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
[//]: # "{{{ 4.7. Bourne shell coding rules"
## 4.7. Bourne shell coding rules

If no rationale is specified for any specific point, the rationale is avoidance of undefined behaviour
and/or implicit behaviour contingent on often subtle special cases, both of which are prone to cause
hard to debug or even diagnose bugs.

### Shell options

1)  The `noglob` option is set at all times *except* for when globbing is required, e.g.:
    `set +o noglob; files=*; set -o noglob`
2)  The `nounset` option is set at all times; if a parameter is to be expanded that may be
    unset, use the `${parameter:-word}` expansion format.
3)  The `errexit` option is unset at all times *except* for top-level subshell code that does
    *not* engage in conditional evaluation, e.g. `([...] set -o errexit; [...]) &` due to its
    implicit unsetting when a/any function is subject to conditional evaluation, e.g.: `[...]
    set -o errexit; [...] if some_function; then [ ... ] fi`

### Quoting and brace-enclosing

4)  Quoting with single quotes or double quotes is mandatory at all times *except* for when field 
    splitting subsequent to parameter expansion, etc. is required, e.g.: `params="a b c";
    param="single parameter"; fn ${params} "${param}"`
5)  Enclosing parameter names in braces is mandatory at all times, e.g.: `${parameter_name123}`

### Checking parameter status

6)  Checking for whether a parameter is set/non-empty or unset/empty is expressed with the following
    the idiom: `[ "${parameter:+1}" = 1 ]` and `[ "${parameter:+1}" != 1 ]` 
  
    This is necessary to avoid the potentially costly expansion of a parameter's value when only its
    status of being set/non-empty or unset/empty is of concern, particularly when this is done repeatedly.

### Functions

7)  Functions must explicitly return either `0` or `1` at all times *except* for when specific
    return exit statuses are specified according to the function's interface contract.
8)  Function names must have namespace prefixes followed by a `p` in the topmost namespace prefix
    field in private functions, e.g.: `rtlp_log_do_something() { [...] }`
9)  The non-POSIX but extremely widely available `local` command must be used at at all times
    in functions on all function-local variables.  
  
    This is necessary in order to avoid polluting the (global) parameter namespace.
10) Function-local variables must be lower case and prefixed with a `_`, a prefix comprised of the
    initial letters of each word in the function's name plus, in private functions, the `p` topmost
    namespace prefix field postfix, and a `_`, where words are separated by `_` characters, e.g.:
    `rtlp_log_do_something() { local _rplds_parameter=""; [...] }` and `ex_something() {
    local _es_parameter=""; [ ...] }` 
  
    This is necessary in order to prevent implicit conflicts between two or more functions that share
    a call path and would otherwise use the same variables names, such as `function1() { local
    list="${1}"; function2 "${list}"; }; function2() { local list="${2}"; }`, particularly when those
    functions acess and/or mutate each other's variables. Additionally, local variables are thus marked
    with a `_` prefix and by being lower case.

### `eval` rules

11) The following special characters must be escaped with a backslash at all times in `eval`
    expressions: `<newline>`, `"`, `'`, `[`, `\`, `]`, `<backtick>`, `$`
12) If parameter expansion is to be evaluated with respect to a parameter reference, the following idiom
    must be used at all times: `eval [...]\${${rparameter[...]}}`
13) If quoting with single quotes or double quotes is required - see 4) - or brace-enclosing - see 5) -
    and with respect to 11), viz. the single quotes or double quotes have been escaped with a backslash,
    something must be evaluated as a single field, then that field must be doubly quoted with single or
    double quotes, where the second set of quotes must not be escaped with a backslash, e.g.: `
    rparameter=parameter; eval ${rparameter}="\"a b c\""`. 
    This is very rarely required.

### Passing arguments

14) The `fork/exec/write`-`read` pattern where a parameter is set to the result of a command
    substitution expression which is executed in a subshell process, e.g.: `parameter="$(function)"`
    is prohibited at all times *except* when an actual external command is invoked, e.g. `sort(1)`
    or `sed(1)`.  
  
    This is necessary due to the very significant cost of the mentioned pattern, particularly concerning
    primitive e.g. list or string processing functions with high contention.
15) If a function is to return, produce, evaluate to, etc. an arbitrary value apart from the exit status,
    it shall do so by receiving references to the target variables in the callers' scope from the caller
    prefixed with a single `$` character, e.g. `function \$parameter` and `function() {
    local _fn_rparameter="${1#\$}"; [..]; }` which are then set with `eval` expressions: `
    function() { local _fn_rparameter="${1#\$}"; [...]; eval ${_fn_rparameter}=\'a b c\'; };` Refer to
    11)-13) for the rules concerning `eval`.  

    This is necessary due to 14) as well as the absence of any other calling convention other than using
    implicit global variables, e.g.: `function1() { VARIABLE=; function2; }; function2() { VARIABLE=1;
    }`
  
[Back to top](#table-of-contents)

[//]: # "}}}"

[//]: # "{{{ 5. References"
## 5. References

* ``Sun, 25 Apr 2016 09:04:08 +0000 [1]``<a href="https://www.musl-libc.org/faq.html" id="r1">musl FAQ</a>  
* ``Wed, 04 Mar 2020 13:36:19 +0000 [2]``<a href="https://midipix.org/#sec-midipix" id="r2">midipix - what is midipix, and how is it different?</a>  
* ``Wed, 29 Apr 2020 23:33:34 +0100 [3]``<a href="https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/user-rights-assignment" id="r3">User Rights Assignment (Windows 10) - Windows security | Microsoft Docs</a>  
* ``Wed, 29 Apr 2020 23:33:50 +0100 [4]``<a href="https://docs.microsoft.com/en-us/previous-versions/dotnet/articles/bb530410%28v%3dmsdn%2e10%29" id="r4">Windows Vista Application Development Requirements for User Account Control Compatibility | Microsoft Docs</a>  
  
[Back to top](#table-of-contents)

[//]: # "}}}"
  
[modeline]: # ( vim: set ff=dos tw=0: )
