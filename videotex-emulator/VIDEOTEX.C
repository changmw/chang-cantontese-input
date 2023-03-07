/*
   Core of Videotex Emulator
   Author: Chang Man Wai
*/
#include <graphics.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <alloc.h>
#include <bios.h>

#include "util.h"
#include "commngr.h"
#include "keyboard.h"
#include "windmngr.h"
#include "pm.h"
#include "draw.h"
#include "videotex.h"
#include "script.h"

int log_session=1,
    to_init_modem;   /* flag to indicate whether the modem is to be */
		               /* initialized when startup */

int to_print_screen=0, /* flag indicate whether print screen is chosen */
    exe_script=0,      /* flag indicate whether script is to be executed */
    to_view_screen=0;  /* flag to indicate whether the print screen function */
                       /* is selected */
FILE *logfile,         /* session log file */
     *configfile;      /* config file for Videotex Emulator */

extern FILE *chinese_file1,   /* data file for displaying */
	    *chinese_file2;   /* chinese characters       */
extern int bkg[40][24];       /* array indicating the background color */
                              /* of each character displayed */
extern int script_running;    /* flag indicate whether script is running */

MENU dialmenu, modemmenu, termmenu, miscmenu, fsavemenu,
     localmenu, baudmenu, stopbitmenu, wordlenmenu,
     paritymenu, serialpmenu;

DIALDIR phonedir;   /* dialing directory */

MACRO macrolist;    /* macro directory */

char *screen_to_view="XXXXXXXX.YYY",
     *script_fname  ="XXXXXXXX.YYY";

void main(int argc, char *argv[]) {
  int looping, k, i;  /* flags and loop counters */
  int g_driver,       /* graphic driver file name */
      g_mode,         /* initial graphic mode to use */
      g_error;        /* error code of initializing the graphics device */

  /* check if the user has added the "o" option when invoking */
  /* the Videotex Emulator */
  script_running=0;
  to_init_modem=((argv[1][0]=='o')||(argv[1][0]=='O')) ? 0 : 1;

  if (registerbgidriver(EGAVGA_driver) < 0) exit(1);
  if (registerbgifont(triplex_font) < 0) exit(1);

  /* check available memory */
  if (biosmemory()<150) {
    printf("\nInsufficient memory to run Videotex Emulator");
    printf("\nVideotex Emulator requires 200K free memory.\n");
    _exit(0);
  }

  /* initialize graphic device */
  g_driver=EGA;
  g_mode=EGAHI;
  initgraph(&g_driver, &g_mode, "");
  g_error = graphresult();
  if (g_error < 0) {
    printf("Initgraph error: %s\n", grapherrormsg(g_error));
    _exit(1);
  }

  /* open log file if necessary */
  if (log_session)
    if ((logfile=fopen("VIDEOTEX.LOG","ab"))==NULL) {
       printf("File open failure\n");
      _exit(1);
    }

  /* opening Chinese characters data file */
  chinese_file1 = fopen("stdfont1.15","rb");
  chinese_file2 = fopen("stdfonts.15","rb");
  if ((chinese_file1==NULL) || (chinese_file2==NULL)) {
    setwindowcolors(WHITE,RED,LIGHTRED);
    windowputs(200,200,"Missing Chinese dictionaries", 1);
  }

  /* init background color array default background color */
  for (i=0;i<40;i++)
    for (k=0;k<24;k++)
      bkg[i][k]=BLACK;
  /* initialize drawing primitives */
  init_draw();

  load_config();     /* load config file */
  init_menu();       /* intialize pull-down menu */
  setup8250();       /* setup the comm port */
  setactivepage(0);  /* select initial graphics page */
  setvisualpage(0);
  draw_logo();       /* display program logo */
  if (to_init_modem) /* init modem if necessary */
    init_modem();

  looping=1;
  while (looping) {
    show_status();
    k=inkey();               /* get a character */
    if (k=='#')              /* convert characters */
      k='_';
    if (termlocalecho)       /* echo characters if local echo on */
      charin(k);
    switch (k) {             /* base on function key to perform functions */
      case FK01:             /* show pull down menu */
	     horiz_menu();        /* display horizontal menu */
        break;

      case FK10:             /* exit the program */
	     setactivepage(0);
	     setvisualpage(0);
	     setfillstyle(SOLID_FILL,RED);
	     bar(0, STATUSLINE_Y, 639, 349);
	     setcolor(WHITE);
	     outtextxy(10,339,"F10 Exit  ESC Resume"); /* confirm for exit */
	     k=inkey2();
	     if (k==FK10)
	       looping=0;
        else
          show_status();
        break;

      case FK09:             /* reveal concealed characters */
	     reveal();
        break;

      case FK02:             /* invoke macro list */
        change_macros();
        break;

      default:
        i=sendchar(k);       /* send out the character */
        break;
    }
  }
  closegraph();              /* close graphic mode */

  fclose(chinese_file1);     /* close Chinese characters file */
  fclose(chinese_file2);

  reset8250int();            /* restore old comm interrupt vector */
  if (log_session)           /* close log file */
    fclose(logfile);
  save_config();             /* save Emulator setup in file */
  printf("Thanks for using Videotex Emulator\n");
}

void horiz_menu() {
  int lastkey, looping, show_vertical;  /* flags */
  void *b;
  MENU *cm;

  setvisualpage(0);      /* goto primary display page */
  setactivepage(0);
  show_vertical=0;

  menu_statusline();

  b=save_titleline();    /* save old screen */
  cm=&modemmenu;         /* first menu to be displayed */
  show_titleline(cm);    /* show menu titles */

  looping=1;
  while (looping) {
    if (show_vertical)
      lastkey=CR;
    else {
      show_a_title(cm);          /* hi-light selected option */
      lastkey=inkey2();
    }

    switch (lastkey) {
      case LEFT_ARROW:
        show_a_title(cm);        /* un-hi-light selection option */
        if (cm->prevmenu!=NULL)  /* tranverse horizontally (left)  */
        cm=cm->prevmenu;
        break;

      case CR:                          /* show vertical menu of the */
      case DOWN_ARROW:                  /* currently selected option */
        if (show_vertical) {
          show_a_title(cm);
          show_vertical=0;
        }
        setwindowcolors(BLACK, WHITE, BLACK); /* in horizontal menu */
        lastkey=display_menu(cm, 1, 1);
        if (bailout)                    /* leave pull-down menu system */
          looping=bailout=0;
        show_a_title(cm);               /* un-hi-light selection option */
        if (lastkey==RIGHT_ARROW) {
        show_vertical=1;
        if (cm->nextmenu!=NULL)
          cm=cm->nextmenu;
        }
        if (lastkey==LEFT_ARROW)  {
          show_vertical=1;
          if (cm->prevmenu!=NULL)
            cm=cm->prevmenu;
        }
        break;

      case RIGHT_ARROW:
	     show_a_title(cm);        /* un-hi-light selection option */
        if (cm->nextmenu!=NULL)  /* tranverse horizontally (right) */
          cm=cm->nextmenu;       /* the menu hierarchy */
        break;

      case ESC:                  /* leave pull-down menu */
        looping=0;
        break;

      default:
	     show_a_title(cm);        /* un-hi-light selection option */
	     break;                   /* in horizontal menu */
    }
  }
  restore_titleline(b);      /* restore the old status line */
  if (to_print_screen) {       /* print graphic page 0 after leaving */
    print_screen();            /* the pull-down menu system */
    to_print_screen=0;         /* reset the flag */
  }
  if (to_view_screen) {
    if (view_screen(screen_to_view)==1) {
      setwindowcolors(WHITE, RED, LIGHTRED);
      windowputs(300,160,"File Not Found", 1);
    }
    to_view_screen=0;
  }
  if (exe_script) {
    execute_script(script_fname);
    exe_script=0;
  }
}

void modemf() {
/* set modem control parameters */

  setwindowcolors(BLACK,WHITE,YELLOW);
  switch (modemmenu.option) {
    case 1:  /* edit modem init command string */
      windowgets(modemmenu.menux+30, modemmenu.menuy+20,
			 modeminit, 40);
      break;

    case 2:   /* edit modem connect reply string */
      windowgets(modemmenu.menux+30, modemmenu.menuy+30,
			 modemconnect, 20);
      break;

    case 3:   /* edit modem busy reply string */
      windowgets(modemmenu.menux+30, modemmenu.menuy+40,
			 modembusy, 20);
      break;

    case 4:   /* edit modem command string */
      windowgets(modemmenu.menux+30, modemmenu.menuy+50,
			 modemreset, 20);
      break;

    case 5:  /* edit modem hangup command string */
      windowgets(modemmenu.menux+30, modemmenu.menuy+60,
			 modemhangup, 20);
      break;

    case 6:   /* edit modem dial prefix command string */
      windowgets(modemmenu.menux+30, modemmenu.menuy+70,
			 dialprefix, 20);

    default:
      break;
  }
}

void dialf() {
/* set dialing functions */
  char *phoneno;
  void *b;
  int i;

  phoneno=(char *)malloc(10);
  strcpy(phoneno,"");
  setwindowcolors(BLACK, WHITE, LIGHTBLUE);
  switch (dialmenu.option) {
    case 1:   /* dialing directory */
      change_dialdir();  /* invoke dialing directory */
      break;
    case 2:   /* manual dial */
      if (windowgets(dialmenu.menux+50,  /* get phone number from user */
		     dialmenu.menuy+30,
		     phoneno, 10)==CR)
	dial("Manual", phoneno, 0);
      free(phoneno);
      break;
    case 3:   /* hang up */
      hang_up();
      break;
    case 4:   /* reset modem */
      init_modem();
      break;
    case 5:   /* set waiting time for connecting with server */
      b=openwindow(200,100, 50, 3*CHAR_HEIGHT);
      innumberxy(210,110,&dialtime,2);
      closewindow(200,100,b);
      break;
    default:
      break;
  }
}

void termf() {
/* set terminal characteristics */

  setwindowcolors(BLACK, WHITE, LIGHTRED);
  switch (termmenu.option) {
    case 1:     /* turn local echo on or off */
      if (termlocalecho)
	      display_menu(&localmenu, 0, 1);
      else
         display_menu(&localmenu, 0, 2);
      break;

    case 2:      /* set line baudrate */
      switch (termbaudrate) {
	      case 1200: display_menu(&baudmenu, 0, 1);
                    break;
         case 2400: display_menu(&baudmenu,0,2);
		              break;
         case 4800: display_menu(&baudmenu, 0, 3);
		              break;
         case 9600: display_menu(&baudmenu, 0, 4);
		              break;
      }
      break;

    case 3:      /* set number of stop bits in line */
      if (termstopbit==OneStopBit)
        display_menu(&stopbitmenu, 0, 1);
      else
        display_menu(&stopbitmenu, 0, 2);
      break;

    case 4:     /* set length of word */
      if (termwordlength==WordLength7)
        display_menu(&wordlenmenu, 0, 1);
      else
        display_menu(&wordlenmenu, 0, 2);
      break;

    case 5:     /* select  parity checking */
      if (termparity==NoParity)
        display_menu(&paritymenu, 0, 1);
      else if (termparity==(EvenParity|ParityEnable))
        display_menu(&paritymenu, 0, 2);
      else
        display_menu(&paritymenu, 0, 3);
      break;

    case 6:    /* select com. port */
      if (termcom==COM1)
        display_menu(&serialpmenu, 0, 1);
      else
        display_menu(&serialpmenu, 0, 2);
      break;

    default:
      break;
  }
  /* re-initialize 8250 with input parameters */
  setup8250();
}

void localf() {
/* set local echo */

  switch (localmenu.option) {
    case 1:
      termlocalecho=1;
      break;

    case 2:
      termlocalecho=0;
      break;

    default:
      break;
  }
}

void baudf() {
/* set baudrate */
  switch (baudmenu.option) {
    case 1: termbaudrate=1200;
            break;
    case 2: termbaudrate=2400;
            break;
    case 3: termbaudrate=4800;
            break;
    case 4: termbaudrate=9600;
            break;
  }
}

void stopbitf() {
/* set number of stop bits */
  switch (stopbitmenu.option) {
    case 1:
      termstopbit=OneStopBit;
      break;

    case 2:
      termstopbit=TwoStopBits;
      break;

    default:
      break;
  }
}

void wordlenf() {
/* set word length */

  switch (wordlenmenu.option) {
    case 1:
      termwordlength=WordLength7;
      break;

    case 2:
      termwordlength=WordLength8;
      break;

    default:
      break;

  }
}

void parityf() {
/* select parity checking */

  switch (paritymenu.option) {
    case 1:
      termparity=NoParity;
      break;

    case 2:
      termparity=(EvenParity|ParityEnable);
      break;

    case 3:
      termparity=(OddParity|ParityEnable);

    default:
      break;
  }
}

void serialpf() {
/* select comport */
  reset8250int();
  switch (serialpmenu.option) {
    case 1:
      termcom=COM1;
      break;

    case 2:
      termcom=COM2;
      break;

    default:
      break;
  }
}

void miscf() {
/* option 4 in the horizontal menu: miscellaneous functions */
  char *f;
  int i;

  f=(char *)malloc(15);
  setwindowcolors(BLACK, WHITE, LIGHTMAGENTA);
  switch (miscmenu.option) {

    case 1:  /* save screen (image) */
      strcpy(f,"VIDEOTEX");
      if (windowgets(miscmenu.menux+30,
                     miscmenu.menuy+miscmenu.height+20, f, 8)==CR) {
	     strcat(f,".IMG");
        if (display_menu(&fsavemenu,0,1)==CR) {
	       printf("%d",fsavemenu.option);
          if (save_screen(f, fsavemenu.option-1)==1) {
	         setwindowcolors(WHITE, RED, LIGHTRED);
	         windowputs(300,160,"Cannot create image file", 1);
          }
          else {
	         windowputs(300,160,"Screen saved", 1);
	         bailout=1;
          }
        }
      }
      break;

    case 2:  /* save screen (text) */
      strcpy(f,"VIDEOTEX");
      if (windowgets(miscmenu.menux+30,
                     miscmenu.menuy+miscmenu.height+20, f, 8)==CR) {
	     strcat(f,".TXT");
        if (display_menu(&fsavemenu,0,1)==CR) {
	       if (save_text_screen(f, fsavemenu.option-1)==1) {
	         setwindowcolors(WHITE, RED, LIGHTRED);
	         windowputs(300,160,"Cannot open file", 1);
          }
          else {
	         windowputs(300,160,"Screen saved", 1);
	         bailout=1;
          }
        }
      }
      break;

    case 3:  /* print screen */
      to_print_screen=1;
      bailout=1;
      break;

    case 4:  /* view saved screen */
      strcpy(screen_to_view,"VIDEOTEX");
      if (windowgets(miscmenu.menux+30,
                     miscmenu.menuy+miscmenu.height+30,
                     screen_to_view, 8)==CR) {
        strcat(screen_to_view, ".IMG");
        to_view_screen=1;
        bailout=1;
      }
      break;

    case 5:
      strcpy(script_fname,"VIDEOTEX");
      if (windowgets(miscmenu.menux+30,
                     miscmenu.menuy+miscmenu.height+20,
                     script_fname, 8)!=ESC) {
        strcat(script_fname,".SCR");
	     exe_script=bailout=1;
      }
      break;

    default:
      break;
  }
  free(f);
}

void fsavef() {}

void print_screen() {
/* dump video page 0 to printer with background color filtered */
  extern int charheight;    /* height of each character on screen */
  unsigned char m;
  int x,y,      /* loop counters */
      j,
      msb,lsb,  /* work variables */
      q;        /* user press F10, this flag will be set */

  if (script_running) {
    setcolor(WHITE);
    outtextxy(NAME_X,STATUSLINE_Y,"Print Graph");
  }
  else {
    setfillstyle(SOLID_FILL,MAGENTA);  /* display function name on */
    bar(0, STATUSLINE_Y, 639, 349);    /* status bar */
    setcolor(WHITE);
    outtextxy(10,339,"F10 Stop");
    setcolor(LIGHTGREEN);
    outtextxy(500,STATUSLINE_Y+4,"PRINT SCREEN");
  }

  lsb=640 &  0x00ff;  /* number of bytes to be sent to printer */
  msb=640 >> 8;

  biosprint(1,0,0); /* initialize printer */
  j=q=0;
  while (j<328 && !q) {
    if (bioskey(1)!=0)
      if (bioskey(0)==FK10)
	     q=1;
    biosprint(0,ESC,0);
    biosprint(0,'*',0);
    biosprint(0,2,0);
    biosprint(0,lsb,0);
    biosprint(0,msb,0);

    x=0;
    while (x<640 && !q) {   /* for each 8-pixel row */
      if (bioskey(1)!=0)
	     if (bioskey(0)==FK10)
	       q=1;
      m=y=0;
      while (y<8 && !q) {   /* print all column in each */
	     m<<=1;
        if (getpixel(x,j+y)!=bkg[x/16][(j+y)/charheight])
	       m++;
        y++;
      }
      biosprint(0,m,0);
      x++;
    }
    biosprint(0,CR,0);
    biosprint(0,ESC,0);
    biosprint(0,74,0);
    biosprint(0,25,0);
    j+=8;
  }
  biosprint(0,LF,0);  /* flush printer's buffer */

  if (q) {      /* inform user abort of printing */
    setwindowcolors(WHITE, RED, WHITE);
    windowputs(100,100,"Print Screen Aborted", 1);
  }
  if (script_running) {
    setfillstyle(SOLID_FILL,MAGENTA);  /* clear function name on */
    bar(NAME_X, STATUSLINE_Y, NAME_X+200, 349);    /* status bar */
  }
  else
    show_status();
}

void draw_logo() {
/* draw the opening screen of this program */
  int x, y, i;
  int c[]= {535,285,543,285,543,290,535,290,535,295,549,295,544,300,
            530,300,530,290,535,285};
  int p[]= {550,275,565,275,565,285,560,290,552,290,552,285,
            560,285,560,280,550,280,550,293,545,293,545,280,550,275};

  /* text logo */
  for (i=1;i>=0;i--) {
    setactivepage(i);

    /* display product name */
    setcolor(MAGENTA);
    rectangle(40,40,getmaxx()-40, getmaxy()-40);
    setcolor(GREEN);
    settextstyle(TRIPLEX_FONT,HORIZ_DIR,10);
    outtextxy(65,80, "VideoTex");
    settextstyle(TRIPLEX_FONT,HORIZ_DIR,5);
    setcolor(CYAN);
    outtextxy(250,200, "Emulator");

    setcolor(WHITE);  /* show author name */
    settextstyle(DEFAULT_FONT,HORIZ_DIR,0.1);
    outtextxy(getmaxx()-250,275,"CHAN Ming-lap");
    outtextxy(getmaxx()-250,285,"CHANG Man-wai");
    settextstyle(DEFAULT_FONT,HORIZ_DIR,3);
    setcolor(WHITE);

    /* draw CPHK's badge */
    setcolor(LIGHTGREEN);
    setfillstyle(SOLID_FILL,LIGHTGREEN);
    fillpoly(13,p);
    setcolor(LIGHTCYAN);
    setfillstyle(SOLID_FILL,LIGHTCYAN);
    fillpoly(10,c);
  }
}

void load_config() {
/* load the configuration file for this program */
  int i, j, h, l;

  if ((configfile=fopen("VIDEOTEX.CFG","rb"))==NULL) {
    setwindowcolors(WHITE,GREEN,LIGHTGREEN);
    windowputs(200,200,"Creating VIDEOTEX.CFG..", 1);
    init_config();
  }
  else {
    for (i=0;i<10;++i) {
      for (j=0;j<21;++j)
	     phonedir.description[i][j]=fgetc(configfile);

      for (j=0;j<11;++j)
        phonedir.phonenumber[i][j]=fgetc(configfile);

      l=(int)fgetc(configfile);
      h=(int)fgetc(configfile)<<8;
      phonedir.baudrate[i]=h|l;
      phonedir.stopbit[i]=fgetc(configfile);
      phonedir.wordlength[i]=fgetc(configfile);
      phonedir.parity[i]=fgetc(configfile);
    }
    for (j=0;j<41;++j) modeminit[j]=fgetc(configfile);
    for (j=0;j<21;++j) modemhangup[j]=fgetc(configfile);
    for (j=0;j<21;++j) modemreset[j]=fgetc(configfile);
    for (j=0;j<21;++j) modemconnect[j]=fgetc(configfile);
    for (j=0;j<21;++j) modembusy[j]=fgetc(configfile);
    for (j=0;j<21;++j) dialprefix[j]=fgetc(configfile);

    l=(int)fgetc(configfile);
    h=(int)fgetc(configfile)<<8;
    termbaudrate=h|l;
    termwordlength=fgetc(configfile);
    termparity=fgetc(configfile);
    termstopbit=fgetc(configfile);
    termlocalecho=fgetc(configfile);
    termcom=fgetc(configfile);
    l=(int)fgetc(configfile);
    h=(int)fgetc(configfile)<<8;
    dialtime=h|l;
    for (i=0;i<10;i++) {
       for (j=0;j<11;j++) macrolist.name[i][j]=fgetc(configfile);
       for (j=0;j<11;j++) macrolist.content[i][j]=fgetc(configfile);
    }

    fclose(configfile);
  }
}

void save_config() {
/* save configuration file */
  int i, j;

  if ((configfile=fopen("VIDEOTEX.CFG","wb"))==NULL) {
    printf("Error writing configuration file.");
    _exit(2);
  }
  else {
    for (i=0;i<10;++i) {
      for (j=0;j<21;++j) fputc(phonedir.description[i][j], configfile);
      for (j=0;j<11;++j) fputc(phonedir.phonenumber[i][j], configfile);
        fputc(phonedir.baudrate[i], configfile);     /* lo-byte */
        fputc(phonedir.baudrate[i]>>8, configfile);  /* hi-byte */
        fputc(phonedir.stopbit[i], configfile);
        fputc(phonedir.wordlength[i], configfile);
        fputc(phonedir.parity[i], configfile);
    }
    for (j=0;j<41;++j) fputc(modeminit[j], configfile);
    for (j=0;j<21;++j) fputc(modemhangup[j], configfile);
    for (j=0;j<21;++j) fputc(modemreset[j], configfile);
    for (j=0;j<21;++j) fputc(modemconnect[j], configfile);
    for (j=0;j<21;++j) fputc(modembusy[j], configfile);
    for (j=0;j<21;++j) fputc(dialprefix[j], configfile);

    fputc(termbaudrate, configfile);     /* lo-byte */
    fputc(termbaudrate>>8, configfile);  /* hi-byte */
    fputc(termwordlength, configfile);
    fputc(termparity, configfile);
    fputc(termstopbit, configfile);
    fputc(termlocalecho, configfile);
    fputc(termcom, configfile);
    fputc(dialtime, configfile);
    fputc(dialtime>>8, configfile);
    for (i=0;i<10;i++) {
       for (j=0;j<11;j++) fputc(macrolist.name[i][j],configfile);
       for (j=0;j<11;j++) fputc(macrolist.content[i][j], configfile);
    }
    fclose(configfile);
  }
}

void init_config() {
/* create the configuration file if not found */
  int i;

  strcpy(modeminit,"ATS0=0M1Q0E1X3|");
  strcpy(modemhangup,"~~~+++~~~ATH0|");
  strcpy(modemreset,"ATZ|");
  strcpy(modemconnect,"CONNECT");
  strcpy(modembusy,"BUSY");
  strcpy(dialprefix,"ATDT");
  termbaudrate=1200;
  termwordlength=WordLength7;
  termparity=EvenParity|ParityEnable;
  termstopbit=OneStopBit;
  termlocalecho=0;
  termcom=COM1;
  dialtime=30;

  for (i=0;i<10;++i){
    strcpy(phonedir.description[i],"Erase Me");
    strcpy(phonedir.phonenumber[i],"1234567");
    phonedir.baudrate[i]=2400;
    phonedir.stopbit[i]=OneStopBit;
    phonedir.parity[i]=NoParity;
    phonedir.wordlength[i]=WordLength8;
  }
  strcpy(macrolist.name[0],"Main menu"); strcpy(macrolist.content[0],"*0#");
  strcpy(macrolist.name[1],"Get p11"); strcpy(macrolist.content[1],"*11#");
  strcpy(macrolist.name[2],"Logoff"); strcpy(macrolist.content[2],"*90#");
  strcpy(macrolist.name[3],"Cancel"); strcpy(macrolist.content[3],"**");
  strcpy(macrolist.name[4],"Get last"); strcpy(macrolist.content[4],"*#");
  for (i=5;i<10;i++) {
     strcpy(macrolist.name[i],"Example");
     strcpy(macrolist.content[i],"?????");
  }
}

void init_menu() {
/* define the fields of each pull down menu */
  int j;

  /* main menu */
  modemmenu.title="Modem";
  modemmenu.prevmenu=NULL;
  modemmenu.nextmenu=&dialmenu;
  modemmenu.noofentry=6;
  modemmenu.entry[0]="Init String";
  modemmenu.entry[1]="Connect String";
  modemmenu.entry[2]="Busy String";
  modemmenu.entry[3]="Reset String";
  modemmenu.entry[4]="Hang Up String";
  modemmenu.entry[5]="Dial Prefix";
  modemmenu.titlex=20;
  modemmenu.titley=0;
  modemmenu.menux=20;
  modemmenu.menuy=20;
  modemmenu.width=150;
  modemmenu.height=75;
  modemmenu.func=modemf;

  /* dialing menu */
  dialmenu.title="Dial";
  dialmenu.prevmenu=&modemmenu;
  dialmenu.nextmenu=&termmenu;
  dialmenu.noofentry=5;
  dialmenu.entry[0]="Dialing Dir";
  dialmenu.entry[1]="Manual Dial";
  dialmenu.entry[2]="Hang Up";
  dialmenu.entry[3]="Reset Modem";
  dialmenu.entry[4]="Waiting Time";
  dialmenu.titlex=140;
  dialmenu.titley=0;
  dialmenu.menux=140;
  dialmenu.menuy=20;
  dialmenu.width=120;
  dialmenu.height=65;
  dialmenu.func=dialf;

  termmenu.title="Terminal";
  termmenu.prevmenu=&dialmenu;
  termmenu.nextmenu=&miscmenu;
  termmenu.noofentry=6;
  termmenu.entry[0]="Local Echo";
  termmenu.entry[1]="Baud Rate";
  termmenu.entry[2]="Stop Bit";
  termmenu.entry[3]="Word Length";
  termmenu.entry[4]="Parity";
  termmenu.entry[5]="Serial Port";
  termmenu.titlex=260;
  termmenu.titley=0;
  termmenu.menux=260;
  termmenu.menuy=20;
  termmenu.width=120;
  termmenu.height=75;
  termmenu.func=termf;

  miscmenu.title="Misc";
  miscmenu.prevmenu=&termmenu;
  miscmenu.nextmenu=NULL;
  miscmenu.noofentry=5;
  miscmenu.entry[0]="Save Screen (Image)";
  miscmenu.entry[1]="Save Screen (Text)";
  miscmenu.entry[2]="Print Screen (Image)";
  miscmenu.entry[3]="View Saved Image";
  miscmenu.entry[4]="Execute Script";
  miscmenu.titlex=380;
  miscmenu.titley=0;
  miscmenu.menux=380;
  miscmenu.menuy=20;
  miscmenu.width=180;
  miscmenu.height=65;
  miscmenu.func=miscf;

  fsavemenu.prevmenu=&termmenu;
  fsavemenu.nextmenu=NULL;
  fsavemenu.noofentry=2;
  fsavemenu.entry[0]="Append to original";
  fsavemenu.entry[1]="Overwrite original";
  fsavemenu.menux=380;
  fsavemenu.menuy=100;
  fsavemenu.width=180;
  fsavemenu.height=30;
  fsavemenu.func=fsavef;

  localmenu.nextmenu=localmenu.prevmenu=NULL;
  localmenu.noofentry=2;
  (localmenu.entry[0]="On");
  (localmenu.entry[1]="Off");
  localmenu.menux=termmenu.menux+50;
  localmenu.menuy=termmenu.menuy+CHAR_HEIGHT+4;
  localmenu.titlex=260;
  localmenu.titley=0;
  localmenu.width=100;
  localmenu.height=30;
  localmenu.func=localf;

  baudmenu.nextmenu=baudmenu.prevmenu=NULL;
  baudmenu.noofentry=4;
  baudmenu.entry[0]="1200";
  baudmenu.entry[1]="2400";
  baudmenu.entry[2]="4800";
  baudmenu.entry[3]="9600";
  baudmenu.menux=termmenu.menux+50;
  baudmenu.menuy=termmenu.menuy+2*CHAR_HEIGHT+4;
  baudmenu.width=100;
  baudmenu.height=50;
  baudmenu.titlex=260;
  baudmenu.titley=0;
  baudmenu.func=baudf;

  stopbitmenu.nextmenu=stopbitmenu.prevmenu=NULL;
  stopbitmenu.noofentry=2;
  stopbitmenu.entry[0]="1";
  stopbitmenu.entry[1]="2";
  stopbitmenu.menux=termmenu.menux+50;
  stopbitmenu.menuy=termmenu.menuy+3*CHAR_HEIGHT+4;
  stopbitmenu.width=100;
  stopbitmenu.height=30;
  stopbitmenu.titlex=260;
  stopbitmenu.titley=0;
  stopbitmenu.func=stopbitf;

  wordlenmenu.nextmenu=wordlenmenu.prevmenu=NULL;
  wordlenmenu.noofentry=2;
  wordlenmenu.entry[0]="7";
  wordlenmenu.entry[1]="8";
  wordlenmenu.menux=termmenu.menux+50;
  wordlenmenu.menuy=termmenu.menuy+4*CHAR_HEIGHT+4;
  wordlenmenu.width=100;
  wordlenmenu.height=30;
  wordlenmenu.titlex=260;
  wordlenmenu.titley=0;
  wordlenmenu.func=wordlenf;

  paritymenu.nextmenu=paritymenu.prevmenu=NULL;
  paritymenu.noofentry=3;
  paritymenu.entry[0]="None";
  paritymenu.entry[1]="Even";
  paritymenu.entry[2]="Odd";
  paritymenu.menux=termmenu.menux+50;
  paritymenu.menuy=termmenu.menuy+5*CHAR_HEIGHT+4;
  paritymenu.width=100;
  paritymenu.height=40;
  paritymenu.titlex=260;
  paritymenu.titley=0;
  paritymenu.func=parityf;

  serialpmenu.nextmenu=serialpmenu.prevmenu=NULL;
  serialpmenu.noofentry=2;
  serialpmenu.entry[0]="COM 1";
  serialpmenu.entry[1]="COM 2";
  serialpmenu.menux=termmenu.menux+50;
  serialpmenu.menuy=termmenu.menuy+6*CHAR_HEIGHT+4;
  serialpmenu.width=100;
  serialpmenu.height=30;
  serialpmenu.titlex=260;
  serialpmenu.titley=0;
  serialpmenu.func=serialpf;
}

void show_macros() {
/* display macro list */
  int i,tx,ty;

  settextstyle(DEFAULT_FONT, HORIZ_DIR, 0);
  setcolor(WHITE);
  tx=100+4;
  ty=150+CHAR_HEIGHT+3;
  for (i=0;i<10;++i){
    outtextxy(tx+4,ty,macrolist.name[i]);
    outtextxy(tx+CHAR_WIDTH*12+2,ty,macrolist.content[i]);
    ty+=CHAR_HEIGHT;
  }
}

void change_macros() {
/* modify macro list */
  void *oldscreen;             /* storage for old screen */
  int i, keypressed, option=0, /* flags */
      tx=100, ty=150,          /* location of hi-light bar */
      looping=1,               /* flags */
      send_macro=0;            /* indicate whether a macro is to be sent */

  setvisualpage(0);
  setactivepage(0);
  /* create the window */
  setwindowcolors(WHITE, DARKGRAY, BROWN);
  oldscreen=openwindow(tx, ty, CHAR_WIDTH*25+2, CHAR_HEIGHT*11+4);
  setcolor(YELLOW);
  outtextxy(105, 154," Note       Content");

  /* status bar */
  setfillstyle(SOLID_FILL,MAGENTA);
  bar(0, STATUSLINE_Y, 639, 349);
  setcolor(LIGHTGREEN);
  outtextxy(550,339, "MACRO");
  setcolor(WHITE);
  outtextxy(10, 339, "F9 Edit  RETURN Send");

  show_macros();
  ty=ty+CHAR_HEIGHT;
  while (looping) {

    /* show bar */
    show_bar(tx+4,ty,CHAR_WIDTH*25-8,CHAR_HEIGHT);
    keypressed=inkey2();
    show_bar(tx+4,ty,CHAR_WIDTH*25-8,CHAR_HEIGHT);

    switch (keypressed) {

      case ESC:
        looping=0;
        break;

      case UP_ARROW:     /* move the cursor up one choice */
        option=option-1;
        if (option<0)
          option=9;
        break;

      case DOWN_ARROW:   /* move the cursor down one choice */
        option=option+1;
        if (option>9)
          option=0;
        break;

      case CR:   /* send the hi-lighted macro */
        looping=0;
	     send_macro=1;
        break;

      case FK09: /* edit the hi-lighted macro */
        setwindowcolors(BLACK,LIGHTGRAY,BROWN);
	     intextxy(tx+8,ty+2,macrolist.name[option],10);
	     intextxy(tx+CHAR_WIDTH*12+6,ty+2,
                 macrolist.content[option],10);
	     setwindowcolors(WHITE,DARKGRAY,BROWN);

	     /* erase old entries */
	     setfillstyle(SOLID_FILL, DARKGRAY);
	     bar(tx+4,ty,tx+CHAR_WIDTH*25-8,ty+CHAR_HEIGHT);
	     show_macros();
	     break;

      default:
        break;
    }
    ty=150+(option+1)*CHAR_HEIGHT;
  }
  closewindow(100, 150, oldscreen);
  if (send_macro)     /* macro sent out after closing the window */
    sendstring(macrolist.content[option]);
}

void menu_statusline() {
  setfillstyle(SOLID_FILL,MAGENTA);
  bar(0, STATUSLINE_Y, 639, 349);
  setcolor(LIGHTGREEN);
  outtextxy(570,339,"MENU");
}

void change_dialdir() {
/* display and modify dialing directory or dial from it */
  void *oldscreen;
  int tx,ty,                 /* location of hi-light bar */
      keypressed, option, i, /* flags */
      looping, to_dial,      /* flags */
      oldx, oldy;            /* old location of the vertical menus */

  setwindowcolors(WHITE, DARKGRAY, BROWN);
  oldscreen=openwindow(dialmenu.menux+3,
                       dialmenu.menuy+CHAR_HEIGHT*2-2,
		       CHAR_WIDTH*50+2, CHAR_HEIGHT*11+4);
  setcolor(YELLOW);
  outtextxy(dialmenu.menux+5, dialmenu.menuy+CHAR_HEIGHT*2,
	    "  Name                 Phone     Baud Wl Sp Pa");

  /* status line */
  setfillstyle(SOLID_FILL,MAGENTA);
  bar(0, STATUSLINE_Y, 639, 349);
  setcolor(LIGHTGREEN);
  outtextxy(480,339, "DIALING DIRECTORY");
  setcolor(WHITE);
  outtextxy(10, 339, "F9 Edit  RETURN Dial");

  show_dialdir();
  option=0;
  tx=dialmenu.menux+5;
  ty=dialmenu.menuy+CHAR_HEIGHT*3;
  looping=1;
  to_dial=0;
  while (looping) {

    /* show bar */
    show_bar(tx+4,ty,CHAR_WIDTH*50-8,CHAR_HEIGHT);
    keypressed=inkey2();
    show_bar(tx+4,ty,CHAR_WIDTH*50-8,CHAR_HEIGHT);

    switch (keypressed) {

      case ESC:
       looping=0;
       break;

      case UP_ARROW:     /* move the cursor up one choice */
        option=option-1;
        if (option<0)
          option=9;
        break;

      case DOWN_ARROW:   /* move the cursor down one choice */
        option=option+1;
        if (option>9)
          option=0;
        break;

      case CR:   /* perform the function specified by the menu */
        looping=0;
        to_dial=1;
        break;

      case FK09:  /* modify hi-lighted directory entry */
        setwindowcolors(BLACK, LIGHTGRAY, YELLOW);
	     intextxy(tx+CHAR_WIDTH+4,ty+2,
	  	           phonedir.description[option],20);
	     intextxy(tx+CHAR_WIDTH*22+2,ty+2,
		           phonedir.phonenumber[option],10);

        setwindowcolors(WHITE, DARKGRAY, YELLOW);
	     oldx=baudmenu.menux;  /* display the vertical menu at different */
	     oldy=baudmenu.menuy;  /* location, so save the old locations */
	     baudmenu.menux=tx+CHAR_WIDTH*33+2;
	     baudmenu.menuy=ty+2;
	     switch (phonedir.baudrate[option]) {
	       case 1200: i=display_menu(&baudmenu, 0, 1);
		               break;
          case 2400: i=display_menu(&baudmenu, 0, 2);
		               break;
          case 4800: i=display_menu(&baudmenu, 0, 3);
		               break;
          case 9600: i=display_menu(&baudmenu, 0, 4);
		               break;
	     }
	     switch (baudmenu.option) {
          case 1: phonedir.baudrate[option] = 1200;
		            break;
          case 2: phonedir.baudrate[option] = 2400;
		            break;
          case 3: phonedir.baudrate[option] = 4800;
		            break;
          case 4: phonedir.baudrate[option] = 9600;
		            break;
	     }
	     baudmenu.menux=oldx; baudmenu.menuy=oldy;

	     oldx=wordlenmenu.menux;
	     oldy=wordlenmenu.menuy;
	     wordlenmenu.menux=tx+CHAR_WIDTH*38+2;
	     wordlenmenu.menuy=ty+2;
	     if (phonedir.wordlength[option]==WordLength7)
	       i=display_menu(&wordlenmenu, 0, 1);
        else
	       i=display_menu(&wordlenmenu, 0, 2);
        if (i != ESC)
          phonedir.wordlength[option] = (wordlenmenu.option==1) ?
				                             WordLength7 : WordLength8;
        wordlenmenu.menux=oldx; wordlenmenu.menuy=oldy;

        oldx=stopbitmenu.menux; oldy=stopbitmenu.menuy;
	     stopbitmenu.menux=tx+CHAR_WIDTH*41+2;
	     stopbitmenu.menuy=ty+2;
	     if (phonedir.stopbit[option]==OneStopBit)
	       i=display_menu(&stopbitmenu, 0, 1);
        else
	       i=display_menu(&stopbitmenu, 0, 2);
        if (i != ESC)
	       phonedir.stopbit[option] = (stopbitmenu.option==1) ?
				                         OneStopBit : TwoStopBits;
        stopbitmenu.menux=oldx; stopbitmenu.menuy=oldy;

	     oldx=paritymenu.menux;
	     oldy=paritymenu.menuy;
	     paritymenu.menux=tx+CHAR_WIDTH*44+2;
	     paritymenu.menuy=ty+2;
	     if (phonedir.parity[option]==NoParity)
	       i=display_menu(&paritymenu, 0, 1);
        else if (phonedir.parity[option]==(EvenParity|ParityEnable))
	       i=display_menu(&paritymenu, 0, 2);
        else
          i=display_menu(&paritymenu, 0, 3);
        if (i!=ESC)
	       switch (paritymenu.option) {
	         case 1:  phonedir.parity[option]=NoParity;
		               break;
            case 2:  phonedir.parity[option]=(EvenParity|ParityEnable);
		               break;
            default: phonedir.parity[option]=(OddParity|ParityEnable);
          }
        paritymenu.menux=oldx; paritymenu.menuy=oldy;

	     /* erase old entry on screen */
	     setfillstyle(SOLID_FILL, DARKGRAY);
	     bar(tx+4,ty,tx+CHAR_WIDTH*50-8,ty+CHAR_HEIGHT);
	     show_dialdir();
	     break;

      default:
        break;
    }
    ty=dialmenu.menuy+CHAR_HEIGHT*3+option*CHAR_HEIGHT;
  }
  closewindow(dialmenu.menux+3, dialmenu.menuy+CHAR_HEIGHT*2-2, oldscreen);
  menu_statusline();
  if (to_dial) {
    termbaudrate   = phonedir.baudrate[option];
    termwordlength = phonedir.wordlength[option];
    termparity     = phonedir.parity[option];
    termstopbit    = phonedir.stopbit[option];
    setcombaud(termbaudrate);
    setwordlen(termwordlength);
    setparity (termparity);
    setstopbit(termstopbit);
    dial(phonedir.description[option], phonedir.phonenumber[option], 0);
  }
}

void show_dialdir() {
/* display dialing directory */
  int i,
      tx, ty;  /* location of hi-light bar */
  char *a;

  a=(char *)malloc(7);
  settextstyle(DEFAULT_FONT, HORIZ_DIR, 0);
  setcolor(WHITE);
  tx=dialmenu.menux+5;
  ty=dialmenu.menuy+CHAR_HEIGHT*3+2;
  for (i=0;i<10;++i){
    outtextxy(tx+CHAR_WIDTH+4,ty,phonedir.description[i]);
    outtextxy(tx+CHAR_WIDTH*22+2,ty,phonedir.phonenumber[i]);
    itoa(phonedir.baudrate[i],a,10);
    outtextxy(tx+CHAR_WIDTH*33+2,ty,a);
    if (phonedir.wordlength[i]==WordLength7)
      outtextxy(tx+CHAR_WIDTH*38+2,ty,"7");
    else
      outtextxy(tx+CHAR_WIDTH*38+2,ty,"8");

    if (phonedir.stopbit[i]==OneStopBit)
      outtextxy(tx+CHAR_WIDTH*41+2,ty,"1");
    else
      outtextxy(tx+CHAR_WIDTH*41+2,ty,"2");

    if (phonedir.parity[i]==(EvenParity|ParityEnable))
      outtextxy(tx+CHAR_WIDTH*44+2,ty,"Even");
    else if (phonedir.parity[i]==(OddParity|ParityEnable))
      outtextxy(tx+CHAR_WIDTH*44+2,ty,"Odd");
    else
      outtextxy(tx+CHAR_WIDTH*44+2,ty,"None");
    ty+=CHAR_HEIGHT;
  }
  free(a);
}
