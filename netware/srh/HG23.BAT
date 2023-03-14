@echo off
@echo Loading Harvard Graphics 2.3 ...
map ins s1:=SYS:LIB\HG23
append f:\lib\hg23
f:
if not exist HG.EXE   NCOPY F:\LIB\HG23\HG.EX_ HG.EXE > nul
if not exist HG.CFG   COPY F:\LIB\HG23\HG.CFG > nul
if not exist HGDP.EXE NCOPY F:\LIB\HG23\HGDP.EXE > nul
HG
rem if exist HG.EXE DEL HG.EXE > nul
if exist HGDP.EXE DEL HGDP.EXE > nul
map del s1:
