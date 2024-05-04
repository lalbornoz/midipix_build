#include <stdio.h>
#include <sys/types.h>
#include <stdarg.h>

#define OSENUM MANDOC_OS_OTHER
#define OSNAME "Midipix"
#define UTF8_LOCALE "en_US.UTF-8"

#define MAN_CONF_FILE "/etc/man.conf"
#define MANPATH_BASE "/usr/share/man:/usr/X11R6/man"
#define MANPATH_DEFAULT "/usr/share/man"
#define BINM_MAN "man"
#define BINM_SOELIN "soelim"
#define BINM_WHATIS "whatis"
#define BINM_CATMAN "catman"
#define BINM_MAKEWHATIS "makewhatis"
#define BINM_APROPOS "apropos"
#define BINM_PAGER "less"

#ifndef HAVE_ERR
extern    void      err(int, const char *, ...);
extern    void      errx(int, const char *, ...);
extern    void      warn(const char *, ...);
extern    void      warnx(const char *, ...);
#endif
#ifndef HAVE_GETLINE
extern    ssize_t   getline(char **, size_t *, FILE *);
#endif
#ifndef HAVE_GETSUBOPT
extern    int       getsubopt(char **, char * const *, char **);
#endif
#ifndef HAVE_ISBLANK
extern    int       isblank(int);
#endif
#ifndef HAVE_MKDTEMP
extern    char     *mkdtemp(char *);
#endif
#ifndef HAVE_MKSTEMPS
extern    int       mkstemps(char *, int);
#endif
#ifndef HAVE_GETPROGNAME
extern    const char *getprogname(void);
#endif
#ifndef HAVE_SETPROGNAME
extern    void      setprogname(const char *);
#endif
#ifndef HAVE_REALLOCARRAY
extern    void     *reallocarray(void *, size_t, size_t);
#endif
#ifndef HAVE_RECALLOCARRAY
extern    void     *recallocarray(void *, size_t, size_t, size_t);
#endif
#ifndef HAVE_STRCASESTR
extern    char     *strcasestr(const char *, const char *);
#endif
#ifndef HAVE_STRLCAT
extern    size_t    strlcat(char *, const char *, size_t);
#endif
#ifndef HAVE_STRLCPY
extern    size_t    strlcpy(char *, const char *, size_t);
#endif
#ifndef HAVE_STRNDUP
extern    char     *strndup(const char *, size_t);
#endif
#ifndef HAVE_STRSEP
extern    char     *strsep(char **, const char *);
#endif
#ifndef HAVE_STRTONUM
extern    long long strtonum(const char *, long long, long long, const char **);
#endif
#ifndef HAVE_VASPRINTF
extern    int       vasprintf(char **, const char *, va_list);
#endif
