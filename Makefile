# makefile for POSIX library for Lua

# change these to reflect your Lua installation
PREFIX=		/usr/local
LUAVERSION=	5.1
LUAINC= 	$(PREFIX)/include
LUALIB= 	$(PREFIX)/lib/lua/$(LUAVERSION)
LUABIN= 	$(PREFIX)/bin

# other executables
LUA=		lua
INSTALL=	install

# no need to change anything below here
PACKAGE=	luaposix
LIBVERSION=	7
RELEASE=	$(LUAVERSION).$(LIBVERSION)

GIT_REV		:= $(shell test -d .git && git describe --always)
ifeq ($(GIT_REV),)
FULL_VERSION	:= $(RELEASE)
else
FULL_VERSION	:= $(GIT_REV)
endif

WARN=		-pedantic -Wall
INCS=		-I$(LUAINC)
CFLAGS+=	-fPIC $(INCS) $(WARN) -DVERSION=\"$(FULL_VERSION)\" -D_XOPEN_SOURCE=700

MYNAME=		posix
MYLIB= 		$(MYNAME)

OBJS=		l$(MYLIB).o

T= 		$(MYLIB).so

OS=$(shell uname)
ifeq ($(OS),Darwin)
  LDFLAGS_SHARED=-bundle -undefined dynamic_lookup
  LIBS=
else
  LDFLAGS_SHARED=-shared
  LIBS=-lcrypt -lrt
endif

# targets
all:	$T

test:	all
	$(LUA) test.lua

$T:	$(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(LDFLAGS_SHARED) $(OBJS) $(LIBS)

tree:	$T
	$(LUA) -l$(MYNAME) tree.lua .

clean:
	rm -f $(OBJS) $T core core.* a.out $(TARGZ)

install: $T
	$(INSTALL) -D $T $(DESTDIR)/$(LUALIB)/$T

show-funcs:
	@echo "$(MYNAME) library:"
	@fgrep '/**' l$(MYLIB).c | cut -f2 -d/ | tr -d '*' | sort

# eof
