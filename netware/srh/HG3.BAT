@echo off
@echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
@echo ³ Loading Harvard Graphics 3.0 ...  ³
@echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
getgraph > NUL
if errorlevel 9 goto LOADHG
if errorlevel 7 goto ERROR
if errorlevel 6 goto ERROR
if errorlevel 5 goto LOADHG
if errorlevel 4 goto LOADHG
if errorlevel 3 goto LOADHG
goto ERROR

:LOADHG
append F:\lib\hg3 > NUL
F:
home
IF EXIST *.$$$ del *.$$$ > NUL
IF EXIST HG3.EXE del hg3.exe > NUL
NCOPY F:\LIB\HG3\HG3.EX_ HG3.EXE > nul
if not exist HG3.CF3 COPY F:\LIB\HG3\HG3.CF_ HG3.CF3 > nul
HG3 %1 %2 %3
if exist HG3.EXE DEL HG3.EXE > nul
goto EXIT

:ERROR
echo .
echo . You need a EGA/VGA monitor to use Harvard Graphics 3.0
echo .
pause
:EXIT
