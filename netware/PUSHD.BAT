@echo off
@IF '%1'=='X' PROMPT @$N:$_@CD $P
@IF '%1'=='' %COMSPEC%/C %0 X >F:%HOMEDIR%\POPD.BAT
