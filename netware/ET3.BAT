@echo off
echo Loading ETen Chinese System 3.0 ששש
echo [Using Big-5 code]
append
H:
CD \LIB\ET3

rem user-supplied mode
If "%1" == ""   GoTo DETECT
if  %1  == EGA  Goto ETEGA
if  %1  == ega  Goto ETEGA
if  %1  == VGA  Goto ETVGA
if  %1  == vga  Goto ETVGA
if  %1  == MONO Goto ETMONO
if  %1  == mono Goto ETMONO


:DETECT
getgraph > NUL
if errorlevel 9 goto ETEGA
if errorlevel 7 goto ETMONO
if errorlevel 5 goto ETEGA
if errorlevel 4 goto ETEGA
if errorlevel 3 goto ETEGA
goto ERR

:ETEGA
vmode ega
ET16E /l16:0/b16:1/l:0/b:1
goto ETCONT

:ETVGA
vmode vga
ET16V-16 /l16:0/b16:1/l:0/b:1
goto ETCONT

:ETMONO
ETN /L16:0/B16:1/L:0/B:1

:ETCONT
echo loading input methods and printer setup...
ETINMD /CJ=CHANGJEI.TAB,XUSRCJ.TBL /PH=PHRASE.BOX
PR24D /P10
goto EXIT

:ERR
@echo
@echo :
@echo :  Sorry, you cannot run ET Chinese System because of lack of or
@echo :  inappropriate graphics hardware. You need a EGA/VGA/Hercules
@echo :  monitor.
@echo :
pause

:EXIT
echo :
echo : To remove ET Chinese System, execute the command KILLET
echo :
F:
home
