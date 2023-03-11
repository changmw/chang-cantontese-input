/*
   Functions to interpret picture description language primitives and
   perform the actions.
   Author: Chang Man Wai
   Primitives' syntax:
   LINE <color> <x1> <y1> <x2> <y2>
   RECTANGLE <color> <x1> <y1> <x2> <y2>
   POINT <color> <x> <y>
   FILL <fillcolor> <framecolor> <start x> <start y>
   CIRCLE <color> <centre x> <centre y> <radius>
   ARC <color> <x1> <y1> <x2> <y2> <x3> <y3>
               note: (x1,y1)..(x6,y6) should be in anti-clockwise direction
   INCREMENTAL_SET <start x> <start y>
   INCREMENTAL_LINE {<color> <end x> <end y>} INCREMENTAL_LINE
   INCREMENTAL_POINT {<color> <x> <y>} INCREMENTAL_POINT
   INCREMENTAL_ARC {<color> <x2> <y2> <x3> <y3>} INCREMENTAL_ARC
*/
#include <graphics.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "draw.h"

int maxx, maxy;
int line_on, circle_on, rectangle_on, point_on, fill_on, arc_on,
    inc_set_on, inc_line_on, inc_point_on, inc_arc_on;
int draw_para_rxd;
char draw_para[20], last_draw_char;
static int draw_cursorx=0, draw_cursory=0;

int char_to_int(char x, char y);
void swap(float *x, float *y);

void my_line() {
/* draw a line */
  int i;

  setcolor(draw_para[0]);
  for (i=0;i<2;i++) {
    setactivepage(i);
    line(char_to_int(draw_para[1], draw_para[2]),
         char_to_int(draw_para[3], draw_para[4]),
         char_to_int(draw_para[5], draw_para[6]),
         char_to_int(draw_para[7], draw_para[8]));
  }
}

void set_draw_cursor() {
/* set initial curosr position of incremental graphics functions */
   draw_cursorx=char_to_int(draw_para[0], draw_para[1]);
   draw_cursory=char_to_int(draw_para[2], draw_para[3]);
}

void my_inc_line() {
/* incremental line */
   int i;

   setcolor(draw_para[0]);
   for (i=0;i<2;i++) {
     setactivepage(i);
     line(draw_cursorx, draw_cursory,
	  char_to_int(draw_para[1], draw_para[2]),
	  char_to_int(draw_para[3], draw_para[4]));
   }
   draw_cursorx=char_to_int(draw_para[1], draw_para[2]);
   draw_cursory=char_to_int(draw_para[3], draw_para[4]);
}

void my_inc_point() {
/* incremental point */
  int i;

  for (i=0;i<2;i++) {
    setactivepage(i);
    putpixel(char_to_int(draw_para[1], draw_para[2]),
	     char_to_int(draw_para[3], draw_para[4]),
	     draw_para[0]);
  }
}

void my_inc_arc() {
/* incremental arc:
   use drawcursorx, drawcursory as starting point of the arc,
   set the last point of last drawn arc as the starting point of the next
   arc */
  float x2,y2,x3,y3;
  int i;

  x2=char_to_int(draw_para[1], draw_para[2]);
  y2=char_to_int(draw_para[3], draw_para[4]);
  x3=char_to_int(draw_para[5], draw_para[6]);
  y3=char_to_int(draw_para[7], draw_para[8]);
  for (i=0;i<2;i++) {
    setactivepage(i);
    draw_arc(draw_cursorx,draw_cursory,x2,y2,x3,y3,draw_para[0]);
  }
  draw_cursorx=char_to_int(draw_para[5], draw_para[6]);
  draw_cursory=char_to_int(draw_para[7], draw_para[8]);
}

void my_circle() {
/* draw a circle with the given coordinates of the centre and radius */
  int i;

  setcolor(draw_para[0]);
  for (i=0;i<2;i++) {
    setactivepage(i);
    circle(char_to_int(draw_para[1], draw_para[2]),
	   char_to_int(draw_para[3], draw_para[4]),
	   char_to_int(draw_para[5], draw_para[6]));
  }
}

void my_rectangle() {
/* draw a rectangle */
  int i;

  setcolor(draw_para[0]);
  for (i=0;i<2;i++) {
    setactivepage(i);
    rectangle(char_to_int(draw_para[1],draw_para[2]),
	      char_to_int(draw_para[3],draw_para[4]),
	      char_to_int(draw_para[5],draw_para[6]),
	      char_to_int(draw_para[7],draw_para[8]));
  }
}

void my_fill() {
/* fill an area bounded completely by lines of a given color */
  int i;

  setfillstyle(SOLID_FILL,draw_para[0]);
  for (i=0;i<2;i++) {
    setactivepage(i);
    floodfill(char_to_int(draw_para[2], draw_para[3]),
	      char_to_int(draw_para[4], draw_para[5]),
	      draw_para[1]);
  }
}

void my_point() {
/* put a dot on screen with given cooridates and color */
  int i;

  for (i=0;i<2;i++) {
    setactivepage(i);
    putpixel(char_to_int(draw_para[1],draw_para[2]),
	     char_to_int(draw_para[3],draw_para[4]),
	     draw_para[0]);
  }
}

void init_draw() {
/* intialize flags */
  line_on=rectangle_on=circle_on=fill_on=point_on=0;
  inc_set_on=inc_line_on=inc_point_on=0;
  maxx=getmaxx()-1;
  maxy=getmaxy()-1;
}

int char_to_int(char x, char y) {
/* convert two 7-bit characters to an integer */
  return(x*128+y);
}

void my_arc() {
  float x1,y1,x2,y2,x3,y3;
  int i;

  x1=char_to_int(draw_para[1], draw_para[2]);
  y1=char_to_int(draw_para[3], draw_para[4]);
  x2=char_to_int(draw_para[5], draw_para[6]);
  y2=char_to_int(draw_para[7], draw_para[8]);
  x3=char_to_int(draw_para[9], draw_para[10]);
  y3=char_to_int(draw_para[11], draw_para[12]);
  for (i=0;i<2;i++) {
    setactivepage(i);
    draw_arc(x1,y1,x2,y2,x3,y3,draw_para[0]);
  }
}

void draw_arc(float x1, float y1,
              float x2, float y2,
              float x3, float y3,
              int color) {
/* draw an arc that links the given 3 points */
/* the arc is a circle that passes the three points */
  float x, y, r, k, m1, m2, m3;

  x=findx(x1,y1,x2,y2,x3,y3);
  y=findy(x1,y1,x2,y2,x3,y3);
  r=sqrt((x-x1)*(x-x1)+(y-y1)*(y-y1));

  m1=quarter(x,y,x1,y1);
  m2=quarter(x,y,x2,y2);
  m3=quarter(x,y,x3,y3);
  setcolor(color);
  ellipse(x,y,m1,m2,r,r);
  ellipse(x,y,m2,m3,r,r);
}

float findy(float x1, float y1,
            float x2, float y2,
	    float x3, float y3) {
/* find the y-coordinate of the circle that passthru the 3 points given */
/* for drawing an arc */
  float a, b, c;

  b=(x1*x1+y1*y1-x2*x2-y2*y2)*(x2-x3);
  c=(x2*x2+y2*y2-x3*x3-y3*y3)*(x1-x2);
  a=b-c;
/*  a=-(x1*x1+y1*y1-x2*x2-y2*y2)*x3+(x 1*x1+y1*y1-x3*x3-y3*y3)*x2-
     (x2*x2+y2*y2-x3*x3-y3*y3)*x1;  */
  b=2*(y1-y2)*(x2-x3)-2*(y2-y3)*(x1-x2);
  return (b==0) ? 0 : a/b;
}

float findx(float x1, float y1,
            float x2, float y2,
            float x3, float y3) {
/* find the y-coordinate of the circle that passthru the 3 points given */
/* for drawing an arc */
  float a, b, c;

  b=(x1*x1+y1*y1-x2*x2-y2*y2)*(y2-y3);
  c=(x2*x2+y2*y2-x3*x3-y3*y3)*(y1-y2);
  a=b-c;
   b=2*(x1-x2)*(y2-y3)-2*(x2-x3)*(y1-y2);
  return (b==0) ? 0 : a/b;
}

float quarter(float x, float y, float x1, float y1) {
/* return the angle of the given point relation to the radian system of */
/* Turbo C's graphics functions */
   float m1;    /* slope  or tan x */
   float ang;   /* slope in degrees */

   m1= ((x-x1)==0) ? 0 : ((y-y1)/(x-x1));
   ang=rad_to_deg(atan(m1));
   if ((x1>x) && (y1<y)) return -ang;
   if ((x1<x) && (y1<y)) return 180-ang;
   if ((x1<x) && (y1>y)) return 180-ang;
   if ((x1>x) && (y1>y)) return 360-ang;
   if ((x==x1) && (y>y1)) return 90;
   if ((x==x1) && (y<y1)) return 270;
}

float rad_to_deg(float rad) {
/* convert radians to degrees */
  return rad*360/(2*PI);
}

void swap(float *x, float *y) {
/* swap the integers given */
  float t;
  t=*x; *x=*y; *y=t;
}
