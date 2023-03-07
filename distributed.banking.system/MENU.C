/*
   CS1291 Banking System
   Menu Manager of DDB Front End
   Author: Chang Man Wai (91xxxxxx)
*/
#include <stdio.h>
#include <curses.h>
#include <string.h>
#include <stdlib.h>

#include "menu.h"

#define MENU_WIDTH 25

int bailout=0;  /* if set, exit from pull-down menu immediately */

/*
  place a text on the given coordinate (x,y) on screen 
*/
outtextxy(x, y, s)
int x, y;
char *s;
{
  mvprintw(y,x,"%s",s);
  refresh();
}

openmenu(p)
MENU *p;
{
  /* display the menu and its options */
  int i;

  for (i=0;i<(p->noofentry);++i) outtextxy(p->menux+2,p->menuy+i+1,p->entry[i]);
}

show_bar(x, y, i)
int x, y, i;
{
  outtextxy(x,y," ");
}

int intextxy(x, y, o, length, echo)
int x, y, length, echo;
char *o;
{
  /* prompt user to input a string at location (x,y) */
  char s[80], i;
  int sp, k, clearfield;

  /* initialize stack for holding user input string */
  strcpy(s,o);

  if (echo)
    outtextxy(x,y,s);
  else 
    for (k=0;k<strlen(s);k++) outtextxy(x+k,y, "*");

  for (k=strlen(s);k<length;++k) outtextxy(x+k,y, ".");

  sp=strlen(s)-1;                 /* intialize stack pointer */
  clearfield=1;
  while ((i=getch())!=K_ESC) {
    if ((i==K_ENTER) || (i==K_CTRL_W)) {
      strcpy(o, s);
      return(i);    /* Exit loop */
    }
    else if (i==K_BS) {    /* backspace pops a character out */
      clearfield=0;
      sp=((sp-1)< -1) ? -1 : (sp-1);
      *(s+sp+1)='\0';
      outtextxy(x+(sp+1),y,".");
    }
    else if (character(i)) {
      if (clearfield) {
        sp=(-1);
        for (k=0;k<length;k++) outtextxy(x+k,y, ".");
        clearfield=0;
      }
      if ((sp+1) < length ) {
        sp++;
        *(s+sp)=i;              /* push a character into the stack */
        *(s+sp+1)='\0';
        if (echo)
          outtextxy(x+sp,y,s+sp);
        else
          outtextxy(x+sp,y,"*");
      }
    }
    refresh();
  }
  return(K_ESC);
}

int innumberxy(x, y, o, length)
int x, y, *o, length;
{
  /* prompt user to input an integer at location (x,y) */
  char s[80], i;
  int sp, k, clearfield;

  /* initialize stack for holding user input string */
  itoa(*o,s);

  outtextxy(x,y,s);
  for (k=strlen(s);k<length;++k) outtextxy(x+k,y, ".");

  sp=strlen(s)-1;                 /* intialize stack pointer */
  clearfield=1;
  while ((i=getch())!=K_ESC) {
    if (i==K_ENTER) {
      *o=atoi(s);
      return(K_ENTER);    /* exit loop */
    }
    if (i==K_BS) {    /* backspace pops a character out */
      clearfield=0;
      sp=((sp-1)< -1) ? -1 : (sp-1);
      *(s+sp+1)='\0';
      outtextxy(x+(sp+1),y,".");
    }
    if (number(i)) {
      if (clearfield) {
        sp=(-1);
        for (k=0;k<length;k++) outtextxy(x+k,y, ".");
        clearfield=0;
      }
      if ((sp+1) < length ) {   /* the number of char to get is length */
        *(s+(++sp))=i;          /* push a character into the stack */
        *(s+sp+1)='\0';
         outtextxy(x+sp,y, s+sp);
      }
    }
  }
  return(K_ESC);
}

int windowgets(x, y, o, length)
int x, y, length;
char *o;
{
  /* pop up a window and accepts a string from user */
  WINDOW *w;
  int i;

  w=newwin(3, length+10, y, x);
  box(w,'|','-');
  i=intextxy(x+5, y+1, o, length);
  free(w);
  return(i);
}

windowputs(x, y, o, hold)
int x, y, hold;
char *o;
{
/* display a message inside a window on screen */
  WINDOW *b;
  int i;

  b=newwin(3, strlen(o), y, x);
  outtextxy(x+5,y+1,o);
  if (hold) sleep(1);
  free(b);
}

int display_menu(p, hold, firstopt)
MENU *p;
int hold, firstopt;
{
  /* show the menu and perform the function user specified */
  int i, tx, ty, keypressed, looping;

  p->option=firstopt;
  tx=p->menux+1;
  ty=p->menuy+(firstopt-1)+1;

  openmenu(p);
  looping=1;
  while (looping) {
    show_bar(tx,ty,p->option);
    keypressed=getch();
    show_bar(tx,ty,p->option);

    switch (keypressed) {
      case K_ESC:
        looping=0;
        break;

      case KEY_UP:     /* move the cursor up one choice */
        if ((--p->option)<1) p->option=p->noofentry;
        break;

      case KEY_DOWN:   /* move the cursor down one choice */
        if ((++p->option)>p->noofentry) p->option=1;
        break;

      case K_ENTER:           /* perform the function specified by the menu */
        show_bar(tx,ty,p->option);
        p->func();
        show_bar(tx,ty,p->option);
        if (!hold||bailout) looping=0;
        break;
      default:
        continue;
    }
    ty=p->menuy+(p->option-1)*1+1;
  }
  closemenu(p);
  return(keypressed);
}

closemenu(p)
WINDOW *p;
{
  free(p);
}

int number(i)
int i;
{
  switch (i) {
    case '.':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '0': return(1);
    default: return(0);
  }
}

clear_window(y1,x1,y2,x2)
int x1,y1,x2,y2;
{
   int x, y;
   char s[80+1];

   s[0]=0;
   for (x=x1;x<x2+1;x++) strcat(s," ");
   for (y=y1;y<y2+1;y++) {
       mvprintw(y,x1,s);
       refresh();
   }
}

int character(i)
int i;
{
  if ((('a'<=i) && (i<='z'))|| (('A'<=i) && (i<='Z'))||
      (('0'<=i) && (i<='9'))|| (' '==i)  || (i=='.'))
    return(1);
  else
    return(0);
}

