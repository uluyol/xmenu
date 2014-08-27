#import <stdbool.h>
#import <ApplicationServices/ApplicationServices.h>

typedef struct {
	CFStringRef text;
	bool out;
} Item;

typedef struct {
	Item *items;
	size_t len;
	size_t cap;
} ItemList;

ItemList ReadStdin(void);