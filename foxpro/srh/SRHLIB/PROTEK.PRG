
* PROTEK.PRG
*
*   Protects a database file from use outside an 
*   application by changing the .DBF file header.
*
*   Usage: DO protek WITH <file name>, SET("CURSOR")
*
*   First bytes of file header are swapped as:
*
*   Database File    Protected    Unprotected
*   อออออออออออออ    อออออออออ    อออออออออออ
*   No memo field    CHR(0)       CHR(3)   
*   With memo field  CHR(26)      CHR(245)
*
*   Parameter THE_FILE is the name of the .DBF
*   file to be protected.
*
*   Author: Pat Adams, DB Unlimited
*   Date: 9/11/91
*   Copyright 1991, 1992 DB Unlimited
* * * * * * * * * * * * * * * * * * * * * * * * *
PARAMETERS the_file, curs_set
* ======================================
*$ Make sure the name of the file is in
*$ all upper case letters
* ======================================
the_file = UPPER(ALLTRIM(the_file))
PRIVATE ALL

IF "." $ the_file AND ! ".DBF" $ the_file
* ===============================================
*$  If the extension of the file name is not .DBF
*$  return an error message to the user.
* ===============================================
    STORE SPACE(12) TO newname
    DEFINE WINDOW BADNAME FROM 6,21 TO 18,58 DOUBLE SHADOW
    ACTIVATE SCREEN
    ACTIVATE WINDOW BADNAME NOSHOW
    @ 0,10 SAY "   WHOOPS   "
    @ 2, 1 SAY "You are trying to protect file"
    @ 3, 1 SAY "&the_file."
    @ 5, 1 SAY "Only a .DBF file can be protected."
    @ 6, 1 SAY "Please enter the name of the .DBF"
    @ 7, 1 SAY "file which should be protected or"
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
        the_file = UPPER(ALLTRIM(newname))
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
    = FWRITE(hhandle, IIF(bbyte==CHR(3), ;
        CHR(0), CHR(26)))
    = FCLOSE(hhandle)
ENDIF hhandle > 0

RETURN
* End PROTEK.PRG

