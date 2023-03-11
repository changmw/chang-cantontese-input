#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "commngr.h"

void main(int argc, char *argv[]) {
  FILE *f;
  char i;
  int j;

  setup8250();

  f=fopen(argv[1],"rb");
  if (f==NULL)
    printf("Cannot open %s", argv[1]);
  else {
    while ((i=(char)fgetc(f))!=EOF) {
      j=sendchar(i);
      printf("%c",i);
    }
    printf("\nFile %s sent", argv[1]);
    j=fclose(f);
  }
}

