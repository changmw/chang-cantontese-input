

* DBFOPEN.PRG
*
*   This routine provides an example of
*   usage of the UNPROTEK.PRG and UNPROTEK.PRG
*   for unprotecting database files and
*   protecting database files.
*
*   Author: Pat Adams, DB Unlimited
*   Date: 12/1/91
*   Copyright 1991, 1992 DB Unlimited
* * * * * * * * * * * * * * * * * * * * * * * *
SET TALK OFF
ACTIVATE SCREEN
* ==============================
*$ Initalize FP25EROR error handler
* ==============================
SET PROCEDURE TO fp25eror
DO erorset 
@ 0, 0 SAY REPLICATE("±",79)
@ 1, 0 SAY REPLICATE("±",79)
@ 2, 0 SAY REPLICATE("±",79)
@ 3, 0 SAY REPLICATE("±",79)
@ 4, 0 SAY REPLICATE("±",79)
@ 5, 0 SAY REPLICATE("±",79)
@ 6, 0 SAY REPLICATE("±",79)
@ 7, 0 SAY REPLICATE("±",79)
@ 8, 0 SAY REPLICATE("±",79)
@ 9, 0 SAY REPLICATE("±",79)
@10, 0 SAY REPLICATE("±",79)
@11, 0 SAY REPLICATE("±",79)
@12, 0 SAY REPLICATE("±",79)
@13, 0 SAY REPLICATE("±",79)
@14, 0 SAY REPLICATE("±",79)
@15, 0 SAY REPLICATE("±",79)
@16, 0 SAY REPLICATE("±",79)
@17, 0 SAY REPLICATE("±",79)
@18, 0 SAY REPLICATE("±",79)
@19, 0 SAY REPLICATE("±",79)
@20, 0 SAY REPLICATE("±",79)
@21, 0 SAY REPLICATE("±",79)
@22, 0 SAY REPLICATE("±",79)
@23, 0 SAY REPLICATE("±",79)
@24, 0 SAY REPLICATE("±",79)
DEFINE WINDOW welcome FROM 8,24 TO 13,56 DOUBLE SHADOW
ACTIVATE WINDOW welcome NOSHOW
SET CURSOR OFF
@ 0, 2 SAY "Welcome to the XYZ System."
@ 2, 2 SAY "Unprotecting database files."
@ 3, 2 SAY "Sorry to keep you waiting..."
SHOW WINDOW welcome
* ======================================
*$ Unprotect file with UNPROTEK routine
*$ so it can be used as a .DBF file
* ======================================
DO unprotek WITH "TEST.DBF", SET("CURSOR")
* =======================
*$ Now place file in use
* =======================
USE test
* =======================================
*$ Inform user file has been unprotected
*$ and placed in use, then close file
*$ and protect again.
* =======================================
DEFINE WINDOW UNPRO FROM 9,9 TO 13,70 DOUBLE SHADOW
RELEASE WINDOW welcome
ACTIVATE SCREEN
BROWSE
ACTIVATE WINDOW UNPRO NOSHOW
@ 0, 2 SAY "The TEST.DBF file has been unprotected " + ;
      "and placed in use."
@ 2, 2 SAY "Press any key to close TEST.DBF and protect it..."
SHOW WINDOW unpro
=INKEY(0, "MH")
CLOSE DATA
DO protek WITH "TEST.DBF", SET("CURSOR")
DEFINE WINDOW DDONE FROM 8,15 TO 14,64 DOUBLE SHADOW
ACTIVATE SCREEN
ACTIVATE WINDOW DDONE NOSHOW
@ 0, 2 SAY "TEST.DBF has been closed and protected."
@ 1, 2 SAY "FoxPro will not acknowledge it as a"
@ 2, 2 SAY "database file unless it is first unprotected."
@ 4, 2 SAY "Press any key..."
RELEASE WINDOW unpro
SHOW WINDOW ddone
=INKEY(0, "MH")
RELEASE WINDOW ddone
RETURN
* End DBFOPEN.PRG
