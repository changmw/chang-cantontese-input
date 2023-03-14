#include <stdio.h>
#include <conio.h>
#include <ctype.h>

#
# Netware print queues for Survey Research Hongkong
#

void box(int,int,int,int,int,int);

void main(int argc, char **argv) {
  int key=0, row=0;
  struct text_info ti;

  box(2,1,75,22,BLACK,WHITE);
  row=3;
  gotoxy(3,row);
  cprintf("Choose printer for LPT%s",argv[1]);
  row+=2;
  gotoxy(3,row++);
  cprintf("A. [ Your desk  ]....Local");
  gotoxy(3,row++);
  cprintf("B. [ QUANTI 1+2 ]....HP-LaserJet IID .....[ A4 & F4 paper]");
  gotoxy(3,row++);
  cprintf("C. [ DP         ]....Epson LQ-1050 .......[ Label / Continous form ]");
  gotoxy(3,row++);
  cprintf("D. [ DP         ]....Angel's LQ-1050 .....[ Label / Continous form ]");
  gotoxy(3,row++);
  cprintf("E. [ DP         ]....Epson DFX-5000 ......[ Continous form ]");
  gotoxy(3,row++);
  cprintf("F. [ DP         ]....HP-LaserJet IIISi ...[ A4 paper ]");
  gotoxy(3,row++);
  cprintf("G. [ DP         ]....HP-LaserJet II ......[ used A4 paper ]");
  gotoxy(3,row++);
  cprintf("H. [ DP         ]....Printronix P300 .....[ Continuous Form ]");
  gotoxy(3,row++);
  cprintf("I. [ QUANTI 3+4 ]....HP-Plotter ..........[ A4 paper/transparency ]");
  gotoxy(3,row++);
  cprintf("J. [ QUANTI 3+4 ]....HP-PaintJet XL ......[ Special stationary ]");
  gotoxy(3,row++);
  cprintf("K. [ QUANTI 3+4 ]....HP-LaserJet III .....[ A4 paper ]");
  gotoxy(3,row++);
  cprintf("L. [ FINANCE    ]....HP-LaserJet III .....[ A4 paper ]");
  gotoxy(3,row++);
  cprintf("M. [ FINANCE    ]....Epson LQ-1050 .......[ Label / Continuous form ]");
  gotoxy(3,row+=2);
  cprintf("Your Selection -> ");
  key=toupper(getch())-'A'+1;
  if (key<0 || key >14) key=0;
  // clear screen
  box(1,1,80,25,LIGHTGRAY,BLACK);
  clrscr();
  exit(key);
}

void box(int left, int top, int right, int bottom,
			int fb_color, int bg_color) {
  int i, width, height;

  window(left,top,right,bottom);
  textcolor(fb_color);
  textbackground(bg_color);
  clrscr();

  width=right-left+1;
  height=bottom-top+1;

  /* draw corners */
  gotoxy(1,1);
  putchar('Ú');
  gotoxy(width,height);
  putchar('Ù');

  gotoxy(width,1);
  putchar('¿');
  gotoxy(1,height);
  putchar('À');

  /* draw borders */
  for (i=1;i<width-1;i++) {
	 gotoxy(i+1,top);
	 putchar('Ä');
  }
  for (i=1;i<width-1;i++) {
	 gotoxy(i+1,height);
	 putchar('Ä');
  }
  for (i=1;i<height-1;i++) {
	 gotoxy(1,i+1);
	 putchar('³');
  }
  for (i=1;i<height-1;i++) {
	 gotoxy(width,i+1);
	 putchar('³');
  }
}
