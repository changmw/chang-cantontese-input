@echo off
echo Loading ET Chinese System 2.55 for PCRAS system ...
echo Using ETen Code ...
F:
CD \LIB\HAN255
getgraph > NUL
if errorlevel 9 goto ETEGA
if errorlevel 7 goto ETMONO
if errorlevel 5 goto ETEGA
if errorlevel 4 goto ETEGA
if errorlevel 3 goto ETEGA
goto ERR

:ETVGA
HANEGA /SI3,3 /B:0 /B16:256 /U:0 /U16:0 /L:0,0,0 /L16:32,32,0 /P:6
goto ETCONT

:ETEGA
HANEGA /SI3,3 /B:0 /B16:256 /U:0 /U16:0 /L:0,0,0 /L16:32,32,0 /P:6
goto ETCONT

:ETMONO
HAN /SI3,3 /B:0 /B16:256 /U:0 /U16:0 /L:0,0,0 /L16:32,32,0 /P:6

:ETCONT
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
home
