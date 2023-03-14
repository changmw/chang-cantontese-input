@echo off
if ""=="%1" goto default
\public\menu %1.MNU
goto end
:default
\public\menu %NETMENU%.MNU
:end
