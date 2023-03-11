/*
  Utility routines of Videotex Emulator
  Author: Chang Man Wai
*/
#include <string.h>
#include "util.h"

int alphabet(char a) {
/* check whether a character belongs to set of alphabets */
  return ( (((a>='A')&&(a<='Z')) || ((a>='a')&&(a<='z')) ) ? 1 : 0);
}

int number(char a)  {
/* check whether a character belongs to the set of numbers */
  return( ((a>='0')&&(a<='9')) ? 1 : 0);
}

int index( char *haystack, char *needle ) {
/*  Function to return the index of string target in source. */
  register int i, j, k;

  for (i=0; haystack[i]!='\0'; i++) {
    for (j=i, k=0; needle[k]!='\0' && haystack[j]==needle[k]; j++, k++);
    if (needle[k] == '\0')
      return(i+1);
  }
  return(0);
}