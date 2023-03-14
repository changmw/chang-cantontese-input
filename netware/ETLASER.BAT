@echo off
echo Loading ETen Chinese System 3.0 (Laser Printer) ששש
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
H:\LIB\ET3\ET16E @H:\LIB\ET3
goto ETCONT

:ETVGA
vmode vga
H:\LIB\ET3\ET16V-16 @H:\LIB\ET3
goto ETCONT

:ETMONO
H:\LIB\ET3\ET16N @H:\LIB\ET3

:ETCONT
echo loading input methods and printer setup...
ETINMD /CJ=CHANGJEI.TAB,XUSRCJ.TBL
ASK "Using <B>ig-5 code or <E>Ten code", BE
IF ERRORLEVEL 2 Goto C_ETEN
IF ERRORLEVEL 1 goto C_BIG5

:C_ETEN
ETCTL /C:si3,3

:C_BIG5
PRLSR
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
