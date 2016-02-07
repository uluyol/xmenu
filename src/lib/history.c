#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "history.h"

// This is the target length for the entries.
// We may store more on disk to avoid rewriting the
// entire file all the time, but we only use this
// many entries in the history.
#define ENTRIES_TARGET_LEN 1024

HistSlice append(HistSlice sl, Hist h) {
  if (sl.len == sl.cap) {
    sl.cap += BUFSIZ;
    sl.arr = realloc(sl.arr, sl.cap * sizeof(Hist));
  }
  sl.arr[sl.len] = h;
  sl.len++;
  return sl;
}

static void update(HistSlice *hist, const char *s) {
  bool found = false;
  size_t pos = 0;
  for (size_t i = 0; i < hist->len; i++) {
    if (strcmp(hist->arr[i].s, s) == 0) {
      found = true;
      pos = i;
      hist->arr[i].count++;
      break;
    }
  }

  if (!found) {
    pos = hist->len;
    Hist h;
    h.s = s;
    h.count = 1;
    *hist = append(*hist, h);
  }

  Hist entry = hist->arr[pos];

  // Promote position to the highest of that count.
  // This way more recent items show up on top.
  while (pos > 0 && hist->arr[pos - 1].count >= entry.count) {
    hist->arr[pos] = hist->arr[pos - 1];
    hist->arr[pos - 1] = entry;
    pos--;
  }
}

typedef struct {
  char **arr;
  size_t len;
  size_t cap;
} StringSlice;

static StringSlice appendSS(StringSlice sl, char *s) {
  if (sl.len == sl.cap) {
    sl.cap += BUFSIZ;
    sl.arr = realloc(sl.arr, sl.cap * sizeof(char *));
  }
  sl.arr[sl.len] = s;
  sl.len++;
  return sl;
}

static StringSlice entries;

bool loadhist(HistSlice *hist, const char *hist_path) {
  bool had_error = false;
  hist->arr = NULL;
  hist->len = 0;
  hist->cap = 0;

  entries.arr = NULL;
  entries.len = 0;
  entries.cap = 0;

  FILE *hist_f = fopen(hist_path, "r+");
  if (hist_f == NULL) {
    goto Return;
  }
  char *buf = NULL;
  size_t cap = 0;
  size_t len = 0;
  while ((len = getline(&buf, &cap, hist_f)) != (size_t)(-1)) {
    if (len == 1 && buf[0] == '\n') {
      continue;
    }
    char *entry = strdup(buf);
    entries = appendSS(entries, entry);
  }

  size_t start = 0;
  if (entries.len > ENTRIES_TARGET_LEN) {
    start = entries.len - ENTRIES_TARGET_LEN;

    if (entries.len > 2 * ENTRIES_TARGET_LEN) {
      fseek(hist_f, 0, SEEK_SET);
      int hist_fd = fileno(hist_f);
      ftruncate(hist_fd, 0);
      for (size_t i = start; i < entries.len; i++) {
        fprintf(hist_f, "%s", entries.arr[i]);
      }
    }
  }

  for (size_t i = start; i < entries.len; i++) {
    update(hist, entries.arr[i]);
  }

  free(buf);
  fclose(hist_f);
Return:
  return had_error;
}

bool loadhist0(HistSlice *hist, const char *hist_path) {
  bool had_error = false;
  hist->arr = NULL;
  hist->len = 0;
  hist->cap = 0;

  FILE *hist_f = fopen(hist_path, "r");
  if (hist_f == NULL) {
    goto Return;
  }
  char *buf = NULL;
  size_t cap = 0;
  size_t len = 0;
  size_t lineno = 0;
  while ((len = getline(&buf, &cap, hist_f)) != (size_t)(-1)) {
    lineno++;
    if (len == 1 && buf[0] == '\n') {
      continue;
    }
    char *delim = strchr(buf, ',');
    if (delim == NULL) {
      fprintf(stderr, "corrupt history file, %s:%zu should have format count,string\n", hist_path,
              lineno);
      goto Err;
    }
    *delim = '\0';
    Hist entry;
    entry.count = strtol(buf, NULL, 10);
    entry.s = strdup(delim + 1);
    *hist = append(*hist, entry);
  }
Err:
  free(buf);
  fclose(hist_f);
Return:
  return had_error;
}
