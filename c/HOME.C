/*
  return a user to the directory specified by DOS environment variable HOME
         in drive F: (Novell Netware 386)
  Written by Chang Man Wai
  
  This program was intent to use with Novell Netware 386 in Survey Research Hongkong.
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
