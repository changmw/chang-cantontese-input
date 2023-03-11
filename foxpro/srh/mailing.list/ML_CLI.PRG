*---------------------------------------------------------------------------*
* Client Database Maint.
*
* Nov 22, 1991          Clean up the code in CLI_ATTR. Now runs faster
*
*--------------------------------------------------------------------------*
PROCEDURE COM_CLI
  PRIVATE I_MAS, I_INIT, I_FN, I_LN, I_TIT, I_DEPT, I_TEL, I_TDIR, ;
          I_TLX, I_FAX, I_CODE, I_MDATE, W_HEAD, M_AREA

  I_MDATE= SPACE(1)
  I_MAS  = SPACE(1)
  I_INIT = SPACE(1)
  I_FN   = SPACE(1)
  I_LN   = SPACE(1)
  I_TIT  = SPACE(1)
  I_DEPT = SPACE(1)
  I_TEL  = SPACE(1)
  I_TDIR = SPACE(1)
  I_TLX  = SPACE(1)
  I_FAX  = SPACE(1)
  I_CODE = SPACE(1)

  DEFINE WINDOW W_FKEY11 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W
  DEFINE WINDOW W_BRCLI FROM 04,01 TO 22,69 SHADOW ;
         COLOR W/N,N/W,N/W,N/W,W/N,N/W,N/W,N/N,N/W,W/N,N/W

  W_HEAD=SHOWHEAD('CLIENT CODES MAINTENANCE')
  =SHOWFKEY(01,'F1','SORT','W_FKEY11')
  =SHOWFKEY(15,'F2','SEARCH','W_FKEY11')
  =SHOWFKEY(30,'F3','CHANGE ATTRIBUTES','W_FKEY11')
  =SHOWFKEY(50,'F4','VIEW ATTRIBUTES','W_FKEY11')

  push key clear
  ON KEY LABEL INS   DO ADD_CLI with COMPANY.COM_CODE
  ON KEY LABEL DEL   DO DEL_CLI
  ON KEY LABEL ENTER DO EDIT_CLI
  ON KEY LABEL F1    DO SORT_CLI
  ON KEY LABEL F2    DO SRCH_CLI
  ON KEY LABEL F3    DO CLI_ATTR
  ON KEY LABEL F4    DO VW_ATTR

  SELECT 0
  USE &ML_PATH.CTRL alias CTRL
  if used('CTRL')
    SELECT 0        && CLIENT MASTER
    USE &ML_PATH.CLIENT ALIAS CLIENT
    IF USED('CLIENT')
      set order to tag COM_CODE

      select CLIENT
      browse fields NAME=PADR(ALLTRIM(L_NAME)+', '+F_NAME,30,' '):H="NAME", ;
                    TIT:15:H="TITLE", ;
                    COM_CODE:H="COMPANY", ;
                    MODI_DATE:H="MODIFIED" ;
             for    COM_CODE = COMPANY.COM_CODE ;
             noappend nodelete nomodify window W_BRCLI ;
             title 'CLIENTS OF '+alltrim(COMPANY.COM_NAME)
      use in CLIENT
    ELSE
      =ERRMSG('Client Master File in use. Try later!')
    ENDIF
    use in CTRL
  else
    =ERRMSG('Client number file in use. Try later!')
  endif

  RELEASE WINDOW W_BRCLI
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_FKEY11
  pop key
  select COMPANY
RETURN

PROCEDURE CLI_MAIN
  PRIVATE I_MAS, I_INIT, I_FN, I_LN, I_TIT, I_DEPT, I_TEL, I_TDIR, ;
          I_TLX, I_FAX, I_CODE, I_MDATE, W_HEAD

  I_MDATE= SPACE(1)
  I_MAS  = SPACE(1)
  I_INIT = SPACE(1)
  I_FN   = SPACE(1)
  I_LN   = SPACE(1)
  I_TIT  = SPACE(1)
  I_DEPT = SPACE(1)
  I_TEL  = SPACE(1)
  I_TDIR = SPACE(1)
  I_TLX  = SPACE(1)
  I_FAX  = SPACE(1)
  I_CODE = SPACE(1)

  DEFINE WINDOW W_FKEY11 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W
  DEFINE WINDOW W_BRCLI FROM 04,10 TO 22,78 SHADOW ;
         COLOR W/N,N/W,N/W,N/W,W/N,N/W,N/W,N/N,N/W,W/N,N/W

  W_HEAD=SHOWHEAD('CLIENT CODES MAINTENANCE')
  DO SHOWFKEY WITH 01,'F1','SORT','W_FKEY11'
  DO SHOWFKEY WITH 15,'F2','SEARCH','W_FKEY11'
  DO SHOWFKEY WITH 30,'F3','CHANGE ATTRIBUTES','W_FKEY11'
  DO SHOWFKEY WITH 50,'F4','VIEW ATTRIBUTES','W_FKEY11'

  SELECT 0
  USE &ML_PATH.CTRL alias CTRL
  if used('CTRL')
    select 0
    use &ML_PATH.COMPANY alias COMPANY
    IF USED('COMPANY')
      set order to tag COM_CODE

      SELECT 0        && CLIENT MASTER
      USE &ML_PATH.CLIENT ALIAS CLIENT
      IF USED('CLIENT')
        set order to tag COM_CODE
        set relation to COM_CODE into COMPANY

        push key clear
        on key label INS   do ADD_CLI with space(len(COM_CODE))
        on key label DEL   do DEL_CLI
        on key label ENTER do EDIT_CLI
        on key label F1    do SORT_CLI
        on key label F2    do SRCH_CLI
        on key label F3    do CLI_ATTR
        on key label F4    do VW_ATTR

        SELECT CLIENT
        BROWSE FIELDS NAME=PADR(ALLTRIM(L_NAME)+', '+F_NAME,30,' '):H="NAME", ;
                      TIT:15:H="TITLE", ;
                      COM_CODE:H="COMPANY", ;
                      MODI_DATE:H="MODIFIED" ;
               NOAPPEND NODELETE NOMODIFY WINDOW W_BRCLI ;
               TITLE 'CLIENT'

        pop key
        use in CLIENT
      ELSE
        =ERRMSG('Client Master File in use. Try later!')
      ENDIF
      use in COMPANY
    ELSE
      =ERRMSG('Company Master File in use. Try later!')
    ENDIF
    use in CTRL
  else
    =ERRMSG('Client number file in use. Try later!')
  endif

  RELEASE WINDOW W_BRCLI
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_FKEY11
RETURN

PROCEDURE SORT_CLI
  push key clear
  do HOOKF10

  DEFINE WINDOW W_TEMP FROM 05,10 TO 09,23 NONE SHADOW
  ACTIVATE WINDOW W_TEMP

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_SORTCLI FROM 00,00
  DEFINE BAR 1 OF W_SORTCLI PROMPT 'CLIENT CODE'
  DEFINE BAR 2 OF W_SORTCLI PROMPT 'LAST NAME'
  DEFINE BAR 3 OF W_SORTCLI PROMPT 'COMPANY CODE'
  ON SELECTION POPUP W_SORTCLI DO CHG_ORDER WITH BAR()

  ACTIVATE POPUP W_SORTCLI

  RELEASE POPUP W_SORTCLI
  RELEASE WINDOW W_TEMP

  pop key
RETURN

PROCEDURE CHG_ORDER
  PARAMETERS M_ORDER

  do case
    case M_ORDER=1
      set order to tag MAS_CODE
    case M_ORDER=2
      set order to tag NAME
    case M_ORDER=3
      set order to tag COM_CODE
  endcase
  KEYBOARD CHR(K_ESC)
RETURN

PROCEDURE CLI_CLRM
  I_MAS  = 0
  I_INIT = SPACE(LEN(CLIENT.INIT))
  I_FN   = SPACE(LEN(CLIENT.F_NAME))
  I_LN   = SPACE(LEN(CLIENT.L_NAME))
  I_TIT  = SPACE(LEN(CLIENT.TIT))
  I_DEPT = SPACE(LEN(CLIENT.DEPT))
  I_TEL  = SPACE(LEN(CLIENT.TEL))
  I_TDIR = SPACE(LEN(CLIENT.TEL_DIR))
  I_TLX  = SPACE(LEN(CLIENT.TELEX))
  I_FAX  = SPACE(LEN(CLIENT.FAX))
  I_CODE = SPACE(LEN(CLIENT.COM_CODE))
  I_MDATE= SYSDATE
RETURN

PROCEDURE CLI_MOVF
  PARAMETERS M_SAVEKEY

  SELECT CLIENT
  IF M_SAVEKEY
    REPLACE MAS_CODE WITH I_MAS
  ENDIF
  REPLACE INIT WITH I_INIT, L_NAME WITH I_LN, ;
          F_NAME WITH I_FN, TIT WITH I_TIT, ;
          DEPT WITH I_DEPT, TEL WITH I_TEL, ;
          TEL_DIR WITH I_TDIR, TELEX WITH I_TLX, ;
          FAX WITH I_FAX, COM_CODE WITH I_CODE, ;
          MODI_DATE WITH SYSDATE
RETURN

FUNCTION V_COM
  PARAMETER M_COM
  PRIVATE M_OSEL, M_RC

  M_OSEL=SELECT()

  SELECT COMPANY
  LOCATE FOR COM_CODE=M_COM
  IF FOUND()
    @ 05,16 SAY COM_NAME
    M_RC=.T.
  ELSE
    DO ERRMSG WITH 'COMPANY CODE NOT FOUND !!'
    M_RC=0
  ENDIF

  SELECT (M_OSEL)
RETURN M_RC

PROCEDURE CLI_GETM
  PARAMETER M_NEW

  DEFINE WINDOW W_CLIGET FROM 03,03 TO 18,73 ;
         COLOR W/N,W/N,W/N,W+/N PANEL SHADOW ;
         title iif(M_NEW,"ADD","EDIT")+" CLIENT"
  DEFINE WINDOW W_FKEY40 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W

  DO SHOWFKEY WITH 01,'ESC','CANCEL','W_FKEY40'
  DO SHOWFKEY WITH 15,'PGDN','NEXT','W_FKEY40'
  DO SHOWFKEY WITH 30,'PGUP','PREVIOUS','W_FKEY40'
  DO SHOWFKEY WITH 65,'F10','SAVE','W_FKEY40'

  ACTIVATE WINDOW W_CLIGET
  do while .t.
    @ 00,     01 SAY 'CLIENT CODE :  ' + STR(I_MAS,5,0)
    @ ROW(),  35 SAY 'LAST MODIFIED: ' + DTOC(I_MDATE)
    @ ROW()+1,01 SAY 'MRS/MR/MS :    ' GET I_INIT PICTURE '@!'
    @ ROW()+1,01 SAY 'LAST NAME :    ' GET I_LN   PICTURE '@!'
    @ ROW()+1,01 SAY 'FIRST NAME :   ' GET I_FN   PICTURE '@!'
    @ ROW()+1,01 SAY 'COMPANY CODE : ' GET I_CODE PICTURE '@!' VALID V_COM(I_CODE)
    @ ROW()+2,01 SAY 'TITLE :        ' GET I_TIT  PICTURE '@!'
    @ ROW()+1,01 SAY 'DEPARTMENT :   ' GET I_DEPT PICTURE '@!'
    @ ROW()+1,01 SAY 'PHONE OFFICE : ' GET I_TEL  PICTURE '@!'
    @ ROW()+1,01 SAY 'PHONE DIRECT : ' GET I_TDIR PICTURE '@!'
    @ ROW()+1,01 SAY 'TELEX :        ' GET I_TLX  PICTURE '@!'
    @ ROW()+1,01 SAY 'FAX :          ' GET I_FAX  PICTURE '@!'
    READ
    if lastkey()=K_ESC .or. lastkey()=K_C_W .or. lastkey()=K_PGDN .or. ;
       lastkey()=K_PGUP
      exit
    endif
  enddo

  RELEASE WINDOW W_FKEY40
  RELEASE WINDOW W_CLIGET
RETURN

*-------------------------------------------*
*  Client Data Movement (DBF --> Variable)  *
*-------------------------------------------*
PROCEDURE CLI_MOVM
  I_MAS  = MAS_CODE
  I_INIT = INIT
  I_LN   = L_NAME
  I_FN   = F_NAME
  I_TIT  = TIT
  I_DEPT = DEPT
  I_TEL  = TEL
  I_TDIR = TEL_DIR
  I_TLX  = TELEX
  I_FAX  = FAX
  I_CODE = COM_CODE
  I_MDATE= MODI_DATE
RETURN

*--------------*
*  Add Client  *
*--------------*
*  MAINT.
PROCEDURE ADD_CLI
  parameters M_CODE
  PRIVATE M_TEMP

  push key clear
  do HOOKF10

  DO CLI_CLRM
  I_CODE = M_CODE           && default company code
  DO WHILE LASTKEY()#K_ESC
    DO CLI_GETM with .t.    && user requested not to clear memory each time
    IF LASTKEY()=K_C_W
      SELECT CTRL
      LOCATE FOR DBF_NAME='CLIENT'
      IF FOUND() and RLOCK()
        I_MAS = LAST_NO + 1
        REPLACE LAST_NO WITH I_MAS

        SELECT CLIENT
        APPEND BLANK
        DO CLI_MOVF WITH .T.
        DO ENTERLOG with SYSDATE, U_NAME, "A", alias(), ;
                         I_CODE+space(1)+;
                         alltrim(I_LN)+space(1)+I_FN ;
                         IN ML_LOG
        M_TEMP=I_CODE

        SELECT CTRL
        UNLOCK
      ELSE
        =ERRMSG('CONTROL RECORD IN USE. PLEASE TRY AGAIN LATER !!')
      ENDIF
      UNLOCK IN CLIENT
    ENDIF
  ENDDO

  SELECT CLIENT
  pop key
RETURN

PROCEDURE EDIT_CLI
  push key clear
  do HOOKF10

  IF RLOCK()
    DO CLI_MOVM
    DO WHILE .T.
        DO CLI_GETM with .f.
        do case
          case lastkey() = K_C_W
            do CLI_MOVF WITH .F.
            DO ENTERLOG with SYSDATE, U_NAME, "E", alias(), ;
                             I_CODE+space(1)+alltrim(I_LN)+;
                             space(1)+alltrim(I_FN) ;
                             IN ML_LOG
            unlock in CLIENT
            exit
          case lastkey() = K_ESC
            unlock in CLIENT
            exit
          case lastkey() = K_PGDN
            unlock in CLIENT
            skip
            if eof()
              skip -1
            endif
            DO CLI_MOVM
          case lastkey() = K_PGUP
            unlock in CLIENT
            skip -1
            if bof()
              skip
            endif
            DO CLI_MOVM
        endcase
    ENDDO
  ELSE
    DO ERRMSG WITH 'RECORD IN USE. TRY EDITING LATER !!'
  ENDIF

  SELECT CLIENT

  pop key
RETURN

procedure VW_ATTR
  push key clear

  IF RLOCK()
    SELECT 0                        && FOR SHOWING AVAILABLE BUSINESS NATURE,
    USE &ML_PATH.CATEG ALIAS CATEG   && PUBLICATION AND DIRECTOR
    IF FLOCK()
      set order to tag CAT_CODE

      SELECT 0
      USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
      IF FLOCK()
        set relation to AUX_CODE into CATEG

        define window W_CLA from 05,05 to 07,40 shadow color n/w,n/w,n/w
        define window W_FKEY13 FROM 24,00 TO 24,79 ;
                      none noshadow color n/w,n/w,n/w
        define window W_BRAUX  from 03,44 to 22,79 shadow ;
                      color w/n,n/w,n/w,n/w,w/n,n/w,n/w,n/n,n/w,w/n,n/w

        =SHOWFKEY(01,'ESC','RETURN','W_FKEY13')

        activate window W_CLA
        ? alltrim(CLIENT.F_NAME)+space(1)+alltrim(CLIENT.L_NAME)

        select AUX_MAS
        browse fields ;
           CATEG.CAT_CODE:h="CODE", ;
           CATEG.CAT_DESC:h="DESCRIPTION" ;
         for MAS_CODE=CLIENT.MAS_CODE ;
         freeze CATEG.CAT_CODE ;
         noappend nodelete nomodify window W_BRAUX ;
         title "ASSOCIATING ATTRIBUTES"

        use in AUX_MAS
        release window W_CLA
        release window W_BRAUX
        release window W_FKEY13
      ELSE
        =ERRMSG('ATTRIBUTES RECORDS IN USE. TRY LATER !!')
      ENDIF
      use in CATEG
    ELSE
      =ERRMSG('ATTRIBUTE CLASS DATABASE IN USE. TRY LATER !!')
    ENDIF
    * CLOSE ATTRIBUTES FILES
  ELSE
    =ERRMSG('CLIENT RECORD IN USE. TRAY AGAIN LATER !!')
  ENDIF

  pop key
return

* ASSOCIATING ATTRIBUTES TO CLIENT: PUBLICATION, DIRECTOR AND BUSINESS NATURE
procedure CLI_ATTR
  private M_TEMP, M_ATTR, M_CURRENT, M_AGAIN, M_I
  declare M_ATTR[7,2]

  M_ATTR[1,1]="O"
  M_ATTR[2,1]="D"
  M_ATTR[3,1]="T"
  M_ATTR[6,1]="B"
  M_ATTR[5,1]="P"
  M_ATTR[4,1]="1"
  M_ATTR[7,1]="2"

  M_ATTR[1,2]="Position"
  M_ATTR[2,2]="Director"
  M_ATTR[3,2]="Circulation"
  M_ATTR[6,2]="Business Nature"
  M_ATTR[5,2]="Publication"
  M_ATTR[4,2]="Key Clients"
  M_ATTR[7,2]="SRG News"

  M_CURRENT=1       && current window of attribute class

  push key clear
  do HOOKF10

  define window W_KEYBOX from 10,05 to 20,35 shadow color N/W
  define window W_MSG    from 05,20 to 07,60 shadow color N/W,N/W,N/W
  define window W_FKEY13 from 24,00 to 24,79 none noshadow color N/W,N/W,N/W
  define window W_BRAUX  from 03,44 to 22,79 shadow ;
         color W/N,N/W,N/W,N/W,W/N,N/W,N/W,N/N,N/W,W/N,N/W

  =SHOWFKEY(01,'ESC','DONE','W_FKEY13')
  =SHOWFKEY(25,'','PREVIOUS','W_FKEY13')
  =SHOWFKEY(50,'','NEXT','W_FKEY13')

  if rlock()
    select 0                        && FOR SHOWING AVAILABLE BUSINESS NATURE,
    use &ML_PATH.CATEG alias CATEG   && PUBLICATION AND DIRECTOR
    if flock()
      set order to tag CAT_CODE

      select 0
      use &ML_PATH.AUX_MAS alias AUX_MAS
      if flock()
        activate window W_MSG
        ? 'SEARCHING ATTRIBUTES ...'

        * Country code are not available to clients
        select CATEG
        replace all FLAG with space(1)    && CLEAR FLAG SETTINGS

        * show selected attributes
        * only COMPANY's business nature are marked 'B'
        * CLIENT's business nature are marked 'G'
        SELECT AUX_MAS
        SCAN ALL FOR MAS_CODE = CLIENT.MAS_CODE
          SELECT CATEG
          SEEK AUX_MAS.AUX_CODE
          IF FOUND()
            REPLACE FLAG WITH '*'
          ENDIF
        ENDSCAN
        DEACTIVATE WINDOW W_MSG

        * user add/delete attribute
        push key clear
        on key label leftarrow  DO PREV_WIN
        on key label rightarrow DO NEXT_WIN
        on key label esc        DO DONE
        define window W_CLA from 05,05 to 07,40 shadow color n/w,n/w,n/w
        activate window W_CLA
        ? alltrim(CLIENT.F_NAME)+space(1)+alltrim(CLIENT.L_NAME)

        activate window W_KEYBOX
        for M_I=1 to 7
          @ 01+M_I-1,02 say str(M_I,1,0)+space(2)+M_ATTR[M_I, 2]
        endfor

        select CATEG
        M_AGAIN=.t.
        do while M_AGAIN
          browse fields FLAG:V=V_ATTR():H=SPACE(2), ;
                        A=CAT_CODE+' - '+CAT_DESC:H="CODE - DESCRIPTION":R ;
                 for CAT_TYPE = M_ATTR[M_CURRENT,1] ;
                 freeze FLAG ;
                 noappend nodelete window W_BRAUX  ;
                 title str(M_CURRENT,2,0)+space(1)+M_ATTR[M_CURRENT,2]
        enddo

        release window W_CLA
        pop key

        * re-construct attributes for the current client
        IF "Y"=ASKYN("SAVE ATTRIBUTE CHANGES")
          activate window W_MSG

          ? 'ASSIGNING NEW ATTRIBUTES ... '
          select CATEG
          set order to tag CAT_CODE
          set filter to
          scan all for .not. empty(CATEG.FLAG)
            * check attribuate already acquired
            select AUX_MAS
            locate for AUX_CODE=CATEG.CAT_CODE and ;
                       MAS_CODE=CLIENT.MAS_CODE

            DO CASE
              CASE CATEG.FLAG='+'
                if .NOT. found()
                  * IF ATTRIBUTE NOT YET ACQUIRED, CREATE IT
                  select AUX_MAS
                  append blank
                  replace MAS_CODE with CLIENT.MAS_CODE, ;
                          COM_CODE with CLIENT.COM_CODE, ;
                          COU_CODE with COMPANY.COU_CODE,;
                          AUX_CODE with CATEG.CAT_CODE
                  if CATEG.CAT_TYPE='B'
                    REPLACE AUX_TYPE WITH 'G'
                  else
                    REPLACE AUX_TYPE WITH CATEG.CAT_TYPE
                  endif
                  do ENTERLOG with SYSDATE, U_NAME, "A", "CLIENT", ;
                                   AUX_CODE + space(1) +;
                                   CLIENT.COM_CODE + space(1)+;
                                   alltrim(CLIENT.L_NAME)+space(1)+ ;
                                   alltrim(CLIENT.F_NAME) ;
                              in ML_LOG
                endif
              CASE CATEG.FLAG='-'         && REMOVE ATTRIBUTE
                IF found()
                  SELECT AUX_MAS
                  DO ENTERLOG with SYSDATE, U_NAME, "D", "CLIENT", ;
                                   AUX_MAS.AUX_CODE + space(1) +;
                                   CLIENT.COM_CODE+space(1) +;
                                   CLIENT.L_NAME+space(1)+ ;
                                   CLIENT.F_NAME ;
                                   IN ML_LOG
                  DELETE
                ENDIF
            ENDCASE
            REPLACE CATEG.FLAG WITH SPACE(1)
          ENDSCAN
        ENDIF
        use in AUX_MAS
      ELSE
        =ERRMSG('ATTRIBUTES RECORDS IN USE. TRY LATER !!')
      ENDIF
      use in CATEG
    ELSE
      =ERRMSG('ATTRIBUTE CLASS DATABASE IN USE. TRY LATER !!')
    ENDIF
    * CLOSE ATTRIBUTES FILES
  ELSE
    =ERRMSG('CLIENT RECORD IN USE. TRAY AGAIN LATER !!')
  ENDIF

  * RELEASE UN-USED WINDOWS
  release window W_BRAUX
  release window W_FKEY13
  release window W_MSG
  release window W_KEYBOX
  pop key
RETURN

procedure NEXT_WIN
  push key clear
  M_CURRENT = M_CURRENT+1
  if M_CURRENT > 7
    M_CURRENT = 1
  endif
  keyboard chr(K_C_W)
  pop key
return

procedure PREV_WIN
  push key clear
  M_CURRENT = M_CURRENT-1
  if M_CURRENT < 1
    M_CURRENT = 7
  endif
  keyboard chr(K_C_W)
  pop key
return

procedure DONE
  on key label esc
  keyboard chr(K_C_W)
  M_AGAIN = .f.
return

*-----------------*
*  Delete Client  *
*-----------------*
*  MAINT.
PROCEDURE DEL_CLI
  push key clear

  if U_LEVEL = 0
    DEFINE WINDOW W_MSG FROM 10,05 TO 12,50 SHADOW

    IF RLOCK()
      IF 'Y'=ASKYN('DELETE CLIENT')
        SELECT 0
        USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
        IF FLOCK()
          set order to tag MAS_CODE

          *SET INDEX TO &ML_PATH.AUX_MAS2, &ML_PATH.AUX_MAS1, ;
          *             &ML_PATH.AUX_MAS3, &ML_PATH.AUX_MAS4

          ACTIVATE WINDOW W_MSG
          ? 'DELETING ATTRIBUTES ....'
          SEEK CLIENT.MAS_CODE
          * REMOVE ATTRIBUTES RECORD IN AUX_MAS FOR THIS CLIENT FIRST
          IF FOUND()
            DELETE FOR COM_CODE=CLIENT.COM_CODE WHILE MAS_CODE=CLIENT.MAS_CODE
          ENDIF

          SELECT CLIENT
          I_CODE = CLIENT.COM_CODE
          I_LN   = CLIENT.L_NAME
          DELETE
          DO ENTERLOG with SYSDATE, U_NAME, "D", alias(), ;
                           I_CODE+space(1)+alltrim(I_LN)+;
                           space(1)+I_FN IN ML_LOG
        ELSE
          DO ERRMSG WITH 'CLIENT DATABASE IN USE. TRY AGAIN LATER !!'
        ENDIF
        SELECT AUX_MAS
        USE
      ENDIF
      UNLOCK IN CLIENT
    ELSE
      =ERRMSG('RECORD IN USE. PLEASE TRY AGAIN LATER !!')
    ENDIF

    SELECT CLIENT
    RELEASE WINDOW W_MSG
  ELSE
    =ERRMSG("YOU ARE NOT AUTHORIZED TO DELETE CLIENT!")
  ENDIF
  pop key
RETURN

*-----------------------------*
*  Partial  Client  USING PARTIAL KEY
*-----------------------------*
PROCEDURE SRCH_CLI
  PRIVATE M_RECNO

  push key clear

  DO CLI_CLRM

  DEFINE WINDOW W_SRCH FROM 05,15 TO 14,65 ;
                SHADOW TITLE " SEARCH A CLIENT BY " ;
                color g/n,,g+/n,gb+/n
  ACTIVATE WINDOW W_SRCH

  I_MDATE=CTOD('')
  I_MAS  =0

  @ wrows()-1,02 say "F10 - Start" color w+/n
  @ 01,02 SAY 'COMPANY CODE = ' GET I_CODE PICTURE '@!'
  @ 02,02 SAY 'FIRST NAME   = ' GET I_FN   PICTURE '@!'
  @ 03,02 SAY 'LAST NAME    = ' GET I_LN   PICTURE '@!'
  @ 04,02 SAY 'MODI. DATE   = ' GET I_MDATE PICTURE '@!'
  @ 05,02 SAY 'CLIENT CODE  = ' GET I_MAS PICTURE '@!'
  READ

  * CLEAR FILTER BY DEFAULT
  IF LASTKEY() = K_ESC
    M_RECNO=RECNO()
    SET FILTER TO
    GO TOP
    if M_RECNO#0
      goto M_RECNO
    endif
  ELSE
    * BUILD FILTER STRING
    SELECT CLIENT
    DO CASE
      CASE .NOT. EMPTY(I_MDATE)
        SET FILTER TO MODI_DATE > I_MDATE
        GO TOP
      CASE .NOT. EMPTY(I_LN)
        SET FILTER TO ALLTRIM(I_LN)$L_NAME
        GO TOP
      CASE .NOT. EMPTY(I_FN)
        SET FILTER TO ALLTRIM(I_FN)$F_NAME
        GO TOP
      CASE .NOT. EMPTY(I_CODE)
        SET FILTER TO
        GO TOP
        IF .NOT. EOF()
          M_RECNO=RECNO()
          SET EXACT OFF
          SEEK ALLTRIM(I_CODE)
          SET EXACT ON
          IF .NOT. FOUND()
            GOTO M_RECNO
            =ERRMSG('COMPANY CODE NOT FOUND !!!')
          ENDIF
        ELSE
          =ERRMSG('NO RECORD TO SEARCH. CLEAR FILTER FIRST !!')
        ENDIF
      CASE I_MAS > 0
        LOCATE FOR MAS_CODE=I_MAS
    ENDCASE
  ENDIF

  RELEASE WINDOW W_SRCH
  pop key
RETURN
