@echo off
cls
@echo Loading Oracle...
MAP INS S1:=SRH486DP/SYS:LIB\ORACLE\BIN > nul
MAP INS S2:=SRH486DP/SYS:LIB\ORACLE\PBIN > nul
sqlpme
if errorlevel 1 goto exit
oracle5
if errorlevel 1 goto exit
if "%1"=="/NOIOR" goto exit
if "%1"=="/noior" goto exit
ior warm

:exit
cls
@ECHO Type "KILLORA" to unload Oracle Engine
@echo 
