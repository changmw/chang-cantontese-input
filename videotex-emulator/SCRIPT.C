/*
  Parser of the script lanaguage of the Videotex Emulator
  the script execution will be aborted by pressing a key.
  This program is a part of the Videotex Emulator main program.
  Author: Chang Man Wai
*/
#include <alloc.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <graphics.h>

#include "keyboard.h"
#include "commngr.h"
#include "windmngr.h"
#include "videotex.h"
#include "script.h"
#include "pm.h"

int script_CONNECT=0, script_running=0;
static int cmd,          /* command flag */
           iffail,       /* flag, set if the IF failed */
			  linenumber,   /* line number for the script */
			  loopbegin,    /* the line number of the LOOP statement */
			  loopcount,    /* the number of times the loop executed */
			  loopcountmax; /* maximum execution times for LOOP */

static long alarminterval,  /* alarm every ? seconds */
            starttime;      /* time last alarm is tested */

static char fbuf[101],   /* buffer for reading script statements */
            arg1[101],   /* first argumnet of the command */
            arg2[101],   /* second argumnet of the command */
            r[1024];     /* text buffer for WAIT command */

void execute_script(char *fname) {
/* execute the script */
  int i, waitchar;
  char *a, c[fbufsize], v;
  FILE *f;

  if ((f=fopen(fname, "rb"))==NULL) {
    setwindowcolors(WHITE,RED,LIGHTRED);
    windowputs(200,200,"Script not found",1);
  }
  else {
    script_running=1;
    linenumber=loopcountmax=0;

    for (i=0;i<2;i++) {
      setactivepage(i);
      setfillstyle(SOLID_FILL,MAGENTA);   /* status bar */
      bar(0, STATUSLINE_Y, 639, 349);
      setcolor(WHITE);
      outtextxy(10,339,"F10 Stop");
      setcolor(LIGHTGREEN);
      outtextxy(550,339,"SCRIPT");
    }

    loopbegin=-1;
    while (fgets(fbuf,100,f)!=NULL) {

      if (bioskey(1)!=0)   /* F10 will stop the script's execution */
        if (bioskey(0)==FK10) {
          setactivepage(0);
			 setwindowcolors(WHITE,RED,WHITE);
			 windowputs(200,200,"Script aborted",1);
          break;
		  }

      parse_command_line(); /* split each script statement into command, */
                            /* and arguments */
	   switch (cmd) {        /* perform the action of the script command */

	     case LOOP:
		    if (arg1!=NULL)
            loopcountmax=atoi(arg1); /* set number of times to loop */
            loopbegin=linenumber;    /* record starting point of loop */
            loopcount=0;             /* number of times loop executed */
          break;

         case EXITLOOP:             /* exit current loop */
           if (loopbegin!=-1) {     /* there is pending LOOP statement */
             while (fgets(fbuf,100,f)!=NULL) {
               linenumber++;
               parse_command_line();
               if (cmd==ENDLOOP)
                 break;
             }
           }
           break;

	     case ENDLOOP:            /* end of the loop */
	       if ((loopcountmax==0) ||
              ((loopcountmax>0) && (++loopcount<loopcountmax))) {
	         fclose(f);              /* go back to the LOOP statement */
	         f=fopen(fname,"rb");
	         linenumber=0;
	         fgets(fbuf,100,f);
		      while (linenumber!=loopbegin) {
			     fgets(fbuf,100,f);
			     linenumber++;
            }
            linenumber--;
           }
           else
             loopbegin=-1;
           break;

        case SEND:     /* send arg1 to host */
	       i=sendstring(arg1);
	       break;

        case SLEEP:    /* terminal sleep for arg1 seconds */
	       sleep(atoi(arg1));
	       break;

        case DIAL:     /* dial arg1, redial arg2 times */
	       dial("Script",arg1,atoi(arg2));
	       break;

        case SHOW:     /* show stored image arg1 */
	       strcat(arg1,".IMG");
	       i=view_screen(arg1);
	       break;

        case CAPTURE:  /* save screen to image arg1 */
	       strcat(arg1, ".IMG");
	       i=save_screen(arg1,atoi(arg2));
	       break;

        case WAIT:     /* wait for a string from host */
          waitchar=1;
          ri=0;
          while ((bioskey(1)==0) && waitchar) {
            if (receivechar(&v)) {
              *(r+(ri++))=v;
              *(r+ri)='\0';
              if (index(strupr(r),strupr(arg1))!=0)
                waitchar=ri=0;
            }
          }
          break;

        case ALARM:                 /* set alarm */
	       alarminterval=(long)atoi(arg1)*18.2;
	       starttime=biostime(0,0);
	       break;

        case IF:
          if (strcmp(arg1,"ALARMRING")==0) {
            if (labs(starttime-biostime(0,0)) < alarminterval)
              iffail=1; /* not yet time out, IF failed */
            else {
              iffail=0;
	           starttime=biostime(0,0);  /* record succeed time */
            }
          }
          else if (strcmp(arg1,"CONNECT")==0)
            iffail=!script_CONNECT;
          if (iffail)   /* IF-condition failed, skip to ELSE or ENDIF */
            while (fgets(fbuf,100,f)!=NULL) {
              parse_command_line();
              if ((cmd==ELSE) || (cmd==ENDIF))
                break;
              linenumber++;
            }
          break;

        case ELSE:
          if (!iffail) {  /* last IF succeed, skip to ENDIF */
            while (fgets(fbuf,100,f)!=NULL) {
              parse_command_line();
              if (cmd==ENDIF)
                break;
              linenumber++;
            }
          }
          break;

        case ENDIF:
	       break;

        default:
          break;
      }  /* end of switch */
      linenumber++;
    }
    fclose(f);
  }
  script_running=0;
  show_status();
}

void substr(char *source, int s, int n, char *target) {
/* this procedure extracts a part of a given string into a new string
   example: substr("abcde",2,2,a), a="bc" */
  int i,j;

  j=0; i=s;
  while (j<n)
    target[j++]=source[i++];
  target[j]='\0';
}

void parse_command_line() {
/* this procedure will separate a script statement into command
   and arguments using spaces and delimiters */
  char s[fbufsize];

  addnull();
  nextword(arg2, nextword(arg1, nextword(s,  0)));
  if (strcmp(s,"LOOP")==0)
    cmd=LOOP;
  else if (strcmp(s,"ENDLOOP")==0)
    cmd=ENDLOOP;
  else if (strcmp(s,"IF")==0)
    cmd=IF;
  else if (strcmp(s,"ELSE")==0)
    cmd=ELSE;
  else if (strcmp(s,"ENDIF")==0)
    cmd=ENDIF;
  else if (strcmp(s,"ALARM")==0)
    cmd=ALARM;
  else if (strcmp(s,"WAIT")==0)
    cmd=WAIT;
  else if (strcmp(s,"SEND")==0)
    cmd=SEND;
  else if (strcmp(s,"SLEEP")==0)
    cmd=SLEEP;
  else if (strcmp(s,"DIAL")==0)
    cmd=DIAL;
  else if (strcmp(s,"SHOW")==0)
    cmd=SHOW;
  else if (strcmp(s,"CAPTURE")==0)
    cmd=CAPTURE;
  else if (strcmp(s,"EXITLOOP")==0)
    cmd=EXITLOOP;
  else
    cmd=BADCOMMAND;
/*  printf("$%s~%s~%s~%d$\n",s,arg1,arg2,cmd);  debug */
}

int nextword(char *s, int i) {
/* extract a word from a statement starting at position i */
  int j,k;

  for (k=i;(fbuf[k]==' ') && (fbuf[k]!=NULL);k++); /* skip leading spaces */
  j=k;
  for (k=k;(fbuf[k]!=' ') && (fbuf[k]!=NULL);k++); /* get word */
  substr(fbuf,j,k-j,s);
  return k;
}

void addnull() {
/* replace the carriage return and line feed characters with null to
   signify the end of string */
  int i;

  i=0;
  while (i<fbufsize) {
    if ((fbuf[i]==CR) || (fbuf[i]==LF))
      fbuf[i]=NULL;
    i++;
  }
}

long labs(long a) {
/* return absolute value of a long type value */
  if (a<0)
    return -a;
  else
    return a;
}
