AC_INIT([mandoc], [1.14.6])
AC_CONFIG_AUX_DIR([build-aux])
AM_INIT_AUTOMAKE([foreign])
AH_TOP([#define _GNU_SOURCE])
AH_BOTTOM([#include <extern_config.h>])
AC_CONFIG_HEADERS([config.h])
AM_PROG_AR
AC_PROG_CC
AC_PROG_RANLIB
AC_PROG_LN_S

AC_CHECK_HEADER([endian.h], [AC_DEFINE([HAVE_ENDIAN], [1], [Define to 1 if you have the <endian.h> header file.])], [])
AC_CHECK_HEADER([sys/endian.h], [AC_DEFINE([HAVE_SYS_ENDIAN], [1], [Define to 1 if you have the <sys/endian.h> header file.])], [])

have_EFTYPE=no
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([#include <errno.h>
],[
#ifndef EFTYPE
#error notfound
#endif
])], [have_EFTYPE=yes])

if test "x$have_EFTYPE" = "xno"; then
  AC_DEFINE([EFTYPE], [EINVAL], [Define EFTYPE to EINVAL if it does not exist.])
fi

#
# Thanks OpenBSD. Guarding each compat file with an include macro is too hard .....
#
have_err=no
have_stringlist=no
have_vasprintf=no
have_isblank=no
have_ohash=no
have_recallocarray=no
have_getline=no
have_mkdtemp=no
have_progname=no
have_getsubopt=no
have_mkstemps=no
have_reallocarray=no
have_strndup=no
have_strlcat=no
have_strlcpy=no
have_strsep=no
have_strcasestr=no
have_strtonum=no
have_fts=no
AC_CHECK_FUNC([err], [have_err=yes], [have_err=no])
AC_CHECK_FUNC([stringlist], [have_stringlist=yes], [have_stringlist=no])
AC_CHECK_FUNC([vasprintf], [have_vasprintf=yes], [have_vasprintf=no])
AC_CHECK_FUNC([isblank], [have_isblank=yes], [have_isblank=no])
AC_CHECK_FUNC([ohash], [have_ohash=yes], [have_ohash=no])
AC_CHECK_FUNC([recallocarray], [have_recallocarray=yes], [have_recallocarray=no])
AC_CHECK_FUNC([getline], [have_getline=yes], [have_getline=no])
AC_CHECK_FUNC([mkdtemp], [have_mkdtemp=yes], [have_mkdtemp=no])
AC_CHECK_FUNC([progname], [have_progname=yes], [have_progname=no])
AC_CHECK_FUNC([getsubopt], [have_getsubopt=yes], [have_getsubopt=no])
AC_CHECK_FUNC([mkstemps], [have_mkstemps=yes], [have_mkstemps=no])
AC_CHECK_FUNC([reallocarray], [have_reallocarray=yes], [have_reallocarray=no])
AC_CHECK_FUNC([strndup], [have_strndup=yes], [have_strndup=no])
AC_CHECK_FUNC([strlcat], [have_strlcat=yes], [have_strlcat=no])
AC_CHECK_FUNC([strlcpy], [have_strlcpy=yes], [have_strlcpy=no])
AC_CHECK_FUNC([strsep], [have_strsep=yes], [have_strsep=no])
AC_CHECK_FUNC([strcasestr], [have_strcasestr=yes], [have_strcasestr=no])
AC_CHECK_FUNC([strtonum], [have_strtonum=yes], [have_strtonum=no])
AC_CHECK_FUNC([fts_open], [have_fts=yes], [have_fts=no])

AM_CONDITIONAL([NEED_ERR_COMPAT], [test "x$have_err" != "xyes"])
AM_CONDITIONAL([NEED_STRINGLIST_COMPAT], [test "x$have_stringlist" != "xyes"])
AM_CONDITIONAL([NEED_VASPRINTF_COMPAT], [test "x$have_vasprintf" != "xyes"])
AM_CONDITIONAL([NEED_ISBLANK_COMPAT], [test "x$have_isblank" != "xyes"])
AM_CONDITIONAL([NEED_OHASH_COMPAT], [test "x$have_ohash" != "xyes"])
AM_CONDITIONAL([NEED_RECALLOCARRAY_COMPAT], [test "x$have_recallocarray" != "xyes"])
AM_CONDITIONAL([NEED_GETLINE_COMPAT], [test "x$have_getline" != "xyes"])
AM_CONDITIONAL([NEED_MKDTEMP_COMPAT], [test "x$have_mkdtemp" != "xyes"])
AM_CONDITIONAL([NEED_PROGNAME_COMPAT], [test "x$have_progname" != "xyes"])
AM_CONDITIONAL([NEED_GETSUBOPT_COMPAT], [test "x$have_getsubopt" != "xyes"])
AM_CONDITIONAL([NEED_MKSTEMPS_COMPAT], [test "x$have_mkstemps" != "xyes"])
AM_CONDITIONAL([NEED_REALLOCARRAY_COMPAT], [test "x$have_reallocarray" != "xyes"])
AM_CONDITIONAL([NEED_STRNDUP_COMPAT], [test "x$have_strndup" != "xyes"])
AM_CONDITIONAL([NEED_STRLCAT_COMPAT], [test "x$have_strlcat" != "xyes"])
AM_CONDITIONAL([NEED_STRLCPY_COMPAT], [test "x$have_strlcpy" != "xyes"])
AM_CONDITIONAL([NEED_STRSEP_COMPAT], [test "x$have_strsep" != "xyes"])
AM_CONDITIONAL([NEED_STRCASESTR_COMPAT], [test "x$have_strcasestr" != "xyes"])
AM_CONDITIONAL([NEED_STRTONUM_COMPAT], [test "x$have_strtonum" != "xyes"])
AM_CONDITIONAL([NEED_FTS_COMPAT], [test "x$have_fts" != "xyes"])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
