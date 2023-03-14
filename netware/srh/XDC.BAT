@Echo Off
Xdskcopy %1 %2 %3 %4 %5
IF "%1"=="" GOTO END
IF "%1"=="" GOTO END
ASK "<C>opy another Master Disk or <E>xit ? ", CE
IF ERRORLEVEL 2 GOTO END
IF ERRORLEVEL 1 GOTO CONT
GOTO END

:CONT
%0 %1 %2 %3 %4 %5

:END
