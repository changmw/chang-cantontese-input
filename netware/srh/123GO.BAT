  @echo off
  @echo Loading 1-2-3 Go! ...
  F:
  home
  :LOTUS23
  echo Loading Lotus 1-2-3 2.3 ...
  COPY F:\LIB\123R23\123.EX_     123.EXE > nul
  COPY F:\LIB\123R23\LICENSE.00_ LICENSE.000 > nul
  if not exist 123.CNF COPY F:\LIB\123R23\SYS123.CNF 123.CNF > nul

  append F:\LIB\HG23;F:\LIB\CWI;F:\LIB\123r23
  MAP INS S1:= SYS:LIB\123R23

  rem user supplied mode
  If "%1" == ""   GoTo AUTO
  if  %1  == VGA  Goto 123VGA
  if  %1  == vga  Goto 123VGA
  if  %1  == MONO Goto 123MONO
  if  %1  == mono Goto 123MONO

  :AUTO
  rem auto detect graphics devices
  getgraph
  if errorlevel 9 goto 123VGA
  if errorlevel 7 goto 123MONO

  :123NONE
  echo No Graphics
  123 -clearn123
  goto 123CONT

  :123VGA
  echo VGA mode
  123 vga -clearn123
  goto 123CONT

  :123MONO
  echo Hercules mode
  123 mono -clearn123

  :123CONT
  home
  if exist 123.EXE     DEL 123.EXE > nul
  if exist LICENSE.000 DEL LICENSE.000 > nul
  if exist 123.CNF     DEL 123.CNF > nul
  MAP DEL S1:
