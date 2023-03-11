/*

          Module : Presentation Manager

          by Chan Ming Lap

          1989-90
*/
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <graphics.h>

#include "pm.h"
#include "windmngr.h"
#include "draw.h"
#include "keyboard.h"
#include "script.h"

char  ALPHA_CHAR[11][14] =         /* Bit pattern of Prestel specific characters
                                      not defined in IBM Character Set BIOS */
   { 0x18,0x24,0x60,0x60,0xF0,0x60,0x60,0x60,0x60,0x66,0xFC,0,0,0, 
     0,0,0,0,0,0,0x3C,0x3C,0,0,0,0,0,0,                      
     0,0,0xC0,0xC4,0xC8,0xD0,0x20,0x4C,0x92,4,8,0x1E,0,0,    
     0,0,0,0,0x10,0x10,0x10,0x10,0x10,0x10,0,0,0,0,          
     0,0,0x66,0x66,0xFF,0x66,0x66,0x66,0xFF,0x66,0x66,0,0,0, 
     0,0,0,0,0,0,0xFF,0,0,0,0,0,0,                         
     0,0,0xC0,0xC4,0xC8,0xD0,0x20,0x4E,0x96,0x3E,6,6,0,0,    
     0,0,0,0,0x18,0x18,0x18,0x18,0x18,0x18,0,0,0,0,          
     0,0xC0,0x20,0xE4,0x28,0xD0,0x20,0x4E,0x96,0x3E,6,6,0,0,
     0,0,0,0,0x18,0x18,0x7E,0x18,0x18,0,0,0,0,0,             
     0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
   };

char  CONT_MOSAIC_CHAR[64][16] =   /* Bit pattern of Contiguous Mosaic Character set */
   { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0,0,0,0,0,0,0,
     0x0F,0x0F,0x0F,0x0F,0x0F,0,0,0,0,0,0,0,0,0,0,0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0,0,0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0,0,0,
     0xF,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0,0,0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0,0,0,
     0,0,0,0,0,0xF,0xF,0xF,0xF,0,0,0,0,0,0,0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0,0,0,0,0,0,0,
     0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0,0,0,0,0,0,0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0,0,0,0,0,0,0,
     0,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0,0,0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0,0,0,
     0xF,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0,0,0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0,0,0, /* 20-2F */
     0,0,0,0,0,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF,0xF,0xF,0xF,0xF,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0,0,0,0,0,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xF,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0, 
     0,0,0,0,0,0,0,0,0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF,0xF,0xF,0xF,0xF,0,0,0,0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0,0,0,0,0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xF,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0xF,0xF,0xF, 
     0,0,0,0,0,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF,0xF,0xF,0xF,0xF,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0,0,0,0,0,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF,0xF,0xF,0xF,0xF,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0,0,0,0,0,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0,0,0,0,0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF0,0xF0,0xF0,0xF0,0xF0,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xF,0xF,0xF,0xF,0xF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
     0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF}; 

char SEPA_MOSAIC_CHAR[64][16]=  /* Bit pattern of separated mosaic characters */
   { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0x60,0x60,0x60,0,0,0,0,0,0,0,0,0,0,0,
     0,0,6,6,6,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0x66,0x66,0x66,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0x60,0x60,0x60,0,0,0,0,0,0,0,
     0,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,0,0,0,0,0,0,
     0,0,6,6,6,0,0x60,0x60,0x60,0,0,0,0,0,0,0,
     0,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,0,0,0,0,0,0,
     0,0,0,0,0,0,6,6,6,0,0,0,0,0,0,0,
     0,0,0x60,0x60,0x60,0,6,6,6,0,0,0,0,0,0,0,
     0,0,6,6,6,0,6,6,6,0,0,0,0,0,0,0,
     0,0,0x66,0x66,0x66,0,6,6,6,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0x66,0x66,0x66,0,0,0,0,0,0,0,
     0,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,0,0,0,0,0,0,
     0,0,6,6,6,0,0x66,0x66,0x66,0,0,0,0,0,0,0,
     0,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,0,0,0,0,0,0, 
     0,0,0,0,0,0,0,0,0,0,0x60,0x60,0x60,0,0,0,
     0,0,0x60,0x60,0x60,0,0,0,0,0,0x60,0x60,0x60,0,0,0,
     0,0,6,6,6,0,0,0,0,0,0x60,0x60,0x60,0,0,0,
     0,0,0x66,0x66,0x66,0,0,0,0,0,0x60,0x60,0x60,0,0,0,
     0,0,0,0,0,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,0,0,
     0,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,0,0,
     0,0,6,6,6,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,0,0,
     0,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,0,0,
     0,0,0,0,0,0,6,6,6,0,0x60,0x60,0x60,0,0,0,
     0,0,0x60,0x60,0x60,0,6,6,6,0,0x60,0x60,0x60,0,0,0,
     0,0,6,6,6,0,6,6,6,0,0x60,0x60,0x60,0,0,0,
     0,0,0x66,0x66,0x66,0,6,6,6,0,0x60,0x60,0x60,0,0,0,
     0,0,0,0,0,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,0,0,
     0,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,0,0,
     0,0,6,6,6,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,0,0,
     0,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,0,0, 
     0,0,0,0,0,0,0,0,0,6,6,6,0,0,0,
     0,0,0x60,0x60,0x60,0,0,0,0,0,6,6,6,0,0,0,
     0,0,6,6,6,0,0,0,0,0,6,6,6,0,0,0,
     0,0,0x66,0x66,0x66,0,0,0,0,0,6,6,6,0,0,0,
     0,0,0,0,0,0,0x60,0x60,0x60,0,6,6,6,0,0,0,
     0,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,6,6,6,0,0,0,
     0,0,6,6,6,0,0x60,0x60,0x60,0,6,6,6,0,0,0,
     0,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,6,6,6,0,0,0,
     0,0,0,0,0,0,6,6,6,0,6,6,6,0,0,0,
     0,0,0x60,0x60,0x60,0,6,6,6,0,6,6,6,0,0,0,
     0,0,6,6,6,0,6,6,6,0,6,6,6,0,0,0,
     0,0,0x66,0x66,0x66,0,6,6,6,0,6,6,6,0,0,0,
     0,0,0,0,0,0,0x66,0x66,0x66,0,6,6,6,0,0,0,
     0,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,6,6,6,0,0,0,
     0,0,6,6,6,0,0x66,0x66,0x66,0,6,6,6,0,0,0,
     0,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,6,6,6,0,0,0, 
     0,0,0,0,0,0,0,0,0,0,0x66,0x66,0x66,0,0,0,
     0,0,0x60,0x60,0x60,0,0,0,0,0,0x66,0x66,0x66,0,0,0,
     0,0,6,6,6,0,0,0,0,0,0x66,0x66,0x66,0,0,0,
     0,0,0x66,0x66,0x66,0,0,0,0,0,0x66,0x66,0x66,0,0,0,
     0,0,0,0,0,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,0,0,
     0,0,0x60,0x60,0x60,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,0,0,
     0,0,6,6,6,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,0,0,
     0,0,0x66,0x66,0x66,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,0,0,
     0,0,0,0,0,0,6,6,6,0,0x66,0x66,0x66,0,0,0,
     0,0,0x60,0x60,0x60,0,6,6,6,0,0x66,0x66,0x66,0,0,0,
     0,0,6,6,6,0,6,6,6,0,0x66,0x66,0x66,0,0,0,
     0,0,0x66,0x66,0x66,0,6,6,6,0,0x66,0x66,0x66,0,0,0,
     0,0,0,0,0,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,0,0,
     0,0,0x60,0x60,0x60,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,0,0,
     0,0,6,6,6,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,0,0,
     0,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,0x66,0x66,0x66,0,0,0}; 

int    i,j;                      /* Loop counters */
int    row=0;                    /* current row position */
int    col=0;                    /* current column position */
int    mosaic_type = CONTIGUOUS; /* Mosaic character type, when screen_mode=MOSAIC */
int    screen_size = NORMAL;     /* Current screen size, NORMAL or DOUBLE */
int    screen_mode = ALPHA;      /* Current screen mode, ALPHA or MOSAIC */
int    current_mode= STANDARD;   /* Current mode, STANDARD or CHINESE */
int    alpha_color = WHITE;      /* Current alpha character color */
int    mosaic_color = WHITE;     /* Current mosaic character color */
int    curr_bkg = BLACK;         /* Current background color */
int    hidden = OFF;             /* Flag to hide 2nd line of DOUBLE mode, if any */
int    flash = OFF;              /* Flag to indicate whether flash mode is on */
int    conceal = OFF;            /* Flag to indicate whether concealed mode is on */
int    last_conceal = OFF;       /* Flag to indicate whether the concealed characters are displayed */
int    view_conceal = OFF;       /* Flag to indicate whether concealed characters are visible */
int    blinking=0;               /* Flag to control the blinking page */
char   c;                        /* Character received for processing */
int    bkg[40][24];              /* Array to store the background colour of the screen */
int    lastdouble=OFF;           /* Flag to indicate whether the last line is double */
int    lastesc=OFF;              /* Flag to check whether the last character received is an escape */
int    lastchin=OFF;             /* Flag to check whether the last character received
				    is the first byte of a chinese character */
int    chinese_special=OFF;      /* Flag to indicate whether the second popular character base is chosen */
int    hold_mosaic=OFF;          /* Flag to define whether hold mosaic mode is set */
char   hold_mosaic_char=' ';     /* Variable to store the hold mosaic character, if hold
                                    mosaic mode is set */
char   chin_code1;               /* The first byte of a Chinese character */
unsigned int code;               /* Internal code (BIG-5) of the Chinese character */
int b,k;                         /* b= mask bit, k= loop counter */
long offset,offset2;             /* Offsets to get the bit pattern of the Chinese character
				    in the Chinese character bit image file */
FILE   *chinese_file1, *chinese_file2; /* Chinese character base files */
int    activepage=0;             /* Current active page */
int    charheight=14;

struct                           /* Structure for screen buffer */
{ char data;
  int row,col;
  int mosaic_type;
  int screen_size;
  int screen_mode;
  int alpha_color;
  int mosaic_color;
  int curr_bkg;
  int hidden;
  int flash;
  int lastdouble;
  int lastesc;
  int lastchin;
  int chinese_special;
  int hold_mosaic;
  char hold_mosaic_char;
} page[1000], current_attr;

char   textpage[1000];           /* Array to store the current page (with control
                                    characters removed */
int    pagelen=0;                /* Page length of the current page */
int    textpagelen=0;            /* Page length of the current page (text only) */


void flashing()
/*
   This procedure toggles the visual page of the screens, which produces
   the blinking effect.
   This procedure is called twice a second and toggles the visual page,
   thus produces a blinking effect.


   Input parameters : None

   Return value     : None

*/
{
    setvisualpage(blinking);           /* Toggle the active screen to create the blinking effect */
}


void clear_attributes()
/*
   This procedure clears all attributes to default values.
   This procedure is called after the end of a line, a line feed, a line up,
   or a clear screen command.


   Input parameters : None

   Return value     : None

*/
{
   screen_size = NORMAL;
   screen_mode = ALPHA;
   alpha_color = WHITE;
   mosaic_color = WHITE;
   curr_bkg = BLACK;
   mosaic_type = CONTIGUOUS;
   lastdouble=OFF;
   flash=OFF;
   lastchin=OFF;
   conceal=OFF;
   hold_mosaic=OFF;
   hold_mosaic_char=' ';
}


void charin(char c)
/*
   This procedure interprets the incoming character.
   This procedure is called when a character is received from the communication
   port.


   Input parameters : The character to interpret

   Return value     : None

*/
{
  char lastc;
  void *b;

  if ((unsigned char)c>(char)0x7f)   /* Display a DEL character if input character is out of range */
     c=(char)0x7f;
  if (view_conceal==OFF)             /* Stores the atrributes in the buffer if not in display conceal mode */
  {
     page[pagelen].data=c;           /* Stores the character in the buffer */
     page[pagelen].mosaic_type=mosaic_type;
     page[pagelen].screen_size=screen_size;
     page[pagelen].screen_mode=screen_mode;
     page[pagelen].alpha_color=alpha_color;
     page[pagelen].mosaic_color=mosaic_color;
     page[pagelen].curr_bkg=curr_bkg;
     page[pagelen].hidden=hidden;
     page[pagelen].flash=flash;
     page[pagelen].lastdouble=lastdouble;
     page[pagelen].lastesc=lastesc;
     page[pagelen].lastchin=lastchin;
     page[pagelen].chinese_special=chinese_special;
     page[pagelen].hold_mosaic=hold_mosaic;
     page[pagelen].hold_mosaic_char=hold_mosaic_char;
     page[pagelen].row=row;
     page[pagelen++].col=col;
  }

  /* Drawing primitives by Chang Man Wai */
  /********************** MY DRAW *******************************/
  if (circle_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_CIRCLE) {
      my_circle();
      setactivepage(activepage);
      circle_on=draw_para_rxd=0;
    }
  }
  else if (rectangle_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_RECTANGLE) {
      my_rectangle();
      setactivepage(activepage);
      rectangle_on=draw_para_rxd=0;
    }
  }
  else if (point_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_POINT) {
      my_point();
      setactivepage(activepage);
      point_on=draw_para_rxd=0;
    }
  }
  else if (fill_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_FILL) {
      my_fill();
      setactivepage(activepage);
      fill_on=draw_para_rxd=0;
    }
  }
  else if (line_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_LINE) {
      my_line();
      line_on=draw_para_rxd=0;
    }
  }
  else if (arc_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_ARC) {
      my_arc();
      arc_on=draw_para_rxd=0;
    }
  }
  else if (inc_set_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_INC_SET) {
      set_draw_cursor();
      inc_set_on=draw_para_rxd=0;
    }
  }
  else if (inc_point_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_INC_POINT) {
      my_point();
      setactivepage(activepage);
      draw_para_rxd=0;
    } else if (c==INCREMENTAL_POINT)
      inc_point_on=draw_para_rxd=0;
  }
  else if (inc_line_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_INC_LINE) {
      my_inc_line();
      setactivepage(activepage);
      draw_para_rxd=0;
    }
    else if (c==INCREMENTAL_LINE)
      inc_line_on=draw_para_rxd=0;
  }
  else if (inc_arc_on) {
    draw_para[draw_para_rxd++]=c;
    if (draw_para_rxd==N_INC_ARC) {
      my_inc_arc();
      setactivepage(activepage);
      draw_para_rxd=0;
    }
    else if (c==INCREMENTAL_ARC)
      inc_arc_on=draw_para_rxd=0;
  }
  /******************************* MY DRAW *********************/

  else if (lastesc)     /* If last character is an ESC, perform the escape sequence */
  {
    setactivepage(0);
    activepage=0;
    do_escape_seq(c);   /* Perform the escape sequence if last character received is an ESC */
    setactivepage(1);
    activepage=1;
    if (view_conceal==OFF)               /* Store the character if the user is not revealing concealed characters */
       textpage[textpagelen++]=' ';
    if ((screen_mode==MOSAIC)&&(hold_mosaic))
       outchar(col,row,screen_size,hold_mosaic_char); /* Display the hold mosaic character if in hold mosaic mode */
    else
       outchar(col,row,screen_size,' '); /* Output a blank in the second page for the escape sequence */
  }
  else
  {
    switch (c)          /* Interpret the incoming character if it is not an ESC */
    {
       case ESC   : lastesc=ON; /* Set the flag to indicate an ESC is received */
		    break;
       case DC_ON : break;
       case DC_OFF: break;
       case APB: if (!((col==0)&&(row==0))) /* Backspace only if not in home position */
		 {
		    col=((col+39)%40);      /* Minus col by 1 */
		    if (col==39)            /* If original position in first column, */
		       row-=1;              /* go up one row */
		 };
                 break;
       case APF: col=((col+1)%40);
		 if (col==0)                /* If original position in last column, */
                    row=((row+1)%24);       /* go down one row */
                 break;
       case APD: if (view_conceal==OFF)
		    textpage[textpagelen++]=c;
		 row=((row+1)%24);          /* Go down one row */
                 hidden=OFF;
                 if (lastdouble)            /* Set current line to hidden if last row is Double size */
                    hidden=ON;
                 clear_attributes();
                 break;
       case APU: row=((row+23)%24);         /* Go up one row */
                 hidden=OFF;
                 if (lastdouble)
                    hidden=ON;
                 clear_attributes();
                 break;
       case CS : setactivepage(1);          /* Clear screen */
		           b=save_statusline();
		           cleardevice();
		           restore_statusline(b);
		           b=save_statusline();
  		           setactivepage(0);
                 cleardevice();
		           restore_statusline(b);
		           for (i=0;i<40;i++)         /* Clear background colour array */
                    for (j=0;j<24;j++)
                       bkg[i][j]=BLACK;
                 row=0;
                 col=0;
		           clear_attributes();        /* Reset all attributes */
		           current_mode=STANDARD;
		           last_conceal=OFF;
		           page[0].data=NULL;
		           page[0].row=0;
		           page[0].col=0;
                 pagelen=0;
                 textpage[0]=NULL;
                 textpagelen=0;
                 charheight=14;
                 break;
       case APR: if (view_conceal==OFF)
		           textpage[textpagelen++]=c;
                 if ((!hidden)&&(curr_bkg!=BLACK))   /* Fill remaining columns of line */
                    for (i=0;i<2;i++)                /* in current background colour if */
                    {                                /* current line is not hidden and */
                       setactivepage(i);             /* background colour not black */
                       setfillstyle(SOLID_FILL,curr_bkg);
                       if (!lastdouble)              /* Normal height */
                       {
                          bar(col*8*2,row*charheight,639,(row+1)*charheight-1);
                          for (j=col;j<40;j++)
                             bkg[j][row]=curr_bkg;
                       }
                       else
               	       {                             /* Double height */
                          bar(col*8*2,row*charheight,639,(row+2)*charheight-1);
                          for (j=col;j<40;j++)
                          {
                             bkg[j][row]=curr_bkg;
                             bkg[j][row+1]=curr_bkg;
                          }
                       }
                    }
                 col=0;
                 break;
       case APH: if ((!hidden)&&(curr_bkg!=BLACK))   /* Fill remaining columns in current background */
                   for (i=0;i<2;i++)
	           {
                      setactivepage(i);
	              setfillstyle(SOLID_FILL,curr_bkg);
	              if (!lastdouble)
                      {
	                 bar(col*8*2,row*14,639,row*14+13);
                         for (j=col;j<40;j++)
                            bkg[j][row]=curr_bkg;
                      }
	              else
                      {
	                 bar(col*8*2,row*14,639,row*14+27);
                         for (j=col;j<40;j++)
                         {
                            bkg[j][row]=curr_bkg;
                            bkg[j][row+1]=curr_bkg;
                         }
                      }
                   }
                 row=0;
		 col=0;
                 clear_attributes();
		 break;
       case NUL: break;
       case ENQ: break;
       default : if (view_conceal==OFF)
		    if (screen_mode==ALPHA)
		       textpage[textpagelen++]=c; /* The character is interpreted as a display
						     character if it is not a control character */
		    else
		       textpage[textpagelen++]=' ';
		 if ((screen_mode==CHINESE)&&(c!=' ')) /* CHINESE mode */
		    if ((!lastchin)&&!((conceal)&&(last_conceal==OFF)))       /* Store character as first byte */
		    {                                  /* If last character is not the first byte and */
		       chin_code1=c-33;                /* not in concealed mode */
                       lastchin=ON;
                    }
                    else                    /* Display Chinese character if the */
                    {                       /* first byte had already received last time */
                       lastchin=OFF;
                       setactivepage(0);
		       activepage=0;
		       outchar(col,row,screen_size,c); /* Display the character on the screen */
                       setactivepage(1);
		       activepage=1;
                       outchar(col,row,screen_size,c);
                    }
                 else
		 {                              /* Output the character (ALPHA or MOSAIC) */
		    setactivepage(0);
		    activepage=0;
		    outchar(col,row,screen_size,c);
		    setactivepage(1);
		    activepage=1;
		    if (flash)                             /* Output a space in the second page */
		       outchar(col,row,screen_size,' ');   /* if the flashing mode is on        */
		    else
		       outchar(col,row,screen_size,c);
                 }
    }
  }
}

void do_escape_seq(char c)
/*
   This procedure performs the escape sequence according to the input character.
   This procedure is called if the last character received is an ESCAPE and
   a new character is received from charin().


   Input parameters : The character to interpret

   Return value     : None


*/
{
    lastesc=OFF;
    switch(c) /* Perform the command according to the character code */
    {
       case ALPHA_RED      : screen_mode = ALPHA;   /* Set the screen mode and screen colour */
		             alpha_color = RED;
		             if (!hidden)
		               outchar(col,row,screen_size,' '); break;
       case ALPHA_GREEN    : screen_mode = ALPHA;
		             alpha_color = GREEN;
		             if (!hidden)
		               outchar(col,row,screen_size,' '); break;
       case ALPHA_YELLOW   : screen_mode = ALPHA;
		             alpha_color = YELLOW;
		             if (!hidden)
		               outchar(col,row,screen_size,' '); break;
       case ALPHA_BLUE     : screen_mode = ALPHA;
		             alpha_color = BLUE;
		             if (!hidden)
		               outchar(col,row,screen_size,' '); break;
       case ALPHA_MAGENTA  : screen_mode = ALPHA;
		             alpha_color = MAGENTA;
		             if (!hidden)
		               outchar(col,row,screen_size,' '); break;
       case ALPHA_CYAN     : screen_mode = ALPHA;
		             alpha_color = CYAN;
		             if (!hidden)
		               outchar(col,row,screen_size,' '); break;
       case ALPHA_WHITE    : screen_mode = ALPHA;
		             alpha_color = WHITE;
		             if (!hidden)
		               outchar(col,row,screen_size,' '); break;
       case MOSAIC_RED     : screen_mode = MOSAIC;
		             mosaic_color = RED;
			     if (!hidden)
			       if (hold_mosaic)
				  outchar(col,row,screen_size,hold_mosaic_char);
			       else
				  outchar(col,row,screen_size,' '); break;
       case MOSAIC_GREEN   : screen_mode = MOSAIC;
		             mosaic_color = GREEN;
		             if (!hidden)
			       if (hold_mosaic)
				  outchar(col,row,screen_size,hold_mosaic_char);
			       else
				  outchar(col,row,screen_size,' '); break;
       case MOSAIC_YELLOW  : screen_mode = MOSAIC;
		             mosaic_color = YELLOW;
		             if (!hidden)
			       if (hold_mosaic)
				  outchar(col,row,screen_size,hold_mosaic_char);
			       else
				  outchar(col,row,screen_size,' '); break;
       case MOSAIC_BLUE    : screen_mode = MOSAIC;
		             mosaic_color = BLUE;
		             if (!hidden)
			       if (hold_mosaic)
				  outchar(col,row,screen_size,hold_mosaic_char);
			       else
				  outchar(col,row,screen_size,' '); break;
       case MOSAIC_MAGENTA : screen_mode = MOSAIC;
		             mosaic_color = MAGENTA;
		             if (!hidden)
			       if (hold_mosaic)
				  outchar(col,row,screen_size,hold_mosaic_char);
			       else
				  outchar(col,row,screen_size,' '); break;
       case MOSAIC_CYAN    : screen_mode = MOSAIC;
		             mosaic_color = CYAN;
		             if (!hidden)
			       if (hold_mosaic)
				  outchar(col,row,screen_size,hold_mosaic_char);
			       else
				  outchar(col,row,screen_size,' '); break;
       case MOSAIC_WHITE   : screen_mode = MOSAIC;
		             mosaic_color = WHITE;
		             if (!hidden)
			       if (hold_mosaic)
				  outchar(col,row,screen_size,hold_mosaic_char);
			       else
				  outchar(col,row,screen_size,' '); break;

       case CHINESE_RED    : screen_mode = CHINESE;
		             alpha_color = RED;
		             if (!hidden)
			       outchar(col,row,screen_size,' ');
			     break;
       case CHINESE_GREEN  : screen_mode = CHINESE;
		             alpha_color = GREEN;
		             if (!hidden)
			       outchar(col,row,screen_size,' ');
			     break;
       case CHINESE_YELLOW : screen_mode = CHINESE;
		             alpha_color = YELLOW;
		             if (!hidden)
			       outchar(col,row,screen_size,' ');
			     break;
       case CHINESE_BLUE   : screen_mode = CHINESE;
		             alpha_color = BLUE;
		             if (!hidden)
			       outchar(col,row,screen_size,' ');
			     break;
       case CHINESE_MAGENTA: screen_mode = CHINESE;
		             alpha_color = MAGENTA;
		             if (!hidden)
			       outchar(col,row,screen_size,' ');
			     break;
       case CHINESE_CYAN   : screen_mode = CHINESE;
                             alpha_color = CYAN;
                             if (!hidden)
                                outchar(col,row,screen_size,' ');
                             break;
       case CHINESE_WHITE  : screen_mode = CHINESE;
                             alpha_color = WHITE;
                             if (!hidden)
                                outchar(col,row,screen_size,' ');
                             break;
       case FLASH : if (!hidden)
                       outchar(col,row,screen_size,' ');
                    flash=ON;       /* Turn on the flasing flag */
                    break;
       case STEADY: if (!hidden)
                       outchar(col,row,screen_size,' ');
                    flash=OFF;      /* Turn off the flashing flag */
                    break;
       case DOUBLE_HEIGHT: if (!hidden)
                           {
                              if (col!=0)              /* Backward fill the characters in the
                                                          same line with double height background */
                                for (i=0;i<col;i++)
                                  if (bkg[i][row]!=bkg[i][row+1])
                                  {
                                    bkg[i][row+1]=bkg[i][row];
                                    for (j=0;j<2;j++)
                                    {
                                      setactivepage(j);
                                      setfillstyle(SOLID_FILL,bkg[i][row]);
                                      bar(i*8*2,(row+1)*charheight,i*8*2+15,(row+2)*charheight-1);
                                    }
                                  }
                              screen_size = DOUBLE;
                              setactivepage(0);
                              outchar(col,row,screen_size,' ');
                              lastdouble = ON;
                           }
                           else
                             outchar(col,row,screen_size,' ');
                           break;
       case NORMAL_HEIGHT: if (!hidden)
                             outchar(col,row,screen_size,' ');
                           screen_size = NORMAL;
                           break;
       case CHINESE_MODE   : current_mode = CHINESE;      /* Set the display to Chinese mode */
                             charheight  = 16;            /* Set the character height to 16 pixels for Chinese characters */
                             break;
       case CHINESE_SPECIAL: chinese_special = ON;        /* Select the chinese character base
                                                             less common character set */
                             break;
       case CONCEAL : if (!hidden)
                         outchar(col,row,screen_size,' ');
                      conceal=ON;                         /* Turn on the conceal mode flag */
                      break;
       case NEW_BKG : if (!hidden)
                      {
                        if ((screen_mode==ALPHA)||(screen_mode==CHINESE))
                          curr_bkg=alpha_color;           /* Set the background color with the current color */
                        else
                          curr_bkg=mosaic_color;
                        outchar(col,row,screen_size,' ');
                      }
                      break;
       case BLACK_BKG   : curr_bkg=BLACK;                 /* Set the background color to BLACK */
                          if (!hidden)
                             outchar(col,row,screen_size,' ');
                          break;
       case CONT_MOSAIC : if (!hidden)
                          {
                            mosaic_type = CONTIGUOUS;     /* Select the contiguous mosaic character mode */
                            outchar(col,row,screen_size,' ');
                          }
                          break;
       case SEPA_MOSAIC : if (!hidden)
                          {
                            mosaic_type = SEPARATED;      /* Select the separated mosaic character mode */
                            outchar(col,row,screen_size,' ');
                          }
                          break;
       case HOLD_MOSAIC : hold_mosaic=ON;
                          if (!hidden)
                             outchar(col,row,screen_size,' ');
                          break;
       case RELEASE_MOSAIC : hold_mosaic=OFF;
                             if (!hidden)
                                outchar(col,row,screen_size,' ');
                             break;

       /* Drawing primitives by Chang Man Wai */
       /********************* MY DRAW ****************************/

       case DRAW_LINE:         line_on=1; break;
       case DRAW_RECTANGLE:    rectangle_on=1; break;
       case DRAW_POINT:        point_on=1; break;
       case DRAW_CIRCLE:       circle_on=1; break;
       case DRAW_FILL:         fill_on=1; break;
       case DRAW_ARC:	       arc_on=1; break;
       case INCREMENTAL_SET:   inc_set_on=1; break;
       case INCREMENTAL_LINE:  inc_line_on=1; break;
       case INCREMENTAL_POINT: inc_point_on=1; break;
       case INCREMENTAL_ARC:   inc_arc_on=1; break;

       /********************* MY DRAW ****************************/

       default : outchar(col,row,screen_size,127);        /* Display a blank is the escape sequence is unknown */
    }
}

void outchar(int xpos,int ypos,int size,char charsend)
/*
   This procedure outputs a character to the screen according to the current
   position on screen and the size specified. The procedure will check whether
   the current mode is CHINESE or STANDARD mode and display the character in the
   correct position on the screen.

   This procedure is called when a character to be displayed is received or
   called after performing an escape sequence and will display a blank.


   Input parameters : Coordinate of the character to display (text coordinate),
                      Size of the character to display (NORMAL or DOUBLE) and
                      the character to display

   Return value     : None


*/
{
  int i,j,t;
  int buf[2];
  char buf2[16];
  char   a;  /* char get from file */

  unsigned off,seg;

  off=FP_OFF(&buf);
  seg=FP_SEG(&buf);
  movedata(CHAR_BASE,0x010c,seg,off,4); /* Vector to BIOS character */
  if (!hidden)
  {
     if ((conceal)&&(last_conceal==OFF))
        charsend=' ';
     if ((screen_mode==ALPHA)||(charsend==' '))
     {
       switch (charsend) {
       case '#' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[0][i];
                  break;
       case '[' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[1][i];
                  break;
       case '\\' : for (i=0;i<14;i++)
                   buf2[i]=ALPHA_CHAR[2][i];
                   break;
       case ']' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[1][i];
                  break;
       case '^' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[3][i];
                  break;
       case '_' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[4][i];
                  break;
       case '`' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[5][i];
                  break;
       case '{' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[6][i];
                  break;
       case '|' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[7][i];
                  break;
       case '}' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[8][i];
                  break;
       case '~' : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[9][i];
                  break;
       case 127 : for (i=0;i<14;i++)
                  buf2[i]=ALPHA_CHAR[10][i];
                  break;
       default :  off=FP_OFF(&buf2);
                  seg=FP_SEG(&buf2);
                  movedata(buf[1],buf[0]+(int)charsend*14,seg,off,14); /* Move the bit pattern of the
                                                                          character to buf2 (14 bytes)*/
     }
     setfillstyle(SOLID_FILL,curr_bkg);   /* Fill the background with the
                                             background color before the character
                                             is displayed */
     if (size==NORMAL)
        bar(xpos*8*2,ypos*charheight,xpos*8*2+15,(ypos+1)*charheight-1);
     else
        bar(xpos*8*2,ypos*charheight,xpos*8*2+15,ypos*charheight+charheight*2-1);
     for (i=0;i<14;i++)   /* Display the character line by line on the screen
                             (total 14 lines as defined in the display BIOS,
                             the same in CHINESE and STANDARD mode  */
     {
       if (size==NORMAL)
          putcharline(xpos*8*2,ypos*charheight+i,(int)buf2[i],alpha_color);
       else
       {
         putcharline(xpos*8*2,ypos*charheight+i*2,(int)buf2[i],alpha_color);
         putcharline(xpos*8*2,ypos*charheight+i*2+1,(int)buf2[i],alpha_color);
       }
     }
  }
  else
     if (screen_mode==MOSAIC)    /* Check if currently in mosaic mode */
     {
       if (hold_mosaic)
          hold_mosaic_char=charsend;
       if (mosaic_type == CONTIGUOUS) /* Check if contiguous mosaic characters are received */
       {
          if (size==NORMAL)
          {
             setfillstyle(SOLID_FILL,curr_bkg);
             bar(xpos*8*2,ypos*charheight,xpos*8*2+15,(ypos+1)*charheight-1);
          }
          else
          {
             setfillstyle(SOLID_FILL,curr_bkg);
             bar(xpos*8*2,ypos*charheight,xpos*8*2+15,ypos*charheight+charheight*2-1);
          }
          for (i=0;i<charheight;i++) /* Display the graphics character on the screen.
                                        The bit pattern is stored in the array CONT_MOSAIC_CHAR.
                                        For STANDARD mode, only the first 14 bytes are used while
                                        in CHINESE mode, 16 bytes will be used */
          {
             if (size==NORMAL)
             {
                if (charsend<96)
                   putcharline(xpos*8*2,ypos*charheight+i,(int)CONT_MOSAIC_CHAR[(int)charsend-32][i],mosaic_color);
                else
                   putcharline(xpos*8*2,ypos*charheight+i,(int)CONT_MOSAIC_CHAR[(int)charsend-96+32][i],mosaic_color);
             }
             else
             {
                if (charsend<96)
                {
                   putcharline(xpos*8*2,ypos*charheight+i*2,CONT_MOSAIC_CHAR[charsend-32][i],mosaic_color);
                   putcharline(xpos*8*2,ypos*charheight+i*2+1,CONT_MOSAIC_CHAR[charsend-32][i],mosaic_color);
                }
                else
                {
                   putcharline(xpos*8*2,ypos*charheight+i*2,(int)CONT_MOSAIC_CHAR[charsend-96+32][i],mosaic_color);
                   putcharline(xpos*8*2,ypos*charheight+i*2+1,(int)CONT_MOSAIC_CHAR[charsend-96+32][i],mosaic_color);
                }
             }
          }
       }
       else     /* otherwise separated mosaic characters are selected */
       {
          if (size==NORMAL)
          {
             setfillstyle(SOLID_FILL,curr_bkg);
             bar(xpos*8*2,ypos*charheight,xpos*8*2+15,(ypos+1)*charheight-1);
          }
          else
          {
             setfillstyle(SOLID_FILL,curr_bkg);
             bar(xpos*8*2,ypos*charheight,xpos*8*2+15,ypos*charheight+charheight*2-1);
          }
          for (i=0;i<charheight;i++)
          {
             if (size==NORMAL)
             {
                if (charsend<96)
                   putcharline(xpos*8*2,ypos*charheight+i,(int)SEPA_MOSAIC_CHAR[(int)charsend-32][i],mosaic_color);
                else
                   putcharline(xpos*8*2,ypos*charheight+i,(int)SEPA_MOSAIC_CHAR[(int)charsend-96+32][i],mosaic_color);
             }
             else
             {
                if (charsend<96)
                {
                   putcharline(xpos*8*2,ypos*charheight+i*2,(int)SEPA_MOSAIC_CHAR[charsend-32][i],mosaic_color);
                   putcharline(xpos*8*2,ypos*charheight+i*2+1,(int)SEPA_MOSAIC_CHAR[charsend-32][i],mosaic_color);
                }
                else
                {
                   putcharline(xpos*8*2,ypos*charheight+i*2,(int)SEPA_MOSAIC_CHAR[charsend-96+32][i],mosaic_color);
                   putcharline(xpos*8*2,ypos*charheight+i*2+1,(int)SEPA_MOSAIC_CHAR[charsend-96+32][i],mosaic_color);
                }
             }
          }
       }
     }
     else /* CHINESE mode */
     {
       /* display CHINESE characters here */
       if (size==NORMAL) /* Set background color */
       {
          setfillstyle(SOLID_FILL,curr_bkg);
          bar(xpos*8*2,ypos*16,xpos*8*2+31,(ypos+1)*16-1);
       }
       else
       {
          setfillstyle(SOLID_FILL,curr_bkg);
          bar(xpos*8*2,ypos*16,xpos*8*2+31,ypos*16+charheight*2-1);
       }
       if ((flash)&&(activepage==1))  /* If in flash mode, the characters
                                         will not display on the second screen */
          for (k=0;k<15;k++)
             for (j=0;j<2;j++)
                if (size==NORMAL)
                   putcharline((xpos+j)*8*2,ypos*16+k,0,alpha_color);
                else
                {
                   putcharline((xpos+j)*8*2,ypos*16+k*2,0,alpha_color);
                   putcharline((xpos+j)*8*2,ypos*16+k*2+1,0,alpha_color);
                }
       else
       {
          offset=(unsigned int)chin_code1*95+(unsigned int)charsend-33;
          if (chinese_special)
             offset+=5401;
          if (offset<1083)     /* Select the bit pattern file according to the offset */
             t=fseek(chinese_file1,offset*15*2,SEEK_SET);
          else
             if (((!chinese_special)&&(offset<5402))||
                 ((chinese_special)&&(offset<13054)))   /* Check if the character is in valid range */
                t=fseek(chinese_file2,(offset-1083)*15*2,SEEK_SET);
          if ((t==0)&&(((!chinese_special)&&(offset<5402))||
            ((chinese_special)&&(offset<13054)))) /* Check if bit pattern is found */
             for (k=0;k<15;k++)   /* Since the bit pattern defined in the file is only
                                     15 bytes, only 15 lines will be displayed. The 16th
                                     line is left for spearator of two lines */
                for (j=0;j<2;j++)
                {
                   if (offset<1083)
                      a=getc(chinese_file1);
                   else
                      a=getc(chinese_file2);
                   if (size==NORMAL)
                      putcharline((xpos+j)*8*2,ypos*16+k,a,alpha_color);
                   else
                   {
                      putcharline((xpos+j)*8*2,ypos*16+k*2,a,alpha_color);
                      putcharline((xpos+j)*8*2,ypos*16+k*2+1,a,alpha_color);
                   }
                }
          else
             for (k=0;k<15;k++)         /* Output two blocks (DEL character) if bit pattern not found */
                for (j=0;j<2;j++)
                   if (size==NORMAL)
                      putcharline((xpos+j)*8*2,ypos*16+k,0xFF,alpha_color);
                   else
                   {
                      putcharline((xpos+j)*8*2,ypos*16+k*2,0xFF,alpha_color);
                      putcharline((xpos+j)*8*2,ypos*16+k*2+1,0xFF,alpha_color);
                   }
       }
       /* end of CHINESE routine */
     }
  }
  if (activepage==1)   /* Perform miscellaneous functions after the character
                          is received */
  {
     if (!hidden)
     {
        bkg[xpos][ypos]=curr_bkg;  /* Store the background character in an array */
        if (size==DOUBLE)
           bkg[xpos][ypos+1]=curr_bkg;
        if (screen_mode==CHINESE)    /* Store background colour for 2nd bytes of chinese char. */
           bkg[xpos+1][ypos]=curr_bkg;
     }
     if ((screen_mode==CHINESE)&&(charsend!=' ')) /* Update the cursor position */
        col=((col+2)%40);
     else
        col=((col+1)%40);
     if (col==0)
     {
       hidden=OFF;
       row=((row+1)%24);
       if (view_conceal==OFF)
       {
          textpage[textpagelen++]=APD;
          textpage[textpagelen++]=APR;
       }
       if ((screen_size==DOUBLE)||(lastdouble))
          hidden=ON;
       clear_attributes();
     }
     else
       if ((screen_mode==CHINESE)&&(col==39))
       {
          col=0;
          hidden=OFF;
          row=((row+1)%24);
          if ((screen_size==DOUBLE)||(lastdouble))
             hidden=ON;
          clear_attributes();
       }
     chinese_special=OFF;
  }
}


void putcharline(int xcord,int ycord,int bitpattern,int out_color)
/*
   procedure to display a horizontal line of a character.
   This procedure is called by outchar to display the character on the screen
   line by line.

   Input parameters : The coordinates of the line to display (graphics corrdinates),
                      the bit pattern of the line to display and
                      the colour of the line to display

   Return value     : None

*/
{
  int j;        /* Loop counter */
  int char_bit; /* Variable to calculate the positions to fill in the line */

  for (j=0,char_bit=128;j<8;j++,char_bit/=2)  /* Repeat 8 times for 8 horizontal dots of a characters */
  {
    if ((bitpattern&char_bit)!=0) /* display a dot for the bit pattern if it is so */
    {
      putpixel(xcord+j*2,ycord,out_color);
      putpixel(xcord+j*2+1,ycord,out_color);
    }
  }
}

void reveal()
/*
   procedure to display concealed characters on the screen once the
   Rev key is pressed.


   Input parameters : None

   Return value     : None


*/
{
  int k,l;

  view_conceal=ON;
  if (last_conceal)
     last_conceal=OFF;
  else
     last_conceal=ON;
  current_attr.mosaic_type=mosaic_type;
  current_attr.screen_size=screen_size;
  current_attr.screen_mode=screen_mode;
  current_attr.alpha_color=alpha_color;
  current_attr.mosaic_color=mosaic_color;
  current_attr.curr_bkg=curr_bkg;
  current_attr.hidden=hidden;
  current_attr.flash=flash;
  current_attr.lastdouble=lastdouble;
  current_attr.lastesc=lastesc;
  current_attr.lastchin=lastchin;
  current_attr.chinese_special=chinese_special;
  current_attr.hold_mosaic=hold_mosaic;
  current_attr.hold_mosaic_char=hold_mosaic_char;
  current_attr.row=row;
  current_attr.col=col;

  for (k=0;k<pagelen;k++)
  {
     if ((page[k].data==(char)ESC)&&(page[k+1].data=='X'))
     {
	mosaic_type=page[k].mosaic_type;
	screen_size=page[k].screen_size;
	screen_mode=page[k].screen_mode;
	alpha_color=page[k].alpha_color;
	mosaic_color=page[k].mosaic_color;
	curr_bkg=page[k].curr_bkg;
	hidden=page[k].hidden;
	flash=page[k].flash;
	lastdouble=page[k].lastdouble;
	lastesc=page[k].lastesc;
	lastchin=page[k].lastchin;
	chinese_special=page[k].chinese_special;
	hold_mosaic=page[k].hold_mosaic;
	hold_mosaic_char=page[k].hold_mosaic_char;
	row=page[k].row;
	col=page[k].col;
	l=k;
	while (l<pagelen)
	   charin(page[l++].data);
	k=pagelen;
     }
  }
  mosaic_type=current_attr.mosaic_type;
  screen_size=current_attr.screen_size;
  screen_mode=current_attr.screen_mode;
  alpha_color=current_attr.alpha_color;
  mosaic_color=current_attr.mosaic_color;
  curr_bkg=current_attr.curr_bkg;
  hidden=current_attr.hidden;
  flash=current_attr.flash;
  lastdouble=current_attr.lastdouble;
  lastesc=current_attr.lastesc;
  lastchin=current_attr.lastchin;
  chinese_special=current_attr.chinese_special;
  hold_mosaic=current_attr.hold_mosaic;
  hold_mosaic_char=current_attr.hold_mosaic_char;
  row=current_attr.row;
  col=current_attr.col;
  view_conceal=OFF;
  conceal=OFF;
}

int save_text_screen(char *savefile, int mode)
/*
   This function saves the text screen captured during the session to a file
   passed to the function. Two modes can be selected, overwrite or append.
   If the function performed successfully, 0 will be returned, else 1 will be returned.


   Input parameters : The address of the filename
                      the mode of the screen save (1 for overwrite, 0 for append)

   Return values    : 0 for successful
                      1 for unsuccessful

*/
{
    FILE *outfile;
    int i;

    switch (mode) {
      case 1:
	if ((outfile=fopen(savefile,"wt"))==NULL)
	  return(1);
	break;
      case 0:
	if ((outfile=fopen(savefile,"at"))==NULL)
	  return(1);
	break;
    }
    for (i=0;i<textpagelen;i++)
      fputc(textpage[i],outfile);
    fclose(outfile);
    return(0);
}

int save_screen(char *savefile, int mode)
/*
   This function saves the image screen captured during the session to a file
   passed to the function.
   If the function performed successfully, 0 will be returned, else 1 will be returned.


   Input parameters : The address of the filename

   Return values    : 0 for successful
                      1 for unsuccessful

*/
{
    FILE *outfile;
    int i;

    switch (mode) {     /* Check the mode of the saving */
      case 1:
        if ((outfile=fopen(savefile,"wb"))==NULL)
          return(1);
        break;
      case 0:
        if ((outfile=fopen(savefile,"ab"))==NULL)
          return(1);
        break;
    }
    for (i=0;i<pagelen;i++)
      fputc(page[i].data,outfile);
    fclose(outfile);
    if (!script_running) {
      setwindowcolors(WHITE,BLUE,LIGHTBLUE);
      windowputs(300,160,"Screen saved", 1);
    }
    return(0);
}

int view_screen(char *viewfile)
/*
   This function displays a saved image to the screen. The file to be viewed is passed to
   the function and the function will return 0 if successul and 1 if unsuccessful


   Input parameters : The address of the file to be viewed.

   Return value     : 0 for sucessful
                      1 for unsuccessful

*/
{
   FILE *infile;   /* File handle of the file */
   int i;
   char inchar;

   if ((infile=fopen(viewfile,"rb"))==NULL)
      return(1);
   else
   {
     /* show status bar */
     if (script_running)
       for (i=0;i<2;i++) {
         setactivepage(i);
         setcolor(LIGHTCYAN);
         outtextxy(NAME_X,STATUSLINE_Y,"VIEW SCREEN");
       }
     else
       for (i=0;i<2;i++) {
         setactivepage(i);
         setfillstyle(SOLID_FILL,MAGENTA);
         bar(0, STATUSLINE_Y, getmaxx(), getmaxy());
         setcolor(LIGHTGREEN);
         settextstyle(DEFAULT_FONT,HORIZ_DIR,0);
         outtextxy(500,STATUSLINE_Y+4,"VIEW SAVED SCREEN");
         setcolor(WHITE);
         outtextxy(10, STATUSLINE_Y+4, "F10 Quit");
       }

     charin(CS);
     while ((inchar=(char)fgetc(infile))!=EOF) {
       if (bioskey(1)!=0)
         if (bioskey(0)==FK10) {
           setwindowcolors(WHITE,BLUE,LIGHTBLUE);
           windowputs(300,160,"View screen aborted", 1);
           break;
         }
       charin(inchar);
     }
     fclose(infile);
     if (script_running)
        for (i=0;i<2;i++) {
          setfillstyle(SOLID_FILL,MAGENTA);  /* clear function name on */
          bar(NAME_X, STATUSLINE_Y, NAME_X+200, 349);    /* status bar */
        }
     else
        show_status();
     return(0);
   }
}
