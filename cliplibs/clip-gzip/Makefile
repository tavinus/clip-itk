ifndef CLIPROOT
	CLIPROOT=$(shell cd ../../../; pwd)/cliproot
endif

include $(CLIPROOT)/include/Makefile.inc

TARGET=libclip-gzip$(DLLSUFF)
ATARGET=libclip-gzip.a
RTARGET=libclip-gzip$(DLLREALSUFF)
OBJS=gzip.o
LIBS=-lz $(C_LIBS)
CFLAGS=$(C_FLAGS) -fPIC

all:	$(TARGET) $(ATARGET)

$(TARGET): $(OBJS)
	$(CLIPROOT)/bin/clip_makeslib $(TARGET) $(OBJS) $(LIBS)

$(ATARGET): $(OBJS)
	$(CLIPROOT)/bin/clip_makelib $(ATARGET) $(OBJS) $(LIBS)

gzip.o: gzip.c hashcode.h
	$(CC) $(CFLAGS) -c gzip.c

hashcode.h:
	echo '#define HASH_ferror ' $$(echo ferror| $(CLIPROOT)/bin/cliphash | cut -d' ' -f2) >hashcode.h

install:
	$(CLIPROOT)/bin/clip_cp libclip-gzip $(DESTDIR)$(CLIPROOT)/lib
	#mkdir -p $(CLIPROOT)/doc/clip-gzip
	#cp *.html $(CLIPROOT)/doc/clip-gzip
	#-cd tdoc && $(MAKE) install
	mkdir -p $(DESTDIR)$(CLIPROOT)/doc/example/clip-gzip
	cp -R example/* $(DESTDIR)$(CLIPROOT)/doc/example/clip-gzip/

clean:
	rm -rf *.o *.bak *.a *.so hashcode.h *.dll *.exe *.ex *.nm
	cd example && $(MAKE) clean
	#-cd tdoc && make clean

distclean: clean
	#-cd tdoc && make distclean
