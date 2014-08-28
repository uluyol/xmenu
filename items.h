#import <stdbool.h>
#import <ApplicationServices/ApplicationServices.h>

typedef struct {
	CFStringRef text;
	bool sel;
} Item;

typedef struct {
	Item *item;
	size_t len;
	size_t cap;
} ItemList;

ItemList ReadStdin(void);