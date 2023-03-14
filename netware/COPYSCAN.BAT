@Echo off
Echo Update McAfee's virus scanner in each user's hard disk
if "%1"=="" goto error
if "%2"=="" goto error
if exist c:\syslib\scan%1.dat del c:\syslib\scan%1.dat
if exist c:\syslib\scan%2.dat goto end
Echo Copying..... please wait!
copy f:\lib\syslib\scan.exe  c:\syslib > nul
copy f:\lib\syslib\clean.exe c:\syslib > nul
copy f:\autouser\scan%2.dat  c:\syslib > nul
goto Finish

:Error
Echo Example : COPYSCAN 95 97
goto End
        
:Finish
Echo Finished.
goto end

:End
