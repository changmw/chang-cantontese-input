@echo off
REM Turbo C compile and link command file.
map ins s1:=srh386a/sys:dp/tcpp3/bin
@tcc  -LG:\DP\TCPP3\LIB -IG:\DP\TCPP3\INCLUDE -P -ml -DTURBO %1
map del s1:
