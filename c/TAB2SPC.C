/*

  This program converts TAB characters found in an input text file
  to hard spaces of given length into an output text file.
  Written by Chang Man Wai
  Compiled by Turbo C 2.0
*/
#include <stdio.h>

#define MAX_TABSIZE   10
#define BUF_SIZE      512
#define LF            0x0A
#define CR            0x0D
#define TAB           0x09
#define SPACE         0x20

void main(void)
{
  FILE *inf, *outf;
  char in[BUF_SIZE], out[BUF_SIZE*MAX_TABSIZE],
       in_fname[12], out_fname[12];
  int i, j, k, bytes_read, tab_size;

  printf("\nTAB-to-SPACES v1.0 (C++)\n\n");
  printf("\nInput File Name: ");
  scanf("%s", in_fname);
  printf("\nOutput File Name: ");
  scanf("%s", out_fname);
  tab_size=MAX_TABSIZE+1;
  while (tab_size > MAX_TABSIZE)
  {
    tab_size=1;
    printf("\nSize of tab(1..10): ");
    scanf("%d", &tab_size);
  }

  if ( (inf=fopen(in_fname, "rb")) != NULL)
    if ( (outf=fopen(out_fname, "wb")) != NULL)
      while ((bytes_read=fread(in, 1, BUF_SIZE, inf)) > 0)
      {
        for (j=i=0; i < bytes_read; i++)
          if (in[i] == TAB)
            for (k=0;k<tab_size;k++) out[j++]=SPACE;
          else
            out[j++]=in[i];
        printf(".");
        fwrite(out, 1, j, outf);
      }
    else
      printf("\nCannot create output file!");
  else
    printf("\nCannot open input file!");

  fclose(outf);
  fclose(inf);
}
