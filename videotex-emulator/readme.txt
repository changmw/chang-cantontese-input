This is a Videotex (ViewData) Emulator for DOS. It was a 2-person 
final-year project for B.Sc. in Computer Studies, 
coded using Turbo C 2.0 for DOS. 

This project won a little award from Hong Kong Computer Society, and 
was interviewed by Hong Kong Air Cargo Terminals Limited (HACTL)
in Kai Tak, Kowloon City.

Back then, there was no HTML standard and Internet was still not yet
opened to business use.


* Source codes for
* SE0313 Videotex Emulation
*
* City Polytechnic of Hong Kong
* Department of Computer Studies
* Bachelor of Science (Honours) in Computer Studies (89-90)
*
*    Final Year Project
*
* by Chan Ming Lap
*    Chang Man Wai
*
* Development platform: Turbo C 2.0

tcconfig.tc     -- Turbo C configuration file for compiling
                   the Videotex Emulator

videotex.prj

videotex.c      -- command centre
videotex.h

commngr.c       -- communication manager
commngr.h

windmngr.c      -- window manager
windmngr.h

util.c          -- utilities
util.h

keyboard.c      -- keyboard manager
keyboard.h

queue.c         -- queue manager
queue.h

pm.c            -- presentation manager
pm.h

draw.c          -- graphics primitives
draw.h

script.c        -- script
script.h

stdfonts.15     -- Chinese characters database
stdfont1.15

*.img           -- Videotex frames captured from local Videotex service
                   operator CSL's Viewdata II

README.1ST      -- This file

*
* Utilities for testing the emulator
*

gentest.c       -- produce GRAPHICS PRIMITVES videotex frames

send.prj        -- send a binary file to a remote machine
send.c          -- using null-modem, use this to emulate
send.h          -- the videotex operator
send1.c
send1.h
send.exe

convert.c       -- converts BIG-5 code to the internal representation
convert.exe     -- format of the videotex emulator

