echo off
@echo Loading Harvard Graphics 3.0 Tutorial ...
append F:\lib\hg3
F:
home
if not exist HG3.EXE COPY F:\LIB\HG3\HG3.EX_ HG3.EXE > nul
if not exist HG3.CF3 COPY F:\LIB\HG3\HG3.CF_ HG3.CF3 > nul

getgraph > NUL
if errorlevel 9 goto VGA
if errorlevel 5 goto EGA
if errorlevel 4 goto EGA
if errorlevel 3 goto EGA
goto ERROR

:EGA
hg3 \lib\hg3\tutorial\egatutor.ma3
goto EXIT

:VGA
hg3 \lib\hg3\tutorial\hg3tutor.ma3
goto EXIT

:ERROR
echo .
echo . You need a EGA/VGA monitor to use Harvard Graphics 3.0
echo .
pause

:EXIT
if exist HG3.EXE DEL HG3.EXE > nul
