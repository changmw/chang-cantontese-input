@echo off
@echo Loading Brief editor 3.0 ...
map ins S1:=SRH486DP/SYS:LIB\BRIEF
B %1 %2 %3 %4 %5
map del S1:
