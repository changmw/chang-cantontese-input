@echo off
echo Loading Lotus 1-2-3 2.2 ...
echo Ú
echo ³ To Chinese System Users: please invoke Lotus 2.2 by
echo ³                          L123 ET
echo À
append F:\LIB\123;F:\LIB\CWI
F:
home
MAP INS S1:=SYS:LIB\123
COPY F:\LIB\123\123.EX_ 123.EXE > nul
COPY F:\LIB\123\LICENSE.00_ LICENSE.000 > nul

@echo restoring Lotus v2.2 config files
if not exist 123R22.CNF COPY F:\LIB\123\SYS123.CNF 123R22.CNF > nul
copy 123r22.CNF 123.CNF > nul

rem user-specified mode
If "%1" == ""   GoTo AUTO
if  %1  == ET   Goto 123ET
if  %1  == et   goto 123ET
if  %1  == EGA  Goto 123EGA
if  %1  == ega  Goto 123EGA
if  %1  == VGA  Goto 123VGA
if  %1  == vga  Goto 123VGA
if  %1  == MONO Goto 123MONO
if  %1  == mono Goto 123MONO

:AUTO
rem auto detect graphics devices
getgraph
if errorlevel 9 goto 123VGA
if errorlevel 7 goto 123MONO
if errorlevel 5 goto 123EGA
if errorlevel 4 goto 123EGA
if errorlevel 3 goto 123EGA

:123NONE
echo No Graphics
lotus 123
goto 123CONT

:123ET
small Chinese
small mode
lotus ET
goto 123CONT

:123EGA
echo EGA mode
lotus ega
goto 123CONT

:123VGA
echo VGA mode
lotus vga
goto 123CONT

:123MONO
echo Hercules mode
lotus mono

:123CONT
f:
home
if exist 123.EXE     DEL 123.EXE > nul
if exist LICENSE.000 DEL LICENSE.000 > nul
if exist 123.CNF     COPY 123.CNF 123r22.CNF > nul
if exist 123.CNF     DEL 123.CNF > nul
MAP DEL S1:
