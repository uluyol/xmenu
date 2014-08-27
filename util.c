#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *
pad(char *s)
{
	int cap = strlen(s)+3;
	char *padded = malloc(cap);
	if (padded)
		snprintf(padded, cap, " %s ", s);
	return padded;
}