/*
   Communication Manager of VideoTex Emulator
   Author: Chang Man Wai
*/

#include <stdio.h>    /* Turbo C libraries */
#include <dos.h>
#include <string.h>
#include <alloc.h>
#include <graphics.h>

#include "keyboard.h"  /* interface with other managers */
#include "pm.h"
#include "queue.h"
#include "commngr.h"
#include "windmngr.h"
#include "util.h"
#include "script.h"

enum dialing_result { UNKNOWN, CONNECT, BUSY, TIMEOUT, ABORT };

/* modem command strings */
char modemconnect[21], modembusy[21], modeminit[41],
     modemreset[21], modemhangup[21], dialprefix[21];

/* terminal characteristics */
int termbaudrate, termcom, dialtime;
char termstopbit, termparity, termwordlength, termlocalecho;

/* communication error flag */
int parityerr, overrunerr, framingerr;

int cts, dsr, dcd, ri, xhrfree;   /* flag for status of 8250 */

/*  locally used variables */
static portaddress;
static QUEUE iq,   /* ring buffer for incoming characters */
             *inq; /* pointer to iq */

static void interrupt (*OldAsynVector)();

void setup8250() {
/* setup the communication ports and interrupt handler */
  int msr, lsr;

  /* initialize global variables */
  inq  = &iq;       /* incoming character queue */
  flushqueue(inq);  /* empty input queue */

  /* initialize 8250 */
  portaddress=portbase(termcom);
  hook8250int();
  setcombaud(termbaudrate);           /* set up default protocol */
  setwordlen(termwordlength);
  setparity(termparity);
  setstopbit(termstopbit);

  init_MCR(DataTerminalReady|Out2); /* init modem control */
  inportb(portbase(termcom)+RX);    /* clear any character in RX before */
				      /* enabling data ready interrupt */
  init_8250_int(EnableLineStatus|EnableDataReady|EnableModemStatus);
  outportb(INTA01,(inportb(INTA01) & ENABLE_ASYN));

  /* initialize communication flags */
  msr = inportb(portbase(termcom)+ModemStatus);
  cts = (msr & ClearToSend)       ? 1 : 0;
  dsr = (msr & DataSetReady)      ? 1 : 0;
  dcd = (msr & DataCarrierDetect) ? 1 : 0;
  ri  = (msr & RingIndicator)     ? 1 : 0;
}

void reset8250int() {
/* unhook our interrupt service routine from IRQ3 or IRQ4, replace
   original vector */
  switch (termcom) {
    case COM1: reset_int(IRQ4_IntrNo, OldAsynVector);
               break;
    case COM2: reset_int(IRQ3_IntrNo, OldAsynVector);
               break;
  }
}

void hook8250int() {
/* hook our interrupt service routine to IRQ3 or IRQ4 */
  switch (termcom) {
    case COM1: capture_int(IRQ4_IntrNo, com_int_handler);
               break;
    case COM2: capture_int(IRQ3_IntrNo, com_int_handler);
               break;
  }
}

void capture_int(int intno, void interrupt (*func)()) {
/* store the address of a function in vector table,
   the old address is stored */
  OldAsynVector=getvect(intno);
  setvect(intno,func);
}

void reset_int(int intno, void interrupt (*func)()) {
/* restore the oldaddress of function in vector table */
  setvect(intno, func);
}

int portbase(int comport) {
/* set the base address of comport */
  switch (comport) {
    case COM1: return COM1_base;
    case COM2: return COM2_base;
  }
}

void setwordlen(unsigned char wl) {
/* set word length in communication */
  outportb(portbase(termcom)+LineControl,
	   (inportb(portbase(termcom)+LineControl)|wl));
}

void setparity(unsigned char p) {
/* set parity */
  outportb(portbase(termcom)+LineControl,
	   (inportb(portbase(termcom)+LineControl)|p));
}

void setstopbit(unsigned char sb) {
  outportb(portbase(termcom)+LineControl,
	   (inportb(portbase(termcom)+LineControl)|sb));
}

void setcombaud(int br) {
/* set baud rate of communcation interrupt */
  unsigned char lobyte, hibyte;
  int t;

  t = BaudFactor/br;
  hibyte = (unsigned)(char) t >> 8;
  lobyte = (unsigned)(char) t;
  outportb(portbase(termcom)+LineControl, DLAB);   /* set DLAB=1 */
  outportb(portbase(termcom)+DivLatchMSB, hibyte);
  outportb(portbase(termcom)+DivLatchLSB, lobyte);
  outportb(portbase(termcom)+LineControl, DLABoff);
}

void init_8250_int(unsigned char mask) {
/* enable communication interrupt */
  outportb(portbase(termcom)+LineControl,
	   (inportb(portbase(termcom)+LineControl)|DLABoff));
  outportb(portbase(termcom)+InterruptEna,mask);
}

void init_MCR(unsigned char mask) {
/* intialize modem control register */
  outportb(portbase(termcom)+ModemControl, mask);
}

void interrupt com_int_handler() {
/* interrupt service routine for communication routine */
  register char iir,lsr,msr,i;

  outportb(INTA01, (inportb(INTA01)|DISABLE_ASYN)); /* disable asyn int */
  iir=inportb(portaddress+InterruptID); /* check type of interrupt */

  overrunerr=parityerr=framingerr=0;
  switch (iir) {
    case LineStatusInterrupt:
      lsr=inportb(portaddress+LineStatus); /* clear line status interrupt */
      outportb(portaddress+LineControl,    /* set dLAB off */
	       (inportb(portaddress+LineControl)|DLABoff));
      inportb(portbase(termcom)+RX);       /* clear receive data register */
      parityerr  = (lsr & ParityError)  ? 1 : 0;  /* set error flags */
      overrunerr = (lsr & OverrunError) ? 1 : 0;
      framingerr = (lsr & FramingError) ? 1 : 0;
      xhrfree    = (lsr & XmitReady)    ? 1 : 0;
      break;

    case DataReadyInterrupt:   /* queue received characters */
      outportb(portaddress+LineControl,
	       (inportb(portaddress+LineControl)|DLABoff));
      enqueue(inq, inportb(portaddress+RX));
      break;

    case ModemStatusInterrupt:   /* set modem status flags */
      msr=inportb(portaddress+ModemStatus);
      if (msr & DeltaCTS)    cts = (msr & ClearToSend)       ? 1 : 0;
      if (msr & DeltaDSR)    dsr = (msr & DataSetReady)      ? 1 : 0;
      if (msr & DeltaDCD)    dcd = (msr & DataCarrierDetect) ? 1 : 0;
      if (msr & TrailEdgeRI) ri  = (msr & RingIndicator)     ? 1 : 0;
      break;

    default:  /* unknown soource of interrupt, should not occur */
      lsr=inportb(portaddress+LineStatus);
      break;
  }
  outportb(INTA00,EOI);               /* send end of interrupt to 8259A */
  outportb(INTA01,(inportb(INTA01) & ENABLE_ASYN)); /* enable asyn int */
}

int sendchar(unsigned char a) {
/* send a character to default com. port */
  int timeout;

  /* wait for Transmit Ready */
  for (timeout=3000;
       ((inportb(portbase(termcom)+LineStatus)&XmitReady)==0) && timeout>0;
       --timeout);
  if (timeout==0) return(2);

  /* send the character */
  outportb(portbase(termcom)+TX, a);
  return(0);
}

int sendstring(char *s) {
/* send a series of characters to default com port */
  int i, j;

  for (i=0;s[i]!='\0';i++) {
    switch (s[i]) {
      case '|': j=sendchar(CR);
		          break;
      case '~': delay(500);
		          break;
      case '#': j=sendchar('_');
		          break;
      default:  j=sendchar(s[i]);
    }
    if (j!=0) return(1);
  }
  return(0);
}

int receivechar(char *a) {
/* get a character from incoming character queue */
  if (!queue_empty(inq)) {
    a[0]=dequeue(inq);
    return(1);
  }
  else
    return(0);
}

/***************  Modem control functions *******************/

void init_modem() {
/* initialize the modem */
  int j;
  void *buffer;

  setwindowcolors(WHITE, DARKGRAY, WHITE);/* inform user resetting modem */
  buffer=openwindow(200,200, 21*CHAR_WIDTH, 3*CHAR_HEIGHT);
  setcolor(YELLOW);
  settextstyle(DEFAULT_FONT,HORIZ_DIR, 0);
  outtextxy(205,200+CHAR_HEIGHT,"Initializing Modem");

  sendstring(modemreset);
  sleep(2);   /* wait 2 seconds for modem to be completely resetted */
  sendstring(modeminit);
  closewindow(200,200,buffer);
}

void dial(char *nodename, char *phoneno, int times) {
/* dial a number */
  void * oldscreen;
  char *s, c, *r;
  int size, result, ri, tries;
  long k, endtime;

  setactivepage(0);
  setvisualpage(0);

  /* creating modem command */
  s=malloc(20);
  r=malloc(20);
  strcpy(s, dialprefix);
  strcat(s, phoneno);

  /* show dialing window */
  setwindowcolors(WHITE, DARKGRAY, WHITE);
  oldscreen=openwindow(200,100,CHAR_WIDTH*40,CHAR_HEIGHT*4);
  setcolor(WHITE);
  outtextxy(210,100+CHAR_HEIGHT,   "Dialing : ");
  outtextxy(210,100+CHAR_HEIGHT*3, "Result: ");
  setcolor(YELLOW);
  outtextxy(210+CHAR_WIDTH*10,100+CHAR_HEIGHT, nodename);
  outtextxy(210+10*CHAR_WIDTH,100+CHAR_HEIGHT*2,phoneno);

  result=BUSY;
  tries=script_CONNECT=0;
  while ((result==BUSY)||(result==TIMEOUT)) {
    endtime=biostime(0,0)+(long)dialtime*18.2;
    sendstring(s);
    sendchar(CR);
    flushqueue(inq);
    result=UNKNOWN;
    ri=0;
    while ((bioskey(1)==0) &&
          (biostime(0,0)<endtime) &&
          (result==UNKNOWN)) {
      if (receivechar(&c)) {
        *(r+(ri++))=c;
        *(r+ri)='\0';
        if (index(strupr(r),strupr(modemconnect))!=0)
      result=CONNECT;
        if (index(strupr(r),strupr(modembusy))!=0)
      result=BUSY;
      }
    }
    if (bioskey(1)!=0) {   /* user pressed a key */
      bioskey(0);
      result=ABORT;        /* dialing process is terminated by user */
    }
    setfillstyle(SOLID_FILL, BG_COLOR);
    bar(210+CHAR_WIDTH*10, 100+CHAR_HEIGHT*3, 350, 100+CHAR_HEIGHT*4-4);
    setcolor(LIGHTGREEN);
    switch (result) {     /* display result of dialing */
      case BUSY:
        outtextxy(210+CHAR_WIDTH*10,100+CHAR_HEIGHT*3,"BUSY");
        break;
      case CONNECT:
        script_CONNECT=1;
        outtextxy(210+CHAR_WIDTH*10,100+CHAR_HEIGHT*3,"CONNECTED");
        bailout=1;
        break;
      case ABORT:
        outtextxy(210+CHAR_WIDTH*10,100+CHAR_HEIGHT*3,"DIAL ABORTED");
        break;
      default:
        result=TIMEOUT;
        outtextxy(210+CHAR_WIDTH*10,100+CHAR_HEIGHT*3,"TIMEOUT");
        break;
    }
    if (((++tries)>=times) && (times!=0))
      break;
    sendchar(CR);
    delay(500);
  }
  closewindow(200,100,oldscreen);
  free(s); free(r);
}

void hang_up() {
/* send hang up command to modem */
  void *buffer;

  setwindowcolors(WHITE, DARKGRAY, WHITE);  /* window */
  buffer=openwindow(200,200, 12*CHAR_WIDTH, 3*CHAR_HEIGHT);
  setcolor(YELLOW);
  settextstyle(DEFAULT_FONT,HORIZ_DIR, 0);
  outtextxy(205,200+CHAR_HEIGHT,"Hanging Up");

  sendstring(modemhangup);
  closewindow(200,200,buffer);
}
