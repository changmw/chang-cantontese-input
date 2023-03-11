

* UNPROTEK.PRG
*
* Unprotects a .DBF file previously protected
* with PROTEK.PRG.
*
* First file bytes are swapped, reversing
* the protection of PROTEK.PRG.
*
*   Usage: DO unprotek WITH <file name>, SET("CURSOR")
*
*   Author: Pat Adams, DB Unlimited
*   Date: 9/11/91
*   Copyright 1991, 1992 DB Unlimited
* * * * * * * * * * * * * * * * * * * * * * * * *
PARAMETERS the_file, curs_set
PRIVATE ALL
the_file = UPPER(ALLTRIM(the_file))

IF "." $ the_file AND ! ".DBF" $ the_file
* ===============================================
*$  If the extension of the file name is not .DBF
*$  return an error message to the user.
* ===============================================
      STORE SPACE(12) TO newname
    DEFINE WINDOW BADNAME FROM 6,20 TO 18,59 DOUBLE SHADOW
    ACTIVATE SCREEN
    ACTIVATE WINDOW BADNAME NOSHOW
    @ 0,11 SAY "   WHOOPS   "
    @ 2, 1 SAY "You are trying to unprotect file"
    @ 3, 1 SAY "&the_file."
    @ 5, 1 SAY "Only a .DBF file can be unprotected."
    @ 6, 1 SAY "Please enter the name of the .DBF"
    @ 7, 1 SAY "file which should be unprotected or"
    @ 8, 1 SAY "press ESC to abandon the protect."
    SET CURSOR ON
    @10,12 GET newname
    SHOW WINDOW badname
    READ
    SET CURSOR &curs_set
    RELEASE WINDOW badname

    IF LASTKEY() = 27 OR EMPTY(newname)
    * =======================================
    *$ Abort protect by RETURNing to calling
    *$ module if user has pressed ESC or has
    *$ not entered a file name
    * =======================================
        RETURN
    ELSE
        the_file = ALLTRIM(UPPER(newname))
    ENDIF lastkey() = 27 .or. empty(newname)
ENDIF "." $ the_file .and. ! ".DBF" $ the_file

IF ! ".DBF" $ the_file
* ==========================================
*$ If the passed parameter does not include
*$ the .DBF file extension add it now
* ==========================================
    the_file = the_file + ".DBF"
ENDIF .not. "." $the_file

hhandle = FOPEN(the_file, 2)

IF hhandle > 0
    bbyte = FREAD(hhandle, 1)
    = FSEEK(hhandle, 0)
    = FWRITE(hhandle, IIF(bbyte==CHR(0), ;
        CHR(3), CHR(245)))
    =FCLOSE(hhandle)
ENDIF hhandle > 0
RETURN
* End UNPROTEK.PRG

