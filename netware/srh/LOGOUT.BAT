@Echo off
Cls
Newmail
If errorlevel 1 goto chkmail
goto main

:chkmail
Ask "Read it now ? <Y>es or <N>o ? ", YN
if errorlevel 2 goto main
if errorlevel 1 CALL pmail
goto main

:Main
if not "%1" == "" goto end
PROMPT [ $p ] 
SET USERID=
SET HOMEDIR=
SET MAILID=
SET WP=
SET NC=
SET FOXPROCFG=
SET NETMENU=
SET PRIMELINK=
type \\srh486dp\sys\lib\batch\bye.txt

:end
Systime
_logout %1 %2 %3 > NUL