#include <time.h>
#include <stdlib.h>
/*
WAITN - written by Chang Man Wai

Wait for given number of seconds, seconds elapsed will NOT be shown
- useful in bringing up file/print server after some delay

This program was written for DOS 3.30, again for Survey Researh Hongkong.

DOS 5 and 6 got a new function CHOICE.EXE.
*/
int elapsed_time();

void main(int argc, char *argv[]) {
  if (argc==1) {
    printf("\nWAIT v1.0\n");
    printf("Usage: wait [seconds]\n");
    exit(1);
  }
  while (elapsed_time() < atoi(argv[1])) {
    if (kbhit()) {
      bioskey(0);
      exit(1);
    }
  }
  exit(0);
}

int elapsed_time() {
  static int start_time = 0;

  start_time = 0 ? clock()/CLK_TCK : start_time;
  return(abs(start_time-clock()/CLK_TCK));
}

