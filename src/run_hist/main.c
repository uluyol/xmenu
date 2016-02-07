#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "history.h"

static HistSlice history;

bool inhistory(const char *s) {
  for (size_t i = 0; i < history.len; i++) {
    if (strcmp(s, history.arr[i].s) == 0) {
      return true;
    }
  }
  return false;
}

int main(int argc, const char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: %s /path/to/history/file\n", argv[0]);
    return 1;
  }
  if (loadhist(&history, argv[1]) != 0) {
    return 1;
  }

  for (size_t i = 0; i < history.len; i++) {
    printf("%s", history.arr[i].s);
  }

  char *buf = NULL;
  size_t cap = 0;
  size_t len = 0;
  while ((len = getline(&buf, &cap, stdin)) != (size_t)(-1)) {
    if (!inhistory(buf)) {
      printf("%s", buf);
    }
  }
  free(buf);
  return 0;
}