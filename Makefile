CC = clang
CFLAGS ?= -Wall -O2
OBJS = draw.o items.o main.o util.o view.o

.PHONY: all clean

all: xmenu

xmenu: $(OBJS)
	@echo " CC " xmenu
	@$(CC) $(CFLAGS) -o xmenu $(OBJS) -framework Cocoa

.c.o .m.o:
	@echo " CC " $<
	@$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(OBJS) xmenu