#import <stdio.h>
#import <stdlib.h>
#import "items.h"

ItemList *
newItemList(void)
{
	return calloc(1, sizeof(ItemList));
}

Item *
newItem(ItemList *list)
{
	Item *item;
	/* We never free anything so pos should never loop. */
	if (list->len == list->cap) {
		list->cap += sizeof(Item) * BUFSIZ;
		if (!(list->items = realloc(list->items, list->cap))) {
			return NULL;
		}
	}
	item = list->items + list->len;
	(list->len)++;
	return item;
}

ItemList *
ReadStdin(void)
{
	ItemList *list = newItemList();
	char *buf = NULL;
	size_t cap = 0;
	size_t len;
	while ((len = getline(&buf, &cap, stdin)) != -1) {
		if (len && buf[len-1] == '\n')
			buf[len-1] = '\0';
		Item *item = newItem(list);
		if (item == NULL)
			return list;
		item->out = false;
		item->text = buf;
		buf = NULL;
	}
	return list;
}

