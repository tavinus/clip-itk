#	Created automatically by configure
#

#
#	Compile flags
#
CLIPROOT=/home/tavinus/src/clip-estiloinfo-git/cliproot
include /home/tavinus/src/clip-estiloinfo-git/cliproot/include/Makefile.inc
OSNAME=LINUX
COMPILER=gcc
DLLSUFF=.so
DLLREALSUFF=.so
INCLUDEDIRS=-I. -I$(CLIPROOT)/include -I/usr/include -I/include
XTARGETS=$(XLIB) $(XSLIB)
C_FLAGS=-Wall -Wextra $(INCLUDEDIRS) 
LIBS=-L/usr/lib64 -lgtk -lgdk -rdynamic -lgmodule -ldl -lglib -lXi -lXext -lX11 -lm
XCFLAGS=-I/usr/include/gtk-1.2 -I/usr/include/glib-1.2 -I/usr/lib64/glib/include

# main part
#
#

#export CC
#DBGFLAGS	= -g #-DMEMDBG
#WARNFLAGS	= -Wimplicit -Wall -Wextra

.SUFFIXES: .prg .c .po
.PHONY:	tests screen hash

SRCS  = sheet.c fontcombo.c bordercombo.c colorcombo.c togglecombo.c \
	combobox.c itementry.c

OBJS  = sheet.o fontcombo.o bordercombo.o colorcombo.o togglecombo.o \
	combobox.o itementry.o

HDRS	= clip-gtkextra.ch clip-gtkextra.h ../clip-gtk/clip-gtk.ch

OBJDIR	= .
EXTOBJS =

HASHSRCS = $(SRCS) $(HDRS)

XLIB	= libclip-gtkextra.a
XSLIB	= libclip-gtkextra$(DLLSUFF)
XSLIBREAL = libclip-gtkextra$(DLLREALSUFF)
XLIBOBJS= $(OBJS)

SYS = $OSNAME
SYSTEM_NAME = $(OSNAME)

DEFS	=
# -DVERSION=\"0.1\"
# -DSYSTEM=\"$(SYSTEM_NAME)\"

CC = $(COMPILER)
CFLAGS  = $(C_FLAGS) $(DEFS) $(MEMDBGFLAGS) -I../clip-gtk
#  $(WARNFLAGS) $(DBGFLAGS) $(OPTFLAGS) -I$(INCLUDE)

export CC CFLAGS
export MEMDBG MEMDBGFLAGS

all: Makefile hash $(XTARGETS)

d: set_dbg

set_dbg: CDBGFLAGS=-g
set_dbg: all

Makefile: Makefile.in configure
	./configure

hash: _hashcode.h

_hashcode.h: $(HASHSRCS)
	$(CLIPROOT)/bin/clip_hashextract $(HASHSRCS) | sort -u > _hashcode.h
	cmp _hashcode.h hashcode.h 2>/dev/null || cp _hashcode.h hashcode.h

$(XLIB): $(XLIBOBJS)
	rm -f $(XLIB)
	$(CLIPROOT)/bin/clip_makelib $(XLIB) $(XLIBOBJS)
	ranlib $(XLIB)

$(XSLIB): $(XLIB)
	$(CLIPROOT)/bin/clip_makeslib $(XSLIB) $(XLIB) $(LIBS)

test: install
	cd example && $(MAKE)

clean:
	rm -rf *.o *.a *.so *.dll *.po *.pa *.b *.BAK *.bak *~ core* \
	*core Makefile.inc _hashcode.h *.ex *.nm

distclean: clean
	rm -rf clip-gtkextracfg.h hashcode.h _hashcode.h Makefile
	cd example && $(MAKE) clean

install: $(XTARGETS)
	$(CLIPROOT)/bin/clip_cp $(XLIB) $(XSLIB) $(DESTDIR)$(CLIPROOT)/lib
	chmod 0644  $(DESTDIR)$(CLIPROOT)/lib/$(XLIB)
	chmod 0755  $(DESTDIR)$(CLIPROOT)/lib/$(XSLIB)
	#[ "$(XSLIBREAL)" = "$(XSLIB)" ] || cp $(XSLIBREAL) $(DESTDIR)$(CLIPROOT)/lib
	cp clip-gtkextra.ch $(DESTDIR)$(CLIPROOT)/include/
#	cp -R doc/* $(CLIPROOT)/doc/clip-gtk
	mkdir -p $(DESTDIR)$(CLIPROOT)/doc/example/clip-gtkextra
	- cp example/*.prg example/Makefile example/*.ch $(DESTDIR)$(CLIPROOT)/doc/example/clip-gtkextra

.c.o:
	@echo $(CC) $(CDBGFLAGS) $(CFLAGS) -c $<
	@$(CC) $(CDBGFLAGS) $(CFLAGS) $(XCFLAGS) -c $<

depend:
	$(MAKE) hash
	makedepend -Y  -- $(CFLAGS) -- $(SRCS) 2>/dev/null

# DO NOT DELETE



