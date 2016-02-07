#pragma once

#include <stdbool.h>
#include <stdint.h>

typedef struct {
  int64_t count;
  const char *s;
} Hist;

typedef struct {
  Hist *arr;
  size_t len;
  size_t cap;
} HistSlice;

HistSlice append(HistSlice sl, Hist h);
bool loadhist(HistSlice *hist, const char *hist_path);
