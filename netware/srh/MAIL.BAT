@echo off
cls
@echo Checking for new mail ...
newmail
if errorlevel 1 goto gotsomemail
@echo ÿ
@echo ð YOU HAVE NO NEW MAIL ð
:gotsomemail
waitn 1
@echo ÿ
@echo Loading Pegasus Mail ...
map ins s1:=SYS:LIB\PMAIL > nul
PMAIL
map del s1: > nul
