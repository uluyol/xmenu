CC = clang
CFLAGS ?= -Wall
OBJS = draw.o items.o main.o util.o view.o

.PHONY: all clean

all: xmenu

xmenu: $(OBJS)
	@echo " CC " xmenu
	@$(CC) -o xmenu $(OBJS) -framework Cocoa

.c.o .m.o:
	@echo " CC " $<
	@$(CC) -c $<

clean:
	rm -f $(OBJS) xmenu