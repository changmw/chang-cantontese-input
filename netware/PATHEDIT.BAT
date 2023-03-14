@echo off
:
: PATHEDIT by Rich Davies, Aurora Co.
: Found in PC Magazine
:
if '%1'=='+'   shift
if '%1'==''    goto help
if '%1'=='-'   goto drop
if '%1'=='sub' goto sub

: Optionally, put new dir first, path=%1;%path%
path=%path%;%1
ECHO %1 added.
: Display path
path
goto end

:drop
IF '%2'=='' goto help
set removed=
set tmp-path=%path%
path=%2
set drop=%path%
: Now drop contains %2 capitalized
path=%tmp-path%
set tmp-path=
for %%a in (%path%) do call %0 sub %%a
path=%tmp-path%
set tmp-path=
IF '%removed%'=='' ECHO %drop% not found.
IF '%removed%'=='YES' ECHO %drop% removed.
set drop=
set removed=
: Display path
path
goto end

:help
ECHO The options are:
ECHO PATHEDIT [-] directory   : drops directory from path
ECHO .
ECHO PATHEDIT [+] directory   : adds directory, "+" is optional
ECHO.
goto end

:sub
IF %drop%==%2 SET removed=YES
IF %drop%==%2 goto end
IF '%tmp-path%'=='' set tmp-path=%2
IF %tmp-path%==%2 goto end
set tmp-path=%tmp-path%;%2

:end
