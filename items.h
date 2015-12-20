#pragma once

#include <ApplicationServices/ApplicationServices.h>
#include <stdbool.h>

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
void ItemListFilter(ItemList *dest, ItemList src, CFStringRef substr);
void ItemListReset(ItemList *l);
void ItemListFrom(ItemList *dest, ItemList src);