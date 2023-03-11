
*!*******************************************************
PROCEDURE backup
*********************************************************
*& Backup files onto floppy disks
*
*   Note that POPUP MAINTAIN for the maintenance menu has
*     not been released when the module is entered.
*
*   Author: Pat Adams  (718) 469-4032
*   Date: 4/29/92
*
*   Copyright 1991 DB Unlimited
* * * * * * * * * * * * * * * * * * * * * * * *  * *
PRIVATE the_files, the_disk, okay, youchose, ;
    needed, you_need, disk_no, dots_recs, combined, ;
    can_recs, tbl_recs, kontinu, korrect, ;
    authorized, youpicked, is_okay, new_file, kounter
STORE 1 TO the_files, the_disk, d_drive, new_file
STORE 0 TO dot_recs, can_recs, tbl_recs
STORE .F. TO  okay, authorized, is_okay
* ========================================
*$ Check user authorization
* =========================================
*DO security WITH authorized, "BACKUP"
* ======================================
* NOTE: The statement STORE .T. TO authorized
* has been subsituted here in order to facilitate
* your running this prototype.
* =======================================
STORE .T. TO authorized

IF ! authorized
    * ===============================================
    *$ Return to main menu & screen if not authorized
    * ===============================================
    RELEASE POPUP maintain
    RETURN
ENDIF (! authorized)

RELEASE WINDOW q_text
RELEASE WINDOW f_text
SET COLOR TO W/N
@ 1,0 CLEAR TO 24,79
* ===========================================
* Turn off right and left arrow keys so popup
* menu will not disappear if they are pressed
* ============================================
ON KEY LABEL rightarrow ?? ""
ON KEY LABEL leftarrow ?? ""
DEFINE POPUP whichfil FROM 7,40 SHADOW ;
    COLOR N/W, N/W, +R/W, R/W, +W/N, +W/N, +GR/W
*          ^    ^    ^        ^    ^     |
*          |    |    ^        ^    ^    Hot Key
* Disabled Optn |    |        |    |
*               |    Border   |  Selected optn
*        Unselected
*        &Background      Message
*
ON SELECTION POPUP whichfil DEACTIVATE POPUP whichfil
DEFINE BAR 1 OF whichfil PROMPT "  SELECT FILES  " SKIP
DEFINE BAR 2 OF whichfil PROMPT " FOR THE BACKUP " SKIP
DEFINE BAR 3 OF whichfil PROMPT "ออออออออออออออออ" SKIP
DEFINE BAR 4 OF whichfil PROMPT " \<All files      " ;
    MESSAGE ;
    "BACK UP FACTS, QUOTES, AND LOOKUP TABLES ON FLOPPY DISKS"
DEFINE BAR 5 OF whichfil PROMPT " \<Facts & quotes " ;
    MESSAGE "BACK UP FACTS AND QUOTES ON FLOPPY DISKS"
DEFINE BAR 6 OF whichfil PROMPT " \<Lookup tables  " ;
    MESSAGE "BACK UP LOOKUP TABLES ON FLOPPY DISKS"
* =========================================================
*$ Put a copy of the previous popup menu back on the screen
*  and then activate the new popup sub-menu
* =========================================================
SHOW POPUP maintain SAVE
DEFINE WINDOW isokay FROM 10,11 TO 12,66 PANEL ;
    COLOR N/W,N/W,R+/R SHADOW

DO WHILE ! is_okay
    * ========================================
    *$ User selection of which files to back up
    *$ and validation of selection
    * ========================================
    ACTIVATE POPUP whichfil
    whichfil = BAR()
    the_files = BAR()
    
    IF LASTKEY() = 27
        RELEASE POPUP whichfil
        EXIT
    ENDIF (LASTKEY() = 27)
    
    youpicked = ALLTRIM(PROMPT())
    ACTIVATE WINDOW isokay
    @ 0, 1 SAY "You selected &youpicked. " + ;
        "Is this correct? (Y/N)"
    DO yn_esc WITH is_okay
    RELEASE WINDOW isokay
   
    IF LASTKEY() = 27 OR is_okay
        EXIT
    ENDIF (LASTKEY() = 27 OR is_okay)
ENDDO (! is_okay)

DO WHILE LASTKEY() <> 27
    * =======================================
    *$ If user has not pressed ESC determine
    *  what size disk is to be used
    * =======================================
    DEFINE POPUP disk_siz FROM 9,18 SHADOW ;
        COLOR N/W, N/W, +*R/W,, +W/N, +W/N, +GR/W
    ON SELECTION POPUP disk_siz DEACTIVATE POPUP
    DEFINE BAR 1 OF disk_siz PROMPT '    SELECT FLOPPY ' + ;
        'DISK SIZE    ' SKIP
    DEFINE BAR 2 OF disk_siz PROMPT 'อออออออออออออ'+ ;
        'ออออออออออออออออออ' SKIP
    DEFINE BAR 3 OF disk_siz PROMPT ' \<Double density ' + ;
        '5-1/4" (360 k) '
    DEFINE BAR 4 OF disk_siz PROMPT ' \<High density ' + ;
        '5-1/4"  (1.2 mb) '
    DEFINE BAR 5 OF disk_siz PROMPT ' D\<ouble density ' + ;
        '3-1/2" (720 k) '
    DEFINE BAR 6 OF disk_siz PROMPT ' H\<igh density ' + ;
        '3-1/2"  (1.4 mb) '
    * ======================================================
    *$ Put a copy of the previous popup menu back on screen
    * ======================================================
    SHOW POPUP whichfil SAVE
    CLEAR TYPEAHEAD
    ACTIVATE POPUP disk_siz
    the_disk = BAR()
    youchose = PROMPT()
    youchose = ALLTRIM(youchose)
    
    IF LASTKEY() = 27
    * ===================================
    *$ Abort if user has pressed ESC key
    * ===================================
        EXIT
    ENDIF (LASTKEY() = 27)
    * =========================================
    *$ Remove all the popups from the screen and
    *  have user verify the disk size selected
    * =========================================
    RELEASE POPUP maintain
    RELEASE POPUP whichfil
    DEFINE WINDOW checkit FROM 8,20 TO 13,60 DOUBLE ;
        COLOR W+/BG,N/W,BG+/BG SHADOW
    SET COLOR TO W/N
    CLEAR
    
    DO WHILE .NOT. okay
        ACTIVATE WINDOW checkit
        @ 0, 1 SAY "You selected the following disk size:"
        @ 1, 4 SAY youchose
        @ 3, 9 SAY "IS THIS CORRECT? (Y/N)" COLOR *+GR/BG
        DO yn_esc WITH okay
        DEACTIVATE WINDOW checkit
        
        IF LASTKEY() = 27
        * ===================================
        *$ Abort if user has pressed ESC key
        * ===================================
            EXIT
        ENDIF (LASTKEY() = 27)
        
        IF .NOT. okay
        * ======================================
        *$ Reactivate window to let user reselect
        *  disk size if error has been made
        * ======================================
            ACTIVATE POPUP disk_siz
            the_disk = BAR()
            youchose = PROMPT()
            youchose = ALLTRIM(youchose)
        ENDIF (.NOT. okay)
    ENDDO (.NOT. okay)
    
    RELEASE WINDOW checkit
    
    IF LASTKEY() = 27
    * ===================================
    *$ Abort if user has pressed ESC key
    * ===================================
        EXIT
    ENDIF (LASTKEY() = 27)
    
    DEFINE WINDOW kalkulat FROM 10,4 TO 12,74 PANEL ;
        COLOR W+/BG,N/W,BG+*/BG SHADOW
    ACTIVATE WINDOW kalkulat    @ 0, 1 SAY "Calculating number of disks required. " +;
        "Sorry to keep you waiting..."
    ON KEY LABEL rightarrow
    ON KEY LABEL leftarrow
    * ====================================
    *$ Calculate the number of disks 
    *$ required for the backup
    * =========================================
    DO CASE whichfil & the_disk
      CASE whichfil = 4 AND the_disk = 3
        * =================================================
        *$ Back up all files on double density 5-1/4" disks
        * =================================================
        SELECT dotsdata    && ******> Substitute your own
                          *********> file name here
        * ============================================
        * 320 DOTSDATA records per high density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 320 TO dot_recs
        you_need = (RECCOUNT()/320) + 1
        * ============================================
        *$ Increment for CANDIDAT.DBF and DOTS_TBL.DBF
        * ============================================
        STORE 5000 TO can_recs, tbl_recs
        SELECT candidat   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = you_need + (RECCOUNT()/5000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/5000) + 1), "@Z 999"))
        
      CASE whichfil = 4 AND the_disk = 4
        * =================================================
        *$ Back up all files on high density 5-1/4" disks
        * =================================================
        SELECT dotsdata   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * ============================================
        * 800 DOTSDATA records per high density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 800 TO dot_recs
        you_need = (RECCOUNT()/800) + 1
        STORE 15000 TO can_recs, tbl_recs
        SELECT candidat   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = you_need + (RECCOUNT()/15000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/15000) + 1), "@Z 999"))
        
      CASE whichfil = 4 AND the_disk = 5
        * =================================================
        *$ Back up all files on double density 3-1/2" disks
        * =================================================
        SELECT dotsdata   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * ============================================
        * 600 DOTSDATA records per double density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 600 TO dot_recs
        you_need = (RECCOUNT()/750) + 1
        * =================================================
        *$ Backup CANDIDAT.DBF and DOTS_TBL.DBF on double
        *$ density 3-1/2" disks - 10,000 records per disk
        * =================================================
        STORE 10000 TO can_recs, tbl_recs
        SELECT candidat    && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = you_need + (RECCOUNT()/10000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/10000) + 1), "@Z 999"))
        
      CASE whichfil = 4 AND the_disk = 6
        * =================================================
        *$ Back up all files on high density 3-1/2" disks
        * =================================================
        SELECT dotsdata   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * ============================================
        * 1,100 DOTSDATA records per high density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 1100 TO dot_recs
        you_need = (RECCOUNT()/1450) + 1
        * =================================================
        *$ Backup CANDIDAT.DBF and DOTS_TBL.DBF on high
        *$ density 3-1/2" disks - 14,000 records per disk
        * =================================================
        STORE 14000 TO can_recs, tbl_recs
        SELECT candidat   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = you_need + (RECCOUNT()/14000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/14000) + 1), "@Z 999"))
        
      CASE whichfil = 5 AND the_disk = 3
        * =================================================
        *$ Backup DOTSDATA on double density 5-1/4" disks
        * =================================================
        SELECT dotsdata   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * ============================================
        * 295 records per double density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 295 TO dot_recs
        you_need = ALLTRIM(TRANSFORM((RECCOUNT()/295) + ;
           1, "@Z 999"))
        
      CASE whichfil = 5 AND the_disk = 4
        * =================================================
        *$ Backup DOTSDATA on high density 5-1/4" disks
        * =================================================
        SELECT dotsdata   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * ============================================
        * 750 records per high density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 750 TO dot_recs
        you_need = ALLTRIM(TRANSFORM((RECCOUNT()/750) + ;
           1, "@Z 999"))
        
      CASE whichfil = 5 AND the_disk = 5
        * =================================================
        *$ Backup DOTSDATA on double density 3-1/2" disks
        * =================================================
        SELECT dotsdata   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * ============================================
        * 600 records per double density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 600 TO dot_recs
        you_need = ALLTRIM(TRANSFORM((RECCOUNT()/600) + ;
           1, "@Z 999"))
        
      CASE whichfil = 5 AND the_disk = 6
        * =================================================
        *$ Backup DOTSDATA on high density 3-1/2" disks
        * =================================================
        SELECT dotsdata   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * ============================================
        * 1,100 records per high density disk
        * to provide sufficient space for memo fields
        * ============================================
        STORE 1100 TO dot_recs
        you_need = ALLTRIM(TRANSFORM((RECCOUNT()/1100) + ;
           1, "@Z 999"))
        
      CASE whichfil = 6 AND the_disk = 3
        * =================================================
        *$ Backup CANDIDAT.DBF and DOTS_TBL.DBF on double
        *$ density 5-1/4" disks - 5,000 records per disk
        * =================================================
        STORE 5000 TO can_recs, tbl_recs
        SELECT candidat   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = (RECCOUNT()/5000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/5000) + 1), "@Z 999"))
        
      CASE whichfil = 6 AND the_disk = 4
        * =================================================
        *$ Backup CANDIDAT.DBF and DOTS_TBL.DBF on high
        *$ density 5-1/4" disks - 16,000 records per disk
        * =================================================
        STORE 16000 TO can_recs, tbl_recs
        SELECT candidat  && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = (RECCOUNT()/16000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/16000) + 1), "@Z 999"))        
      CASE whichfil = 6 AND the_disk = 5
        * =================================================
        *$ Backup CANDIDAT.DBF and DOTS_TBL.DBF on double
        *$ density 3-1/2" disks - 10,000 records per disk
        * =================================================
        STORE 10000 TO can_recs, tbl_recs
        SELECT candidat  && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = (RECCOUNT()/10000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/10000) + 1), "@Z 999"))
        
      CASE whichfil = 6 AND the_disk = 6
        * =================================================
        *$ Backup CANDIDAT.DBF and DOTS_TBL.DBF on high
        *$ density 3-1/2" disks - 15,000 records per disk
        * =================================================
        STORE 15000 TO can_recs, tbl_recs
        SELECT candidat   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = (RECCOUNT()/15000) + 1
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        you_need = ALLTRIM(TRANSFORM(you_need + ;
           ((RECCOUNT()/15000) + 1), "@Z 999"))
    ENDCASE  whichfil & the_disk
    
    RELEASE WINDOW kalkulat
    * ====================================================
    *$ Inform user how many formatted floppy disks will be
    *$ required and provide option to abort routine
    * ====================================================
    DEFINE WINDOW need_dsk FROM 9,8 TO 13,71 DOUBLE ;
        COLOR W+/BG,N/W,BG+/BG SHADOW
    ACTIVATE WINDOW need_dsk
    @ 0, 6 SAY "&you_need floppy disks will be " + ;
        "required for this backup."
    @ 2, 1 SAY "Do you have enough FORMATTED disks on " + ;
        "hand to proceed? (Y/N)"
    @ 2,20 SAY "FORMATTED" COLOR N/BG
    STORE .F. TO kontinu
    DO yn_esc WITH kontinu
    RELEASE WINDOW need_dsk   
    IF LASTKEY() = 27 OR ! kontinu
    * ===================================
    *$ Abort if user has pressed ESC key
    *$ or does not want to continue
    * ===================================
        EXIT
    ENDIF (LASTKEY() = 27 OR ! kontinu
    * ================================
    *$ Determine whether floppy disks 
    *$ will be in drive A: or B:
    * ================================
    STORE SPACE(2) TO d_drive
    DO flopydrv WITH d_drive
    
    IF LASTKEY() = 27 OR d_drive = SPACE(2)
    * ==============================================
    *$ Abort if user has pressed ESC key
    *$ or has not supplied floppy drive designation
    * ==============================================
        EXIT
    ENDIF (LASTKEY() = 27)
    
    DEFINE WINDOW backup FROM 7,26 TO 13,54 DOUBLE ;
        COLOR B/W,N/W,BG+/W SHADOW
    ACTIVATE WINDOW backup
    @ 0, 2 SAY "Ready to begin backup."
    @ 2, 2 SAY "Please insert 1st disk"
    @ 3, 2 SAY "in drive &d_drive and press"
    @ 4, 2 SAY "any key or ESC to abort."
    CLEAR TYPEAHEAD
    =INKEY(0, "MH")

    IF LASTKEY() = 27
    * ===================================
    *$ Abort if user has pressed ESC key
    * ===================================
        EXIT
    ENDIF (LASTKEY() = 27)
    
    RELEASE WINDOW backup
    * ===========================================
    *$ DISK.BIN checks for presence of a disk in
    *  the designated drive (1 character).  If
    *  everything is not okay it returns an 'X',
    *  otherwise the passed parameter is returned
    * ===========================================
    LOAD DISK   
    STORE "1" TO kounter  
    IF dot_recs <> 0 AND LASTKEY() <> 27
        * ==================================================
        *$ If user is backing up DOTSDATA copy
        *  those records to floppy disk unless ESC pressed
        * ==================================================
        SELECT dotsdata  && **************> Substitute
                          *****************> your own file
                          *****************> name here
        SET ORDER TO 1        && Index is DOTSDATA

        GO TOP
        new_file = d_drive + "DOTSDATA"
        DEFINE WINDOW copying FROM 9,21 TO 12,58 PANEL ;
            COLOR W+/B,N/W,W+/B SHADOW
        DEFINE WINDOW next_dsk FROM 9,21 TO 13,58 PANEL ;
            COLOR +W/R,N/W,R+*/R SHADOW
        
        DO WHILE .NOT. EOF()
            diskit = UPPER(LEFT(d_drive,1))
            CALL DISK WITH diskit
            
            DO WHILE UPPER(diskit) = "X"
                * ========================================
                *$ Disk is not in the drive.  Prompt user
                * ========================================
                DO no_disk WITH d_drive
                
                IF LASTKEY() = 27
                * ===================================
                *$ Abort if user has pressed ESC key
                * ===================================
                    EXIT
                ENDIF (LASTKEY() = 27)
                
                diskit = LEFT(d_drive,1)
                CALL DISK WITH diskit
            ENDDO (UPPER(diskit) = "X")
            
            IF LASTKEY() = 27
            * ===================================
            *$ Abort if user has pressed ESC key
            * ===================================
                EXIT
            ENDIF (LASTKEY() = 27)
            
            ACTIVATE WINDOW copying NOSHOW
            @ 0, 1 SAY "Copying Quotes & Facts to " + ;
               "disk #&kounter."
            @ 1,11 SAY "Please wait..."
            SHOW WINDOW copying
            COPY NEXT dot_recs TO &new_file
            SKIP
           
            IF LASTKEY() = 27
            * ===================================
            *$ Abort if user has pressed ESC key
            * ===================================
                EXIT
            ENDIF (LASTKEY() = 27)

            IF .NOT. EOF()
             * =============================================
             *$ Sound pleasant chime and if not end
             *  of file prompt user to put in another disk
             * =============================================
                DEACTIVATE WINDOW copying
                ACTIVATE WINDOW next_dsk
                @ 0, 3 SAY "Please remove disk #" + ;
                  "&kounter, insert"
                @ 1, 3 SAY "next disk for Quotes and Facts"
                @ 2, 3 SAY "and press any " + ;
                   "key to continue..."
                CLEAR TYPEAHEAD
                DO nicechim
                = INKEY(0, "MH")
                DEACTIVATE WINDOW next_dsk
                kounter = ALLTRIM(TRANSFORM(VAL(kounter) + ;
                    1, "@Z 999"))
                
                IF LASTKEY() = 27
                * ===================================
                *$ Abort if user has pressed ESC key
                * ===================================
                    EXIT
                ENDIF (LASTKEY() = 27)
            ENDIF (.NOT. EOF())
        ENDDO (.NOT. EOF())
        
        DEACTIVATE WINDOW copying
        DEACTIVATE WINDOW next_dsk
        
        IF LASTKEY() = 27
        * ===================================
        *$ Abort if user has pressed ESC key
        * ===================================
            EXIT
        ENDIF (LASTKEY() = 27)
        
        DEFINE WINDOW finish FROM 9,16 TO 13,63 PANEL ;
            COLOR W+/B,N/W,W+/B SHADOW
        * ================================================
        *$ Inform user backup of quotes & facts completed
        * =================================================
        ACTIVATE SCREEN
        ACTIVATE WINDOW finish
        @ 0, 1 SAY "Backup of Quotes & facts " + ;
           "has been completed."
        @ 2,10 SAY "Press any key to continue..." COLOR W/B
        CLEAR TYPEAHEAD
        = INKEY(0, "MH")
        RELEASE WINDOW finish
    ENDIF (dot_recs <> 0 AND LASTKEY() <> 27)
    
    IF can_recs <> 0 AND LASTKEY() <> 27
        DEFINE WINDOW copying FROM 9,21 TO 12,57 PANEL ;
            COLOR W+/B,N/W,W+/B SHADOW
        DEFINE WINDOW next_dsk FROM 9,21 TO 13,58 PANEL ;
            COLOR W+/R,N/W,R+*/R SHADOW
        
        IF dot_recs <> 0
            ACTIVATE WINDOW next_dsk
            @ 0, 3 SAY "Please remove disk " + ;
               "#&kounter, insert"
            @ 1, 3 SAY "next disk for lookup tables"
            @ 2, 3 SAY "and press any key to continue..."
            CLEAR TYPEAHEAD
            DO nicechim
            = INKEY(0, "MH")
            DEACTIVATE WINDOW next_dsk
            kounter = ALLTRIM(TRANSFORM(VAL(kounter) + ;
               1, "@Z 999"))
        ENDIF (dot_recs <> 0)
        * =====================================
        *$ First back up the DOTS_TBL database
        * =====================================
        SELECT dots_tbl   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        SET ORDER TO 3          && Index is dt_name
        GO TOP
        new_file = d_drive + "DOTS_TBL"

        DO WHILE .NOT. EOF()
            diskit = UPPER(LEFT(d_drive,1))
            CALL DISK WITH diskit
            
            DO WHILE UPPER(diskit) = "X"
                * ========================================
                *$ Disk is not in the drive.  Prompt user
                * ========================================
                DO no_disk WITH d_drive
                
                IF LASTKEY() = 27
                    EXIT
                ENDIF (LASTKEY() = 27)
                diskit = UPPER(LEFT(d_drive,1))
                CALL DISK WITH diskit
            ENDDO (UPPER(diskit) = "X")
            
            IF LASTKEY() = 27
            * ===================================
            *$ Abort if user has pressed ESC key
            * ===================================
                EXIT
            ENDIF (LASTKEY() = 27)
            
            ACTIVATE WINDOW copying NOSHOW
            @ 0, 1 SAY "Copying lookup tables " + ;
               "to disk #&kounter."
            @ 1,11 SAY "Please wait..."
            SHOW WINDOW copying
            * =============================================
            *$ Check for presence of disk in floppy drive
            * =============================================
            CALL DISK WITH diskit
            
            DO WHILE UPPER(diskit) = 'X'
                * ===================================
                *$ Inform user no disk in drive and provide
                *$ option to abort
                * ====================================
                DO no_disk WITH d_drive
                
                IF LASTKEY() = 27
                * ===================================
                *$ Abort if user has pressed ESC key
                * ===================================
                    EXIT
                ELSE
                    STORE UPPER(LEFT(d_drive,1)) TO diskit
                    CALL DISK WITH diskit
                ENDIF (LASTKEY() = 27)
            ENDDO (UPPER(diskit) = 'X')

            IF LASTKEY() = 27 OR UPPER(diskit) = "X"
            * ===================================
            *$ Abort if user has pressed ESC key
            *$ or there is no floppy disk in drive
            * ===================================
                EXIT
            ENDIF (LASTKEY() = 27 OR UPPER(diskit) = "X")
            
            COPY NEXT tbl_recs TO &new_file
            SKIP 
            IF LASTKEY() <> 27 AND !EOF()
            * =====================================
            *$ Sound pleasant chime and if not end
            *  of file prompt user to put in another disk
            * =====================================
                DEACTIVATE WINDOW copying
                ACTIVATE WINDOW next_dsk NOSHOW
                @ 0, 3 SAY "Please remove disk #" + ;
                  "&kounter, insert"
                @ 1, 3 SAY "next disk for lookup tables"
                @ 2, 3 SAY "and press any " + ;
                   "key to continue..."
                SHOW WINDOW next_dsk
                CLEAR TYPEAHEAD
                DO nicechim
                = INKEY(0, "MH")
                DEACTIVATE WINDOW next_dsk
                * ===========================
                *$ Check for presence of disk 
                *$ in floppy drive
                * ===========================
                CALL DISK WITH diskit
                
                DO WHILE UPPER(diskit) = 'X'
                * ===================================
                *$ Inform user no disk in drive and provide
                *$ option to abort
                * ====================================
                    DO no_disk WITH d_drive
                    
                    IF LASTKEY() = 27
                    * ===================================
                    *$ Abort if user has pressed ESC key
                    * ===================================
                        EXIT
                    ELSE
                        STORE UPPER(LEFT(d_drive,1)) ;
                           TO diskit
                        CALL DISK WITH diskit
                    ENDIF (LASTKEY() = 27)
                ENDDO (UPPER(diskit) = 'X')

                IF LASTKEY() = 27 OR UPPER(diskit) = "X"
                * ===================================
                *$ Abort if user has pressed ESC key
                *$ or no floppy disk in the drive
                * ===================================
                    EXIT
                ENDIF (LASTKEY() = 27 OR              
                kounter = ALLTRIM(TRANSFORM(VAL(kounter) + ;
                    1, "@Z 999"))
            ENDIF (LASTKEY() <> 27 AND !EOF())
            
            IF LASTKEY() = 27 OR UPPER(diskit) = "X"
                EXIT
            ENDIF (LASTKEY() = 27 OR UPPER(diskit) = "X")
        ENDDO (.NOT. EOF())
        
        SET ORDER TO 1
        * =================================
        *$ Now backup the CANDIDAT database
        * ==================================
        SELECT candidat   && **************> Substitute
                          *****************> your own file
                          *****************> name here
        * =================================================
        *$ Determine if a new disk is required for CANDIDAT
        *$ file or if it can be placed on the same disk
        * =================================================
        dbf_top = HEADER()
        * ===============================
        *$ Get size of CANDIDAT database
        * ================================
        f_size = dbf_top + (RECSIZE() * RECCOUNT() + 1)
        STORE SET("DEFAULT") TO de_fault
        SET DEFAULT TO &d_drive
        STORE DISKSPACE() TO remaining
        SET DEFAULT TO &de_fault
        
        IF remaining < f_size
        * ===============================================
        *$ If there is not sufficient space on the floppy
        *  for the CANDIDAT database prompt user to insert
        *  a new blank disk
        * ================================================
            ACTIVATE WINDOW next_dsk
            @ 0, 3 SAY "Please remove disk #" + ;
               "&kounter, insert"
            @ 1, 3 SAY "next disk for lookup tables"
            @ 2, 3 SAY "and press any key to continue..."
            CLEAR TYPEAHEAD
            DO nicechim
            = INKEY(0, "MH")
            DEACTIVATE WINDOW next_dsk
            kounter = ALLTRIM(TRANSFORM(VAL(kounter) + ;
               1, "@Z 999"))
        ENDIF (remaining < f_size)
        
        SET ORDER TO 2              && Index is CAN_NAME
        GO TOP
        new_file = d_drive + "CANDIDAT"
        
        DO WHILE .NOT. EOF()
            diskit = UPPER(LEFT(d_drive,1))
            CALL DISK WITH diskit
            
            DO WHILE UPPER(diskit) = "X"
                * ========================================
                *$ Disk is not in the drive.  Prompt user
                * ========================================
                DO no_disk WITH d_drive
                
                IF LASTKEY() = 27 OR UPPER(diskit) = "X"
                * ===================================
                *$ Abort if user has pressed ESC key
                *$ or no floppy disk in the drive
                * ===================================
                    EXIT
                ENDIF (LASTKEY() = 27 OR 
                
                diskit = UPPER(LEFT(d_drive,1))
                CALL DISK WITH diskit
            ENDDO (UPPER(diskit) = "X")
            
            IF LASTKEY() = 27 OR UPPER(diskit) = "X"
            * ===================================
            *$ Abort if user has pressed ESC key
            *$ or no floppy disk in the drive
            * ===================================
                EXIT
            ENDIF (LASTKEY() = 27 OR UPPER(diskit) = "X")
            
            ACTIVATE WINDOW copying NOSHOW
            @ 0, 1 SAY "Copying lookup tables to " + ;
               "disk #&kounter."
            @ 1,11 SAY "Please wait..."
            SHOW WINDOW copying
            COPY NEXT can_recs TO &new_file
            SKIP
            
            IF LASTKEY() = 27 OR UPPER(diskit) = "X"
            * ===================================
            *$ Abort if user has pressed ESC key
            *$ or no floppy disk in the drive
            * ===================================
                EXIT
            ENDIF (LASTKEY() = 27 OR UPPER(diskit) = "X")
            
            IF .NOT. EOF()
            * =============================================
            *$ Sound pleasant chime and if not end
            *  of file prompt user to put in another disk
            * =============================================
                DEACTIVATE WINDOW copying
                ACTIVATE WINDOW next_dsk NOSHOW
                @ 0, 3 SAY "Please remove disk #" + ;
                  "&kounter, insert"
                @ 1, 3 SAY "next disk for lookup tables"
                @ 2, 3 SAY "and press any " + ;
                   "key to continue..."
                SHOW WINDOW next_dsk
                CLEAR TYPEAHEAD
                DO nicechim
                = INKEY(0, "MH")
                DEACTIVATE WINDOW next_dsk
                * ==============================
                *$ Check for presence of disk 
                *$ in floppy drive
                * ==============================
                CALL DISK WITH diskit
                
                DO WHILE UPPER(diskit) = 'X'
                * ===================================
                *$ Inform user no disk in drive and provide
                *$ option to abort
                * ====================================
                    DO no_disk WITH d_drive
                    
                    IF LASTKEY() = 27
                    * ===================================
                    *$ Abort if user has pressed ESC key
                    * ===================================
                        EXIT
                    ELSE
                        STORE UPPER(LEFT(d_drive,1)) ;
                           TO diskit
                        CALL DISK WITH diskit
                    ENDIF (LASTKEY() = 27)
                ENDDO (UPPER(diskit) = 'X')
                
                IF LASTKEY() = 27 OR UPPER(diskit) = "X"
                * ===================================
                *$ Abort if user has pressed ESC key
                *$ or no floppy disk in the drive
                * ===================================
                    EXIT
                ENDIF (LASTKEY() = 27 OR 
                
                kounter = ALLTRIM(TRANSFORM(VAL(kounter) + ;
                    1, "@Z 999"))
            ENDIF (.NOT. EOF())          

            IF LASTKEY() = 27 OR UPPER(diskit) = "X"
            * ===================================
            *$ Abort if user has pressed ESC key
            *$ or no floppy disk in the drive
            * ===================================
                EXIT
            ENDIF (LASTKEY() = 27 OR UPPER(diskit) = "X")
        ENDDO (.NOT. EOF())
        
        SET ORDER TO 1
       
        IF LASTKEY() = 27 OR UPPER(diskit) = "X"
        * ===================================
        *$ Abort if user has pressed ESC key
        *$ or no floppy disk in the drive
        * ===================================
            EXIT
        ENDIF (LASTKEY() = 27 OR UPPER(diskit) = "X")
    ENDIF (can_recs <> 0 AND LASTKEY() <> 27)
    
    IF whichfil = 4
        * ==============================================
        *$ If all files are being backed up now copy the
        *  files which hold the last ID numbers for the
        *  various DOTS_TBL data elements and candidate ID
        * ==============================================
        SET DEFAULT TO &d_drive
        STORE DISKSPACE() TO remaining
        * ============================================
        *$ Determine if enough space remains on floppy
        * ============================================
        SET DEFAULT TO &de_fault

        IF remaining < 600
            * ==========================================
            *$ If insufficient space on floppy prompt user
            *  to insert another floppy
            * ===========================================
            DO WHILE .T.
                ACTIVATE WINDOW next_dsk NOSHOW
                @ 0, 3 SAY "Please remove disk #" + ;
                  "&kounter, insert"
                @ 1, 3 SAY "next disk for lookup tables"
                @ 2, 3 SAY "and press any key " + ;
                   "to continue..."
                SHOW WINDOW next_dsk
                CLEAR TYPEAHEAD
                DO nicechim
                = INKEY(0, "MH")
                DEACTIVATE WINDOW next_dsk
                diskit = UPPER(LEFT(d_drive,1))
                CALL DISK WITH diskit
                
                IF UPPER(diskit) = "X"
                    * =================================
                    *$ If no disk in drive prompt user
                    * =================================
                    DO no_disk WITH d_drive                  
                    IF LASTKEY() <> 27
                        LOOP
                    ELSE
                    * ===================================
                    *$ Abort if user has pressed ESC key
                    * ===================================
                        EXIT
                    ENDIF (LASTKEY() <> 27)
                ELSE
                    EXIT
                ENDIF (UPPER(diskit) = "X")
            ENDDO (.T.)
        ENDIF (remaining < 600)
        
        IF LASTKEY() <> 27 AND UPPER(diskit) <> "X"
        * ==================================
        *$ These are small files so just copy 
        *$ each file to floppy
        * ==================================
            ACTIVATE WINDOW copying NOSHOW
            @ 0, 1 SAY "Copying lookup tables to " + ;
               "disk #&kounter."
            @ 1,11 SAY "Please wait..."
            SHOW WINDOW copying
            wholefile = d_drive + "ATTACKNO.DBF"
            COPY FILE \dots\attackno.dbf TO &wholefile
            wholefile = d_drive + "CAN_NO.DBF"
            COPY FILE \dots\can_no.dbf TO &wholefile
            wholefile = d_drive + "MAJOR_NO.DBF"
            COPY FILE \dots\major_no.dbf TO &wholefile
            wholefile = d_drive + "MINOR_NO.DBF"
            COPY FILE \dots\minor_no.dbf TO &wholefile
            wholefile = d_drive + "SIGNF_NO.DBF"
            COPY FILE \dots\signf_no.dbf TO &wholefile
            wholefile = d_drive + "SOURCENO.DBF"
            COPY FILE \dots\sourceno.dbf TO &wholefile
        ENDIF (LASTKEY() <> 27 AND UPPER(diskit) <> "X")
    ENDIF (whichfil = 4)
    
    RELEASE WINDOW copying
    RELEASE WINDOW next_dsk
    RELEASE MODULE DISK
    
    IF LASTKEY() <> 27
        DEFINE WINDOW finished FROM 8,22 TO 13,57 DOUBLE ;
            COLOR N/W,N/W,*R/W SHADOW
        ACTIVATE WINDOW finished
        @ 0, 2 SAY "The backup has been completed."
        @ 2, 2 SAY "Press any key to return to"
        @ 3, 2 SAY "the main screen and window..."
        CLEAR TYPEAHEAD
        DO go_horn
        = INKEY(0, "MH")
        RELEASE WINDOW finished
    ENDIF (LASTKEY() <> 27)
    
    EXIT
ENDDO (LASTKEY() <> 27)

ON KEY
SELECT dotsdata   && **************> Substitute
                   *****************> your own file
                   *****************> name here
GO BOTTOM
SKIP -1
RELEASE POPUP maintain
RELEASE POPUP whichfil
RELEASE POPUP the_disk
RELEASE MODULE DISK
CLEAR WINDOWS
SET COLOR TO W/N
CLEAR
DO sayscrn    && Provides windows and SAYs to screen
DO saydata    && Displays record data with SAYs
CLEAR TYPEAHEAD
RETURN
* End Procedure BACKUP
*!******************************************************
PROCEDURE yes_no
********************************************************
*& Get user Y/N input and return appropriate value
*
*   Author: Pat Adams, DB Unlimited
*   Date: 12/3/90
*   Copyright 1990, 1991 DB Unlimited
*
*   The passed parameter, USER_INPUT, is returned as
*   either a .T. or .F. value
* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
PARAMETERS user_input
PRIVATE curs_set, kkey
STORE SET("CURSOR") TO curs_set
SET CURSOR OFF
* =================================
* Error Trapping for Yes/No Response
* =================================
CLEAR TYPEAHEAD
STORE 0 TO kkey

DO WHILE kkey = 0
    kkey = INKEY()
    IF kkey > 0
        * =============================
        * Function keys 2 thru 9 return
        * negative values.  This sets up
        * error trapping for that condition.
        * =============================
        IF CHR(kkey) $ "YyNn"
            IF CHR(kkey) $ "Yy"
                STORE .T. TO user_input
            ELSE
                STORE .F. TO user_input
            ENDIF (CHR(kkey) $ "Yy")
        ELSE
            STORE 0 TO kkey
        ENDIF (CHR(kkey) $ "YyNn")
    ELSE
        STORE 0 TO kkey
    ENDIF (kkey > 0)
ENDDO (kkey = 0)

SET CURSOR &curs_set
CLEAR TYPEAHEAD
RETURN user_input
* END Procedure YES_NO