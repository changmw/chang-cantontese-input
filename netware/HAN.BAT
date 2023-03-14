@echo off
echo Loading Chun Han Chinese System 2.55 ...
echo Using BIG-5 code ...
F:
CD \LIB\HAN255

rem user-supplied mode
If "%1" == ""   goto DETECT
if  %1  == EGA  goto HANEGA
if  %1  == ega  goto HANEGA
if  %1  == VGA  goto HANVGA
if  %1  == vga  goto HANVGA
if  %1  == MONO goto HANMONO
if  %1  == mono goto HANMONO

:DETECT
getgraph > NUL
if errorlevel 9 goto HANEGA
if errorlevel 7 goto HANMONO
if errorlevel 5 goto HANEGA
if errorlevel 4 goto HANEGA
if errorlevel 3 goto HANEGA
goto ERR

:HANVGA
HANVGA /SI0,0 /B:0 /B16:256 /U:0 /U16:0 /L:0,0,0 /L16:1011,408,0 /P:6
goto HANCONT

:HANEGA
HANEGA /SI0,0 /B:0 /B16:256 /U:0 /U16:0 /L:0,0,0 /L16:1011,408,0 /P:6
goto HANCONT

:HANMONO
HAN /SI0,0 /B:0 /B16:256 /U:0 /U16:0 /L:0,0,0 /L16:1011,408,0 /P:6

:HANCONT
goto EXIT

:ERR
@echo
@echo :
@echo :  Sorry, you cannot run HAN Chinese System because of lack of or
@echo :  inappropriate graphics hardware. You need a EGA/VGA/Hercules
@echo :  monitor.
@echo :
pause

:EXIT
echo :
echo : To remove Chun Hon Chinese System, execute the command KILLHAN
echo :
home
