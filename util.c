#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void *ecalloc(size_t n, size_t siz) {
  void *p = calloc(n, siz);
  if (p == NULL) {
    perror(NULL);
    exit(1);
  }
  return p;
}

char *pad(char *s) {
  int cap = strlen(s) + 3;
  char *padded = ecalloc(cap, sizeof(char));
  snprintf(padded, cap, " %s ", s);
  return padded;
}
