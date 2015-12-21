/*

This file is mostly taken from dmenu.

MIT/X Consortium License

© 2006-2014 Anselm R Garbe <anselm@garbe.us>
© 2010-2012 Connor Lane Smith <cls@lubutu.com>
© 2009 Gottox <gottox@s01.de>
© 2009 Markus Schnalke <meillo@marmaro.de>
© 2009 Evan Gates <evan.gates@gmail.com>
© 2006-2008 Sander van Dijk <a dot h dot vandijk at gmail dot com>
© 2006-2007 Michał Janeczek <janeczek at gmail dot com>
© 2014-2015 Hiltjo Posthuma <hiltjo@codemadness.org>

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern bool topbar;
extern bool caseSensitive;
extern float window_height;
extern const char *promptCStr;
extern const char *font;
extern const char *normbgcolor;
extern const char *normfgcolor;
extern const char *selbgcolor;
extern const char *selfgcolor;

void usage(void);

void *ecalloc(size_t n, size_t siz) {
  void *p = calloc(n, siz);
  if (p == NULL) {
    perror(NULL);
    exit(1);
  }
  return p;
}

void parseargs(int argc, const char **argv) {
  int i;
  for (i = 1; i < argc; i++) {
    /* these options take no arguments */
    if (!strcmp(argv[i], "-v")) { /* prints version information */
      puts("xmenu-" XMENU_VERSION ", a dmenu clone");
      exit(0);
    } else if (!strcmp(argv[i], "-b")) { /* appears at the bottom of the screen */
      topbar = false;
    } else if (!strcmp(argv[i], "-f")) { /* grabs keyboard before reading stdin */
      /* deliberately unsupported */;
    } else if (!strcmp(argv[i], "-i")) { /* case-insensitive item matching */
      caseSensitive = false;
    } else if (i + 1 == argc) {
      usage();
      /* these options take one argument */
    } else if (!strcmp(argv[i], "-l")) { /* number of lines in vertical list */
      fprintf(stderr, "support for -l is not yet implemented\n");
      exit(1);
    } else if (!strcmp(argv[i], "-m")) {
      /* unsupported */;
    } else if (!strcmp(argv[i], "-p")) { /* adds prompt to left of input field */
      promptCStr = argv[++i];
    } else if (!strcmp(argv[i], "-fn")) { /* font or font set */
      font = argv[++i];
    } else if (!strcmp(argv[i], "-nb")) { /* normal background color */
      normbgcolor = argv[++i];
    } else if (!strcmp(argv[i], "-nf")) { /* normal foreground color */
      normfgcolor = argv[++i];
    } else if (!strcmp(argv[i], "-sb")) { /* selected background color */
      selbgcolor = argv[++i];
    } else if (!strcmp(argv[i], "-sf")) { /* selected foreground color */
      selfgcolor = argv[++i];
    } else if (!strcmp(argv[i], "-H")) { /* bar height */
      window_height = atof(argv[++i]);
    } else {
      usage();
    }
  }
}

void usage(void) {
  fputs(
      "usage: xmenu [-b] [-i] [-p prompt] [-fn font][-nb color] [-nf color]\n"
      "             [-sb color] [-sf color] [-H height] [-v]\n",
      stderr);
  exit(1);
}
