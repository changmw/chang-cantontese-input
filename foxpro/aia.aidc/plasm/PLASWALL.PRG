parameters M_VERSION
*
* display the wall paper personal lines systems
* adapted from Jonathan Tam's wall paper window
* Copyright AIDCHK, 1993
*
* A light shadow is created by painting a shadow at (y+100,x+100)
* for any word (y,x)
*
  activate screen
  set color to RGB(,,,192,192,192)
  clear
  @ 4.554, 4 SAY (LOCFILE("aia.bmp","BMP|ICO", "Where is aia.bmp?")) BITMAP ;
          SIZE 14.062,22.001 ;
          STRETCH ;
          STYLE "T"

  @ 5.408,28.100 SAY "PLAS"  ;
          FONT "Arial", 64 ;
          STYLE "BT" ;
          COLOR RGB(0,0,0,,,,)
  @ 5.308,28 SAY "PLAS"  ;
          FONT "Arial", 64 ;
          STYLE "BT" ;
          COLOR RGB(0,0,255,,,,)

  @ 14.615,25 SAY "PERSONAL LINES ADMINISTRATION SYSTEM"  ;
          FONT "Arial", 11 ;
          STYLE "BT" ;
          COLOR RGB(255,0,0,,,,)

  @ 16.211,34 SAY "Version "+M_VERSION ;
          FONT "Arial", 11 ;
          STYLE "T" ;
          COLOR RGB(0,0,128,,,,)

* black title
  @ 27.562,15.180 SAY "(c) Copyright 1993  American International Data Centre Limited"  ;
          FONT "MS Sans Serif", 8 ;
          STYLE "BT" ;
          COLOR RGB(0,0,0)
* white title
  @ 27.462,15.000 SAY "(c) Copyright 1993  American International Data Centre Limited"  ;
          FONT "MS Sans Serif", 8 ;
          STYLE "BT" ;
          COLOR RGB(255,255,255,128,128,128)
* black title
  @ 28.946,15.180 SAY "All Rights Reserved."  ;
          FONT "MS Sans Serif", 8 ;
          STYLE "BT" ;
          COLOR RGB(0,0,0)
* white title
  @ 28.846,15.000 SAY "All Rights Reserved."  ;
          FONT "MS Sans Serif", 8 ;
          STYLE "BT" ;
          COLOR RGB(255,255,255,128,128,128)
  set color to
return
