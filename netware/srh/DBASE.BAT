@echo off
@echo Loading dBase III+ 1.0 ...
map ins s1:=sys:lib\dbase > NUL
dbase
map del s1: > NUL
