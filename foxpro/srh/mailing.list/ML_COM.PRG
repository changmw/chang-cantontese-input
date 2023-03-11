**---------------------------*-----------------------------------------*
*|  Company Database Maint.                                            |
*
* Nov 22, 1991          Clean up the code used to assign attributes to
*                       clients. Now runs faster
*
**---------------------------*-----------------------------------------*
  PRIVATE I_CODE, I_NAME, I_COU, I_CLI, I_ACC, I_ADD, W_HEAD
  DECLARE I_ADD[4]

  I_CODE   = SPACE(1)
  I_NAME   = SPACE(1)
  I_ADD[1] = SPACE(1)
  I_ADD[2] = SPACE(1)
  I_ADD[3] = SPACE(1)
  I_ADD[4] = SPACE(1)
  I_COU    = SPACE(1)
  I_CLI    = SPACE(1)
  I_ACC    = SPACE(1)
      
  DEFINE WINDOW W_FKEY12 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W
  DEFINE WINDOW W_BRCOM FROM 04,15 TO 22,78 SHADOW ;
         COLOR W/N,N/W,N/W,N/W,W/N,N/W,N/W,N/N,N/W,W/N,N/W

  W_HEAD=SHOWHEAD('COMPANY CODES MAINTENANCE')
  DO SHOWFKEY WITH 01,'F1','SORT','W_FKEY12'
  DO SHOWFKEY WITH 15,'F2','SEARCH','W_FKEY12'
  DO SHOWFKEY WITH 30,'F3','ATTRIBUTE','W_FKEY12'
  DO SHOWFKEY WITH 45,'F4','CLIENTS','W_FKEY12'

  SELECT 0
  USE &ML_PATH.COMPANY ALIAS COMPANY
  IF USED('COMPANY')
    set order to tag COM_NAME

    push key clear
    ON KEY LABEL INS   DO ADD_COM
    ON KEY LABEL DEL   DO DEL_COM
    ON KEY LABEL ENTER DO EDIT_COM
    ON KEY LABEL F1    DO SORT_COM
    ON KEY LABEL F2    DO SRCH_COM
    ON KEY LABEL F3    DO COM_ATTR
    on key label F4    do COM_CLI in ML_CLI

    BROWSE FIELDS COM_CODE:H="CODE", ;
                  COM_NAME:H="NAME", ;
                  MODI_DATE:H="MODI DATE" ;
           NOAPPEND NODELETE NOMODIFY WINDOW W_BRCOM ;
           TITLE 'COMPANY'
    pop key
    use in COMPANY
  ELSE
    =ERRMSG('Company Master File in use. Try later!')
  ENDIF

  RELEASE WINDOW W_BRCOM
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_FKEY12
RETURN

FUNCTION V_DUCOM
  PARAMETER I_CODE

  IF EMPTY(I_CODE)
    DO ERRMSG WITH 'COMPANY CODE CANNOT BE BLANK!'
    RETURN 0
  ENDIF

  SELECT COMPANY
  SET ORDER TO COM_CODE
  SEEK I_CODE
  IF FOUND()
    DO ERRMSG WITH 'COMPANY CODE ALREADY IN USE !!'
    RETURN 0
  ENDIF
RETURN .T.

PROCEDURE SORT_COM
  push key clear
  do HOOKF10

  DEFINE WINDOW W_TEMP FROM 05,10 TO 08,23 NONE SHADOW
  ACTIVATE WINDOW W_TEMP

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_SORTCLI FROM 00,00
  DEFINE BAR 1 OF W_SORTCLI PROMPT 'COMPANY CODE'
  DEFINE BAR 2 OF W_SORTCLI PROMPT 'COMPANY NAME'
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
      set order to tag COM_CODE
    case M_ORDER=2
      set order to tag COM_NAME
  endcase
  KEYBOARD CHR(K_ESC)
RETURN

*--------------------*
*  Get Company Data  *            
*--------------------*
PROCEDURE COM_GETM
  PARAMETERS M_NEW

  push key clear
  do HOOKF10

  DEFINE WINDOW W_COMGET FROM 12,07 TO 22,77 SHADOW ;
         color W/N,,,G+/N title iif(M_NEW,"ADD", "EDIT")+" COMPANY"
  DEFINE WINDOW W_FKEY41 FROM 24,00 TO 24,79 ;
         NONE NOSHADOW COLOR N/W,N/W,N/W
  DO SHOWFKEY WITH 01,'ESC','CANCEL','W_FKEY41'
  DO SHOWFKEY WITH 65,'F10','SAVE','W_FKEY41'
  ACTIVATE WINDOW W_COMGET

  set notify off
  @ 00,     05 SAY 'COMPANY CODE: ' GET I_CODE   PICTURE '@!' ;
                                    VALID V_DUCOM(I_CODE) WHEN M_NEW
  @ row()+1,05 SAY 'NAME:         ' GET I_NAME   PICTURE '@!' ;
               WHEN M_NEW .or. (U_LEVEL = 0)
  @ row()+1,05 SAY 'COMPANY TYPE: ' GET I_CLI    PICTURE '@!' WHEN U_LEVEL=0
  @ row()+1,05 SAY 'ADDRESS  -1:  ' GET I_ADD[1] PICTURE '@!'
  @ row()+1,05 SAY '         -2:  ' GET I_ADD[2] PICTURE '@!'
  @ row()+1,05 SAY '         -3:  ' GET I_ADD[3] PICTURE '@!'
  @ row()+1,05 SAY '         -4:  ' GET I_ADD[4] PICTURE '@!'
  @ row()+1,05 SAY 'COUNTRY CODE: ' GET I_COU    PICTURE '@!' ;
               valid V_COU(I_COU)  WHEN U_LEVEL=0
  @ row()+1,05 SAY 'COSTACC CODE: ' GET I_ACC    PICTURE '@!' when U_LEVEL=0
  READ cycle
  set notify on

  RELEASE WINDOW W_COMGET
  RELEASE WINDOW W_FKEY41
  pop key
RETURN

*
* check if country code exists in CATEG.DBF
*
FUNCTION V_COU
  parameters I_COU
  private M_OK

  M_OK = .F.
  select 0
  use &ML_PATH.CATEG alias COUNTRY
  if used("COUNTRY")
    locate for CAT_TYPE="C" and CAT_CODE=I_COU
    if found()
      M_OK = .T.
    else
      =ERRMSG("Country code not found!")
    endif
    use in COUNTRY
  endif
RETURN M_OK

*-----------------------*
*  Update Company Data  *
*-----------------------*
PROCEDURE COM_MOVF
  private O_COU

  select COMPANY
  O_COU=COMPANY.COU_CODE
  replace COM_CODE with I_CODE, ;
          COM_NAME with I_NAME, ;
          COM_ADD1 with I_ADD[1], ;
          COM_ADD2 with I_ADD[2], ;
          COM_ADD3 with I_ADD[3], ;
          COM_ADD4 with I_ADD[4], ;
          COU_CODE with I_COU, ;
          CLI_TYPE with I_CLI, ;
          ACC_CODE with I_ACC, ;
          MODI_DATE with SYSDATE
  if O_COU # I_COU
    select 0
    use &ML_PATH.AUX_MAS alias ATTR
    if flock()
      scan for COM_CODE=I_CODE
        if AUX_TYPE="C"
          replace AUX_CODE with I_COU
        endif
      endscan
    endif
    use in ATTR
    select COMPANY
  endif
RETURN

*---------------------------------------------*
*  Company Data Movement  (DBF --> Variable)  *
*---------------------------------------------*
procedure COM_MOVM
  select COMPANY
  I_CODE   = COM_CODE
  I_NAME   = COM_NAME
  I_ADD[1] = COM_ADD1
  I_ADD[2] = COM_ADD2
  I_ADD[3] = COM_ADD3
  I_ADD[4] = COM_ADD4
  I_COU    = COU_CODE
  I_CLI    = CLI_TYPE
  I_ACC    = ACC_CODE
return

procedure COM_CLRM
  select COMPANY
  I_CODE   = space(len(COM_CODE))
  I_NAME   = space(len(COM_NAME))
  I_ADD[1] = space(len(COM_ADD1))
  I_ADD[2] = space(len(COM_ADD2))
  I_ADD[3] = space(len(COM_ADD3))
  I_ADD[4] = space(len(COM_ADD4))
  I_COU    = space(len(COU_CODE))
  I_CLI    = space(len(CLI_TYPE))
  I_ACC    = space(len(ACC_CODE))
RETURN

*---------------*
*  Add Company  *
*---------------*
PROCEDURE ADD_COM
  PRIVATE M_DONE

  push key clear
  if U_LEVEL=0
    DO COM_CLRM
    DO WHILE lastkey()#K_ESC
      DO COM_GETM with .T.
      IF LASTKEY()=K_C_W
        SELECT COMPANY
        IF FLOCK()
          SEEK I_CODE
          IF FOUND()
            =ERRMSG('DUPLICATED COMPANY CODE. PLS CHANGE IT!')
            UNLOCK IN COMPANY
          ELSE
            APPEND BLANK
            do COM_MOVF
            do ENTERLOG with SYSDATE, U_NAME, "A", alias(), ;
                             I_CODE+space(1)+I_NAME IN ML_LOG
          ENDIF
          unlock in COMPANY
        ELSE
          =ERRMSG("COMPANY FILE IN USE. TRY LATER!")
        ENDIF
      ENDIF
    ENDDO
  else
    =ERRMSG("YOU ARE NOT ALLOWED TO ADD COMPANY!")
  endif
  select COMPANY
  pop key
RETURN

*--------------------*
*  Edit Company - 1  *
*--------------------*
procedure EDIT_COM
  private M_DONE

  push key clear

  IF RLOCK()
    DO COM_MOVM
    DO WHILE LASTKEY()#K_ESC
      DO COM_GETM with .F.
      IF LASTKEY()=K_C_W
        SELECT 0           && UPDATE ATTRIBUTE RECORDS
        USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
        IF FLOCK()
          set order to tag COM_CODE
          * SET INDEX TO &ML_PATH.AUX_MAS3, &ML_PATH.AUX_MAS2, ;
          *             &ML_PATH.AUX_MAS1, &ML_PATH.AUX_MAS4
          SET FILTER TO AUX_TYPE = 'B'
          GO TOP
          SEEK COMPANY.COM_CODE
          IF FOUND()
            REPLACE COU_CODE WITH COMPANY.COU_CODE ;
                    WHILE COM_CODE=COMPANY.COM_CODE
          ENDIF
          USE
          SELECT COMPANY
          DO COM_MOVF
          DO ENTERLOG with SYSDATE, U_NAME, "E", alias(), ;
                           COM_NAME IN ML_LOG
          EXIT
        ELSE
          SELECT AUX_MAS
          USE
          DO ERRMSG WITH 'ATTRIBUTE DATABASE IN USE. TRY AGAIN !!'
        ENDIF
      ENDIF
    ENDDO
    UNLOCK IN COMPANY
  ELSE
    DO ERRMSG WITH 'RECORD IN USE. TRY LATER !!'
  ENDIF

  SELECT COMPANY
  pop key
RETURN

*--------------------*
*  Edit Company - 2  *
*--------------------*
PROCEDURE COM_ATTR
  private M_TEMP, M_ATTR, M_CURRENT, M_AGAIN
  declare M_ATTR[2,2]

  push key clear
  IF U_LEVEL = 0
    M_ATTR[1,1]="B"     && business nature

    M_ATTR[1,2]="Business Nature"

    M_CURRENT=1       && current window of attribute class


    define window W_MSG from 05,20 TO 07,60 shadow color N/W,N/W,N/W
    define window W_BRATTR from 04,40 TO 22,79 shadow ;
                  color W/N,N/W,N/W,N/W,W/N,N/W,N/W,N/N,N/W,W/N,N/W
    define window W_FKEY14 FROM 24,00 TO 24,79 none noshadow color N/W,N/W,N/W

    =SHOWFKEY(01,'ESC','DONE','W_FKEY14')
    =SHOWFKEY(25,'','PREVIOUS','W_FKEY14')
    =SHOWFKEY(50,'','NEXT','W_FKEY14')

    if rlock()
      select 0
      use &ML_PATH.CATEG alias CATEG
      if flock()
        set order to tag CAT_CODE

        SELECT 0
        USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
        IF FLOCK()
          activate window W_MSG
          ? 'SEARCHING ATTRIBUTES ...'

          * companies can have business natures ONLY
          SELECT CATEG
          REPLACE ALL FLAG WITH SPACE(1)    && CLEAR FLAGS FIRST

          * for showing selected categ attributes
          SELECT AUX_MAS
          set order to tag COM_CODE
          SCAN FOR COM_CODE = COMPANY.COM_CODE
            SELECT CATEG
            SEEK AUX_MAS.AUX_CODE
            IF FOUND()
              REPLACE FLAG WITH '*'
            ENDIF
          ENDSCAN

          deactivate window W_MSG

          * user add/delete attribute
          push key clear
          on key label leftarrow  DO PREV_WIN
          on key label rightarrow DO NEXT_WIN
          on key label esc        DO DONE

          define window W_CLA from 05,00 to 07,35 shadow color n/w,n/w,n/w
          activate window W_CLA
          ? ALLTRIM(COMPANY.COM_NAME)

          SELECT CATEG
          M_AGAIN=.t.
          do while M_AGAIN
            browse fields FLAG:V=V_ATTR():H=SPACE(2), ;
                          CAT_CODE:H="CODE":R, ;
                          CAT_DESC:H="DESCRIPTION":R ;
                   for    CAT_TYPE = M_ATTR[M_CURRENT,1] ;
                   freeze FLAG ;
                   nodelete noappend norgrid window W_BRATTR ;
                   title str(M_CURRENT,2,0)+space(1)+M_ATTR[M_CURRENT,2]
          enddo

          release window W_CLA
          pop key

          IF "Y"=ASKYN("SAVE ATTRIBUTE CHANGES")
            ACTIVATE WINDOW W_MSG
            ? 'ASSIGNING NEW ATTRIBUTES ... '

            * set attributes for COMPANY
            select AUX_MAS
            set order to tag COM_AUX
            select CATEG
            SCAN ALL FOR .NOT. EMPTY(CATEG.FLAG)
              * check if the category has already been acquired
              SELECT AUX_MAS
              SEEK COMPANY.COM_CODE+CATEG.CAT_CODE
              DO CASE
                CASE CATEG.FLAG = '+'   && add an attribute
                  IF .not. found()
                    SELECT AUX_MAS
                    APPEND BLANK
                    REPLACE COM_CODE WITH COMPANY.COM_CODE, ;
                            MAS_CODE with 0, ;
                            COU_CODE WITH COMPANY.COU_CODE, ;
                            AUX_CODE WITH CATEG.CAT_CODE, ;
                            AUX_TYPE WITH CATEG.CAT_TYPE
                    DO ENTERLOG with SYSDATE, U_NAME, "A", "COMPANY", ;
                                     AUX_CODE+space(1)+COMPANY.COM_NAME IN ML_LOG
                  ENDIF
                CASE CATEG.FLAG = '-'    && remove an attribute
                  IF found()
                    SELECT AUX_MAS
                    M_TEMP=AUX_CODE
                    DELETE
                    DO ENTERLOG with SYSDATE, U_NAME, "D", "COMPANY", ;
                                     M_TEMP+space(1)+COMPANY.COM_NAME IN ML_LOG
                  ENDIF
              ENDCASE
              REPLACE CATEG.FLAG WITH SPACE(1)
            ENDSCAN
          ENDIF
        ELSE
          DO ERRMSG WITH 'RELATIONS DATABASE IN USE. TRY LATER !!'
        ENDIF
      ELSE
        DO ERRMSG WITH 'ATTRIBUTES DATABASE IN USE. TRY LATER !!'
      ENDIF
    ELSE
      DO ERRMSG WITH 'COMPANY RECORD IN USE. TRY AGAIN LATER !!'
    ENDIF

    IF USED('CATEG')
      use in CATEG
    ENDIF
    IF USED('AUX_MAS')
      use in AUX_MAS
    ENDIF

    RELEASE WINDOW W_BRATTR
    RELEASE WINDOW W_FKEY14
    RELEASE WINDOW W_MSG
    SELECT COMPANY
  ELSE
    =ERRMSG("YOU ARE NOT ALLOWED TO CHANGE COMPANY ATTRIBUTES!")
  ENDIF
  pop key
RETURN

procedure NEXT_WIN
  push key clear
  M_CURRENT = M_CURRENT+1
  if M_CURRENT > 1
    M_CURRENT = 1
  endif
  keyboard chr(K_C_W)
  pop key
return

procedure PREV_WIN
  push key clear
  M_CURRENT = M_CURRENT-1
  if M_CURRENT < 1
    M_CURRENT = 1
  endif
  keyboard chr(K_C_W)
  pop key
return

procedure DONE
  on key label esc
  keyboard chr(K_C_W)
  M_AGAIN = .f.
return

*------------------*
*  Delete Company  *
*------------------*
PROCEDURE DEL_COM
  push key clear
  IF U_LEVEL = 0
    DEFINE WINDOW W_MSG FROM 10,05 TO 12,50 SHADOW

    IF RLOCK()       && LOCK COMPANY RECORD FIRST
      IF 'Y'=ASKYN('DELETE THIS COMPANY')
        SELECT 0
        USE &ML_PATH.CLIENT ALIAS CLIENT
        IF FLOCK()
          * FIRST INDEX IS COMPANY CODE
          set order to tag COM_CODE
          * SET INDEX TO &ML_PATH.CLIENT3, &ML_PATH.CLIENT1, &ML_PATH.CLIENT2
          SET ORDER TO 0

          SELECT 0
          USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
          IF FLOCK()   && LOCK AUX_MAS.DBF TO PREVENT FURTHER CHANGES
            * SET INDEX TO &ML_PATH.AUX_MAS3, &ML_PATH.AUX_MAS2, ;
            *             &ML_PATH.AUX_MAS1, &ML_PATH.AUX_MAS4
            * SET ORDER TO 0

            * REMOVE COMPANY CODES IN CLIENT DATBASE
            ACTIVATE WINDOW W_MSG

            ? 'REMOVING RELATED CLIENTS AND THEIR ATTRIBUTES ....'
            SELECT CLIENT
            SET FILTER TO COM_CODE=COMPANY.COM_CODE
            SCAN
              SELECT AUX_MAS
              SET FILTER TO MAS_CODE=CLIENT.MAS_CODE
              DELETE ALL
              SET FILTER TO
              SELECT CLIENT
              REPLACE COM_CODE WITH SPACE(1), MODI_DATE WITH SYSDATE
            ENDSCAN
            SET FILTER TO

            * DELETE COMPANY'S ATTRIBUTE RECORDS
            ? 'REMOVING COMPANY ATTRIBUTES ....'
            SELECT AUX_MAS
            DELETE ALL FOR COM_CODE=COMPANY.COM_CODE

            SELECT COMPANY
            I_CODE = COMPANY.COM_CODE
            I_NAME = COMPANY.COM_NAME
            DELETE
            DO ENTERLOG with SYSDATE, U_NAME, "D", alias(), ;
                             I_CODE+space(1)+I_NAME IN ML_LOG
          ELSE
            =ERRMSG('ATTRIBUTE DATABASE IN USE. TRY AGAIN LATER !!')
          ENDIF
        ELSE
          =ERRMSG('CLIENT DATABASE IN USE. TRY AGAIN LATER !!')
        ENDIF
      ELSE
        =ERRMSG('RECORD IN USE. TRY LATER!!')
      ENDIF
      UNLOCK IN COMPANY
    ELSE
      =ERRMSG('COMPANY RECORD IN USE. TRY AGAIN LATER !!')
    ENDIF

    IF USED('AUX_MAS')
      USE IN AUX_MAS
    ENDIF

    IF USED('CLIENT')
      USE IN CLIENT
    ENDIF

    RELEASE WINDOW W_MSG
  ELSE
    =ERRMSG("YOU ARE NOT ALLOWED TO DELETE COMPANY!")
  ENDIF
  pop key
RETURN

*------------------------------*
*  Partial A Company USING PARTIAL KEY
*------------------------------*
PROCEDURE SRCH_COM
  PRIVATE M_RECNO

  push key clear

  DEFINE WINDOW W_SRCH FROM 08,20 TO 11,78 ;
                SHADOW color g/n,,g+,g+ title " SEARCH A COMPANY BY "

  DO COM_CLRM

  ACTIVATE WINDOW W_SRCH
  @ 00,05 SAY 'COMPANY CODE:' GET I_CODE PICT '@!'
  @ 01,05 SAY 'NAME:' GET I_NAME PICT '@!'
  READ

  IF LASTKEY() = K_ESC
    M_RECNO=RECNO()
    SET FILTER TO
    GO TOP
    if M_RECNO#0
      goto M_RECNO
    endif
  ELSE
    DO CASE
      CASE .NOT. EMPTY(I_CODE)
        set order to COM_CODE
        IF .NOT. EOF()
          M_RECNO=RECNO()
          SET EXACT OFF
          SEEK ALLTRIM(I_CODE)
          SET EXACT ON
          IF .NOT. FOUND()
            DO ERRMSG WITH 'COMPANY CODE NOT FOUND !!'
            GOTO M_RECNO
          ENDIF
        ELSE
          DO ERRMSG WITH 'NO RECORD TO SEARCH. PLS CLEAR FILTER !!'
        ENDIF
      OTHERWISE
        set order to COM_NAME
        SET FILTER TO ALLTRIM(I_NAME)$COM_NAME
        GO TOP
    ENDCASE
  ENDIF

  RELEASE WINDOW W_SRCH
  pop key
RETURN
