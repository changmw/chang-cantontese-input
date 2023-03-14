@echo off
echo Loading ETen Chinese System For PCRAS systems ...
echo Using ETen Code...
append
F:
CD \LIB\ET22
getgraph > NUL
if errorlevel 9 goto ETVGA
if errorlevel 7 goto ETMONO
if errorlevel 5 goto ETEGA
if errorlevel 4 goto ETEGA
if errorlevel 3 goto ETEGA
goto ERR

:ETEGA
ET16E /l16:0 /b16:1 /l:0 /b:1
goto ETCONT

:ETVGA
ET16V-16 /l16:0 /b16:1 /l:0 /b:1
goto ETCONT

:ETMONO
ET /L16:0 /B16:1 /L:0 /B:1

:ETCONT
echo loading input methods and printer setup...
ETINMD /CJ=CHANGJEI.TAB,XUSRCJ.TBL
ETCTL/P:P9T24W1Z1
etctl /C:si3,3
goto EXIT

:ERR
@echo :
@echo :  Sorry, you cannot run ET Chinese System because of lack of or
@echo :  inappropriate graphics hardware. You need a EGA/VGA/Hercules
@echo :  monitor.
@echo :
pause

:EXIT
home
