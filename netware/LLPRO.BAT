@echo off
@echo Loading LapLink 4.0 ...
map ins s1:=SRH386A/sys:dp\ll4 > NUL
llpro
map del s1: > NUL
