/*
   Keyboard Manager of Videotex Emulator
   Author: Chang Man Wai
*/
#include <stdio.h>
#include <bios.h>
#include <graphics.h>
#include "commngr.h"
#include "keyboard.h"
#include "pm.h"

extern int blinking;
extern FILE *logfile;  /* session log file for Videotex Emulator */
extern log_session;    /* flag indicating whether the session */
		                 /* is to be logged */
void showtime();

int inkey() {
/* while waiting for key pressed display any character received */
/* return any character receive from keyboard to the function caller */
  int i, nodata;
  char a;
  static long j;

  while (bioskey(1)==0) {       /* waiting for keypress */
    if (j!=biostime(0,0)) {     /* get system time */
      j=biostime(0,0);
      if (j%9==0) {            /* every 1/2 second */
	     blinking=(blinking==0) ? 1 : 0;
	     showtime();            /* display time */
	     flashing();            /* show flash characters */
      }
    }
    if (receivechar(&a)) {
      if (log_session)         /* log input characters */
   	fputc(a,logfile);
      charin(a);
    }
  }
  i=bioskey(0);
  return ( ( (i&0x00ff)==0 ) ? i : i&0xff );
}

/* wait for a key pressed only */
int inkey2() {
  int i;

  while (bioskey(1)==0);       /* waiting for keypress */
  i=bioskey(0);
  return ( ((i&0x00ff)==0) ? i : i&0xff);
}

void showtime() {
  /* convert numeric value into ascii codes */
  long k;
  int sys_hour, sys_minute, sys_second;
  char systime[10];

  k=biostime(0,0);
  sys_hour=(int) (k/65520);
  k%=65520;
  sys_minute=(int) (k/1092);
  k%=1092;
  sys_second=(int) (k/18.2);

  systime[0]=(char)((int)(sys_hour/10)+48);
  systime[1]=(char)(sys_hour%10+48);
  systime[2]=':';
  systime[3]=(char)((int)(sys_minute/10)+48);
  systime[4]=(char)(sys_minute%10+48);
  systime[5]=':';
  systime[6]=(char)((int)(sys_second/10)+48);
  systime[7]=(char)(sys_second%10+48);
  systime[8]='\0';

  /* display time both at primary and secondary page */
  settextstyle(DEFAULT_FONT, HORIZ_DIR, 0);
  setfillstyle(SOLID_FILL, BLUE);
  for (k=1;k>=0;k--) {
    setactivepage(k);
    bar(550, 340, 639, 349);     /* erase old time */
    setcolor(WHITE);
    outtextxy(550,340,systime);  /* show new time */
  }
}
