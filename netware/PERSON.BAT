@echo off
@echo Loading Personnel System ...
rem goto MAINT
foxr -t f:\srhis\person\person
goto EXIT
:MAINT
@echo .
rem @echo . SYSTEM UNDER MAINTENANCE
@echo . SYSTEM UNDER CONSTRUCTION
@echo .
pause
:EXIT
