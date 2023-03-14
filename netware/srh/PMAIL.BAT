@echo off
@echo Loading Peagasus Mail 2.31 ...
map ins s1:=SRH486DP/SYS:LIB\PMAIL > nul
PMAIL
map del s1: > nul
