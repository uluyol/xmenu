VERSION = 1.0
CC ?= clang
CFLAGS ?= -Wall -O2
BUILD_FLAGS := -fmodules -DXMENU_VERSION=\"${VERSION}\" -Isrc/include
OBJS = \
	src/xmenu/draw.o \
	src/xmenu/items.o \
	src/xmenu/main.o \
	src/xmenu/util.o \
	src/xmenu/view.o
HIST_OBJS = src/lib/history.o

BINS = xmenu xpassmenu run_hist update_hist xmenu_path xmenu_run xmenu_apps_path xmenu_combined_run
PREFIX = /usr/local

.PHONY: all clean install fmt

install: all bindir $(addprefix $(PREFIX)/bin/,$(BINS))

bindir:
	@install -m755 -d $(PREFIX)/bin

$(PREFIX)/bin/%: bin/%
	@echo " INSTALL" $@
	@install -m 755 $< $@

all: $(addprefix bin/,$(BINS))

bin/xmenu: $(OBJS)
	@echo " CC     " bin/xmenu
	@$(CC) $(CFLAGS) $(BUILD_FLAGS) -o bin/xmenu $(OBJS) -framework Cocoa

bin/run_hist: src/run_hist/*.c $(HIST_OBJS)
	@echo " CC     " bin/run_hist
	@$(CC) $(CFLAGS) $(BUILD_FLAGS) -o bin/run_hist $^

.c.o .m.o:
	@echo " CC     " $@
	@$(CC) $(CFLAGS) $(BUILD_FLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(HIST_OBJS) bin/xmenu bin/run_hist

fmt:
	@echo " FMT    " src/*/*.c src/*/*.h src/*/*.m
	@clang-format -style=file -i src/*/*.c src/*/*.h src/*/*.m
