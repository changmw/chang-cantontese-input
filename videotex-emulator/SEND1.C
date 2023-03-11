/* Communication Manager for VideoTex Emulator */
/* Written by Chang Man Wai */
/* Date : December 20, 1989 */
#define UNKNOWN   0
#define CONNECT   1
#define BUSY      2
#define TIMEOUT   3
#define ABORT     4
#include <stdio.h>
#include <dos.h>
#include <string.h>
#include <alloc.h>

#include "commngr.h"

int xhrfree;   /* flag for status of 8250 */
int terminalid;

/*  locally used variables */

static int portaddress;

void setup8250() {

  int msr, lsr;
  unsigned char i;


  portaddress = COM1_base;
  setcombaud(1200);           /* set up default protocol */
  setwordlen(WordLength7);
  setparity(EvenParity|ParityEnable);
  setstopbit(OneStopBit);

  i=inportb(portaddress+RX);          /* clear any character in RX before */
  outportb(INTA01,(inportb(INTA01) & 0xef));
}

void setwordlen(unsigned char wl) {
/* set word length in communication */
  outportb(portaddress+LineControl, (inportb(portaddress+LineControl)|wl));
}

void setparity(unsigned char p) {
/* set parity */
  outportb(portaddress+LineControl, (inportb(portaddress+LineControl)|p));
}

void setstopbit(unsigned char sb) {
  outportb(portaddress+LineControl, (inportb(portaddress+LineControl)|sb));
}

void setcombaud(int br) {
  unsigned char lobyte, hibyte;
  int t;

  t = BaudFactor/br;
  hibyte = (unsigned)(char) t >> 8;
  lobyte = (unsigned)(char) t;
  outportb( portaddress+LineControl, DLAB );   /* set DLAB=1 */
  outportb( portaddress+DivLatchMSB, hibyte );
  outportb( portaddress+DivLatchLSB, lobyte );
  outportb( portaddress+LineControl, DLABoff );/* set DLAB=0 */
}

int sendchar(unsigned char a) {
/* send a character to default com. port */
  int msr, mcr, timeout, control;

  /* wait for transmit Transmit Ready */
  for (timeout=3000;
       ((inportb(portaddress+LineStatus)&XmitReady)==0) && timeout>0;
       --timeout);
  if (timeout==0) return(2);

  /* send the character */
  outportb(portaddress+TX, a);
  return(0);
}