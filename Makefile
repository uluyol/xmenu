VERSION = 1.0
CC ?= clang
CFLAGS ?= -Wall -O2
BUILD_FLAGS := -fmodules -DXMENU_VERSION=\"${VERSION}\"
OBJS = draw.o items.o main.o util.o view.o
BINS = xmenu xmenu_path xmenu_run
PREFIX = /usr/local

.PHONY: all clean install fmt

install: all bindir $(addprefix $(PREFIX)/bin/,$(BINS))

bindir:
	@install -m755 -d $(PREFIX)/bin

$(PREFIX)/bin/%: %
	@echo " INSTALL" $@
	@install -m 755 $< $@

all: xmenu

xmenu: $(OBJS)
	@echo " CC     " xmenu
	@$(CC) $(CFLAGS) $(BUILD_FLAGS) -o xmenu $(OBJS) -framework Cocoa

.c.o .m.o:
	@echo " CC     " $<
	@$(CC) $(CFLAGS) $(BUILD_FLAGS) -c $<

clean:
	rm -f $(OBJS) xmenu

fmt:
	@echo " FMT    " *.c *.h *.m
	@clang-format -style=file -i *.c *.h *.m
