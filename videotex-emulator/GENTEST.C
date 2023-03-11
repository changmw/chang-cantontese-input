/* generate graphics description laanguage command */
#include <stdio.h>
#include <graphics.h>
#include "draw.h"
#include "pm.h"

void pi(int a);
void pc(char a);

FILE *f;
int i,r,k;

void main() {
  if ((f=fopen("DRAW.IMG","wb"))==NULL) {
    printf("Error opening file.");
    _exit(2);
  }
  else {
    pc(CS);
    pc(ESC);pc(DRAW_ARC);pc(RED);pi(100);pi(100);pi(50);pi(75);pi(50);pi(150);

    pc(ESC);pc(DRAW_LINE);pc(RED);pi(400);pi(100);pi(500);pi(200);
    pc(ESC);pc(DRAW_POINT);pc(MAGENTA);pi(480);pi(150);

    pc(ESC);pc(INCREMENTAL_SET);pi(300);pi(100);
    pc(ESC);pc(INCREMENTAL_LINE);
    pc(LIGHTGREEN);pi(350);pi(100);
    pc(GREEN);pi(350);pi(150);
    pc(INCREMENTAL_LINE);

    pc(ESC);pc(DRAW_RECTANGLE);pc(BLUE);pi(400);pi(100);pi(500);pi(200);

    pc(ESC);pc(INCREMENTAL_POINT);
    pc(WHITE);pi(350);pi(150);
    pc(WHITE);pi(348);pi(150);
    pc(WHITE);pi(346);pi(150);
    pc(WHITE);pi(344);pi(150);
    pc(INCREMENTAL_POINT);

    pc(ESC);pc(INCREMENTAL_SET);pi(50);pi(150);
    pc(ESC);pc(INCREMENTAL_ARC);pc(WHITE);pi(75);pi(225);pi(100);pi(200);
    pc(MAGENTA);pi(125);pi(250);pi(150);pi(200);
    pc(BLUE);pi(225);pi(200);pi(200);pi(150);
    pc(GREEN);pi(200);pi(75);pi(150);pi(100);
    pc(YELLOW);pi(125);pi(50);pi(100);pi(100);
    pc(RED);pi(50);pi(75);pi(50);pi(150);
    pc(INCREMENTAL_ARC);

    pc(ESC);pc(DRAW_CIRCLE);pc(LIGHTRED);pi(125);pi(150);pi(50);

    pc(ESC);pc(INCREMENTAL_SET);pi(535);pi(285);
    pc(ESC);pc(INCREMENTAL_LINE);
    pc(GREEN);pi(543);pi(285);
    pc(GREEN);pi(543);pi(290);
    pc(GREEN);pi(535);pi(290);
    pc(GREEN);pi(535);pi(295);
    pc(GREEN);pi(549);pi(295);
    pc(GREEN);pi(544);pi(300);
    pc(GREEN);pi(530);pi(300);
    pc(GREEN);pi(530);pi(290);
    pc(GREEN);pi(535);pi(285);pc(INCREMENTAL_LINE);

    pc(ESC);pc(INCREMENTAL_SET);pi(550);pi(275);
    pc(ESC);pc(INCREMENTAL_LINE);
    pc(CYAN);pi(565);pi(275);
    pc(CYAN);pi(565);pi(285);
    pc(CYAN);pi(560);pi(290);
    pc(CYAN);pi(552);pi(290);
    pc(CYAN);pi(552);pi(285);
    pc(CYAN);pi(560);pi(285);
    pc(CYAN);pi(560);pi(280);
    pc(CYAN);pi(550);pi(280);
    pc(CYAN);pi(550);pi(293);
    pc(CYAN);pi(545);pi(293);
    pc(CYAN);pi(545);pi(280);
    pc(CYAN);pi(550);pi(275);pc(INCREMENTAL_LINE);

    pc(ESC);pc(DRAW_FILL);pc(CYAN);pc(CYAN);pi(555);pi(278);

    fclose(f);
    printf("\nDRAW.IMG written");
  }
}
void pc(char a) {
  int r;
  r=fputc(a,f);
}
void pi(int a) {
  int r;
  r=fputc(a/128, f);  /* hi-byte */
  r=fputc(a%128, f);  /* lo-byte */
}
