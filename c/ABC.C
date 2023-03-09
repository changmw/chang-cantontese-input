#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

/*
  This program is used to print a PCRAS reports from a given page.
  A new page is identified by the string "SRH RETAIL AUDIT".
  
  SRH, Survey Research Hong Kong, was a market research company.
  Retail audit aimed to collect sales figures of goods in various
  supermarkets.

  This function was written to help Data Processing Deparment (of 
  Survey Reseearch Hongkong) to print a big file from a given page.
  Back then, the printer might be out of paper. It will be a nightware
  to restart the whole print job.
*/

char str[20];
FILE *p;

void usage();

void main(int argc,char **argv)
{
  int i, j, f;

  p = fopen(argv[1],"rb");
  i = 0;
  while (fgets(str,1,p) && !kbhit())
  {
    if (strncmp(str,"",1)==0) i++;
	printf("%s pages so far\r");
  }
  fclose(p);
}
