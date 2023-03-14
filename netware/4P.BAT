@echo off
rem
rem default options:
rem
rem -f   front side only
rem -b   back side only
rem -u   unattended
rem -n   line numbers
rem -o   output device
rem -s   single side only
rem -q   quick (don't count no of pages)
rem -tab set number of spaces to fill TAB character
rem
if "%1"=="" goto help
@echo Outputing to LPT1: ...
echo nn | 4print -s -sq -u -ft -q -tab3 -tt -zw %1 %2 %3 %4 %5 %6 %7 %8
goto end
:help
  @echo .
  @echo . 4PRINT (to LPT1:)
  @echo . Usage: 4p filename(s)
  @echo .        eg. 4p *.c *.h
  @echo .
:end
