/*
  return a user to the directory specified by DOS environment variable HOME
         in drive F:
  Written by Chang Man Wai
*/
#include <stdio.h>
#include <stdlib.h>
#include <dir.h>

void main()
{
  int i = 4;

  /* printf("%s\n", getenv("HOME")); */
  /*
     attemp to change to HOME at current drive first, if failed
     try F:, then G:, ...
  */
  while (chdir(getenv("HOME")) == -1 && i <= 26) setdisk(i++);
}
