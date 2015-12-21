#include <stdio.h>
#include <stdlib.h>

void *ecalloc(size_t n, size_t siz) {
  void *p = calloc(n, siz);
  if (p == NULL) {
    perror(NULL);
    exit(1);
  }
  return p;
}
