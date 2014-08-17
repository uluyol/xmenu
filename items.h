#import <stdbool.h>

typedef struct {
	char *text;
	bool out;
} Item;

typedef struct {
	Item *items;
	size_t len;
	size_t cap;
} ItemList;

ItemList *ReadStdin(void);