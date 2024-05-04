bin_PROGRAMS = \
mandoc \
demandoc \
soelim

man1_MANS = apropos.1 demandoc.1 man.1 mandoc.1 soelim.1
man5_MANS = man.conf.5 mandoc.db.5
man7_MANS = eqn.7 man.7 mandoc_char.7 mdoc.7 roff.7 tbl.7
man8_MANS = makewhatis.8

install-exec-hook:
	cd $(DESTDIR)$(bindir) && \
	$(MKDIR_P) $(DESTDIR)$(sbindir) && \
	$(LN_S) -f mandoc$(EXEEXT) man$(EXEEXT) && \
	$(LN_S) -f mandoc$(EXEEXT) apropos$(EXEEXT) && \
	$(LN_S) -f mandoc$(EXEEXT) whatis$(EXEEXT) && \
	cp mandoc$(EXEEXT) ../sbin/makewhatis$(EXEEXT)

install-data-hook:
	cd $(DESTDIR)$(mandir)/man1 && \
	$(LN_S) -f apropos.1 whatis.1

noinst_LIBRARIES = libmandoc.a libcompat.a

libmandoc_a_SOURCES = \
man.c \
man_macro.c \
man_validate.c \
att.c \
lib.c \
mdoc.c \
mdoc_argv.c \
mdoc_macro.c \
mdoc_state.c \
mdoc_validate.c \
st.c \
eqn.c \
roff.c \
roff_validate.c \
tbl.c \
tbl_data.c \
tbl_layout.c \
tbl_opts.c \
arch.c \
chars.c \
mandoc.c \
mandoc_aux.c \
mandoc_msg.c \
mandoc_ohash.c \
mandoc_xr.c \
msec.c \
preconv.c \
read.c \
tag.c

libcompat_a_SOURCES = 
if NEED_ERR_COMPAT
libcompat_a_SOURCES += compat_err.c
endif
if NEED_GETSUBOPT_COMPAT
libcompat_a_SOURCES += compat_getsubopt.c
endif
if NEED_MKSTEMPS_COMPAT
libcompat_a_SOURCES += compat_mkstemps.c
endif
if NEED_REALLOCARRAY_COMPAT
libcompat_a_SOURCES += compat_reallocarray.c
endif
if NEED_STRINGLIST_COMPAT
libcompat_a_SOURCES += compat_stringlist.c
endif
if NEED_STRNDUP_COMPAT
libcompat_a_SOURCES += compat_strndup.c
endif
if NEED_VASPRINTF_COMPAT
libcompat_a_SOURCES += compat_vasprintf.c
endif
if NEED_FTS_COMPAT
libcompat_a_SOURCES += compat_fts.c
endif
if NEED_ISBLANK_COMPAT
libcompat_a_SOURCES += compat_isblank.c
endif
if NEED_OHASH_COMPAT
libcompat_a_SOURCES += compat_ohash.c
endif
if NEED_RECALLOCARRAY_COMPAT
libcompat_a_SOURCES += compat_recallocarray.c
endif
if NEED_STRLCAT_COMPAT
libcompat_a_SOURCES += compat_strlcat.c
endif
if NEED_STRSEP_COMPAT
libcompat_a_SOURCES += compat_strsep.c
endif
if NEED_GETLINE_COMPAT
libcompat_a_SOURCES += compat_getline.c
endif
if NEED_MKDTEMP_COMPAT
libcompat_a_SOURCES += compat_mkdtemp.c
endif
if NEED_PROGNAME_COMPAT
libcompat_a_SOURCES += compat_progname.c
endif
if NEED_STRCASESTR_COMPAT
libcompat_a_SOURCES += compat_strcasestr.c
endif
if NEED_STRLCPY_COMPAT
libcompat_a_SOURCES += compat_strlcpy.c
endif
if NEED_STRTONUM_COMPAT
libcompat_a_SOURCES += compat_strtonum.c
endif

mandoc_SOURCES = \
eqn_html.c \
html.c \
man_html.c \
mdoc_html.c \
roff_html.c \
tbl_html.c \
eqn_term.c \
man_term.c \
mdoc_term.c \
roff_term.c \
term.c \
term_ascii.c \
term_ps.c \
term_tab.c \
term_tag.c \
tbl_term.c \
dbm.c \
dbm_map.c \
mansearch.c \
dba.c \
dba_array.c \
dba_read.c \
dba_write.c \
mandocdb.c \
main.c \
manpath.c \
mdoc_man.c \
mdoc_markdown.c \
out.c \
tree.c
mandoc_LDADD = libmandoc.a libcompat.a -lz

demandoc_SOURCES = \
demandoc.c
demandoc_LDADD = libmandoc.a libcompat.a -lz

soelim_SOURCES = \
soelim.c
soelim_LDADD = libcompat.a
