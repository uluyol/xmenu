#include <stdio.h>
#include <stdlib.h>
#include "items.h"
#include "util.h"

Item *newItem(ItemList *list) {
  Item *item;
  if (list->len == list->cap) {
    list->cap += sizeof(Item) * BUFSIZ;
    if (!(list->item = realloc(list->item, list->cap))) {
      return NULL;
    }
  }
  item = list->item + list->len;
  (list->len)++;
  item->text = NULL;
  item->sel = FALSE;
  return item;
}

void ItemListFilter(ItemList *dest, ItemList src, CFStringRef substr) {
  bool alwaysAdd = CFStringGetLength(substr) == 0;
  for (int i = 0; i < src.len; i++) {
    Item *cur = src.item + i;
    if (!alwaysAdd) {
      CFRange r =
          CFStringFind(cur->text, substr, kCFCompareCaseInsensitive |
                                              kCFCompareDiacriticInsensitive);
      if (r.location == kCFNotFound || r.length == 0) {
        continue;
      }
    }
    newItem(dest)->text = cur->text;
  }
}

void ItemListReset(ItemList *l) { l->len = 0; }

void ItemListFrom(ItemList *dest, ItemList src) {
  dest->cap = src.len;
  dest->len = src.len;
  dest->item = ecalloc(sizeof(Item), src.len);
  memcpy(dest->item, src.item, sizeof(Item) * src.len);
}

ItemList ReadStdin(void) {
  ItemList list;
  char *buf = NULL;
  size_t cap = 0;
  size_t len;
  while ((len = getline(&buf, &cap, stdin)) != -1) {
    if (len && buf[len - 1] == '\n') buf[len - 1] = '\0';
    Item *item = newItem(&list);
    if (item == NULL) {
      goto end;
    }
    item->sel = false;
    char *padded = pad(buf);
    item->text = CFStringCreateWithCString(NULL, padded, kCFStringEncodingUTF8);
    free(padded);
  }
end:
  free(buf);
  return list;
}
