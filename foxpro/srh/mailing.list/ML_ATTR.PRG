*------------------------------------------------------------------------*
*  Attributes maintenance
*---------------------------------------------------------
*  maintain one category of attributes governed by input parameters M_TYPE
*------------------------------------------------------------------------*
  parameters M_TYPE
  private W_HEAD

  IF U_LEVEL=0
    DEFINE WINDOW W_FKEY7 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W
    DEFINE WINDOW W_BRATTR  FROM 04,25 TO 22,75 SHADOW ;
           COLOR W/N,N/W,N/W,N/W,W/N,N/W,N/W,N/N,N/W,W/N,N/W
    do case
      case M_TYPE="B"
        W_HEAD=SHOWHEAD('BUSINESS NATURE CODES MAINTNENACE')
      case M_TYPE="C"
        W_HEAD=SHOWHEAD('COUNTRY CODE MAINTNENACE')
      case M_TYPE="D"
        W_HEAD=SHOWHEAD('DIRECTOR CODES MAINTNENACE')
      case M_TYPE="P"
        W_HEAD=SHOWHEAD('PUBLICATION CODES MAINTNENACE')
      CASE M_TYPE="1"
        W_HEAD=SHOWHEAD('KEY CLIENTS CODES MAINTENANCE')
      CASE M_TYPE="2"
        W_HEAD=SHOWHEAD('SRG NEWS MAINTENANCE')
      CASE M_TYPE="T"
        W_HEAD=SHOWHEAD('CIRCULATION CODES MAINTENANCE')
      CASE M_TYPE="O"
        W_HEAD=SHOWHEAD('POSITION CODES MAINTENANCE')
    endcase

    =SHOWFKEY(01,'F2','SEARCH','W_FKEY7')

    SELECT 0
    USE &ML_PATH.CATEG ALIAS CATEG
    IF USED('CATEG')
      set order to tag CAT_CODE

      push key clear
      ON KEY LABEL INS   DO ADD_ATTR
      ON KEY LABEL DEL   DO DEL_ATTR
      ON KEY LABEL ENTER DO EDIT_ATTR
      ON KEY LABEL F2    DO SRCH_ATTR

      BROWSE FIELDS CAT_CODE:H="CODE", ;
                    CAT_DESC:H="DESCRIPTION" ;
             FOR CAT_TYPE=M_TYPE ;
             NOAPPEND NODELETE NOMODIFY ;
             WINDOW W_BRATTR TITLE space(1)
      pop key
    ELSE
      =ERRMSG('Attributes File in use. Try later!')
    ENDIF

    CLOSE DATABASES
    RELEASE WINDOW (W_HEAD)
    RELEASE WINDOW W_FKEY7
    RELEASE WINDOW W_BRATTR
  ELSE
    =ERRMSG("YOU ARE NOT ALLOWED TO CHANGE ATTRIBUTES FILE!")
  ENDIF
RETURN

PROCEDURE ATTR_CLRM
  I_CODE=space(len(CATEG.CAT_CODE))
  I_LN  =SPACE(LEN(CATEG.CAT_DESC))
RETURN

PROCEDURE ATTR_GETM
  PARAMETER M_EDITKEY

  push key clear
  do HOOKF10

  DEFINE WINDOW W_ATTRGET FROM 05,05 TO 10,75 SHADOW
  DEFINE WINDOW W_FKEY43 FROM 24,00 TO 24,79 COLOR N/W,N/W,N/W NONE NOSHADOW
  DO SHOWFKEY WITH 01,'ESC','CANCEL','W_FKEY43'
  DO SHOWFKEY WITH 65,'F10','SAVE','W_FKEY43'
  ACTIVATE WINDOW W_ATTRGET

  @ 01,05 SAY padr('Code:',20)
  @ 02,05 SAY padr('Description :',20)

  @ 01,20 GET I_CODE PICT '@!' WHEN M_EDITKEY
  @ 02,20 GET I_LN   PICT '@!'
  READ cycle

  RELEASE WINDOW W_FKEY43
  RELEASE WINDOW W_ATTRGET
  pop key
RETURN

PROCEDURE ATTR_MOVM
  I_CODE=CATEG.CAT_CODE
  I_LN  =CATEG.CAT_DESC
RETURN

PROCEDURE ATTR_MOVF
  SELECT CATEG
  REPLACE CAT_CODE WITH I_CODE, CAT_DESC WITH I_LN, ;
          CAT_TYPE WITH M_TYPE
RETURN

PROCEDURE ADD_ATTR
  PRIVATE I_CODE, I_LN

  I_CODE = SPACE(1)
  I_LN   = SPACE(1)

  push key clear

  DO ATTR_CLRM
  DO ATTR_GETM WITH .T.
  IF LASTKEY()#K_ESC
    SELECT CATEG
    IF FLOCK()
      SEEK I_CODE
      IF FOUND()
        =ERRMSG('CODE ALREADY EXISTS !!')
      ELSE
        APPEND BLANK
        DO ATTR_MOVF
      ENDIF
      UNLOCK IN CATEG
    ELSE
      =ERRMSG('DATABASE IN USE. TRY SAVE AGAIN LATER !!')
    ENDIF
  ENDIF

  pop key
RETURN

PROCEDURE EDIT_ATTR
  PRIVATE I_CODE, I_LN
  
  I_CODE=SPACE(1)
  I_LN  =SPACE(1)
  
  push key clear

  IF RLOCK()
    DO ATTR_MOVM
    DO ATTR_GETM WITH .F.
    IF LASTKEY()=K_C_W
      DO ATTR_MOVF
    ENDIF
    UNLOCK IN CATEG
  ELSE
    =ERRMSG('RECORD IN USE. TRY AGAIN LATER !!')
  ENDIF

  pop key
RETURN

PROCEDURE DEL_ATTR
  push key clear

  IF RLOCK()
    IF 'Y'=ASKYN('DELETE '+alltrim(CATEG.CAT_CODE))
      SELECT 0
      USE &ML_PATH.AUX_MAS ALIAS AUX_MAS EXCLUSIVE
      if used("AUX_MAS")
        set order to tag AUX_CODE

        SELECT CATEG
        DELETE

        SELECT AUX_MAS
        delete for AUX_CODE=CATEG.CAT_CODE and AUX_TYPE=CATEG.CAT_TYPE
        USE
      else
        =ERRMSG("UNABLE TO OPEN AUX_MAS.DBF. TRY LATER!")
      endif
    ENDIF
    UNLOCK IN CATEG
  ELSE
    =ERRMSG('RECORD IN USE. PLEASE TRY LATER !!')
  ENDIF

  pop key
RETURN

FUNCTION SRCH_ATTR
  PRIVATE I_CODE, I_LN, M_RECNO

  push key clear

  M_RECNO= RECNO()
  I_CODE = SPACE(1)
  I_LN   = SPACE(1)

  DO ATTR_CLRM
  DO ATTR_GETM WITH .T.
  IF LASTKEY() = K_ESC
    SET FILTER TO CAT_TYPE = M_TYPE
    GO TOP
    if M_RECNO#0
      goto M_RECNO
    endif
  ELSE
    IF .NOT. EMPTY(I_LN)
      SET FILTER TO CAT_TYPE = M_TYPE and ALLTRIM(I_LN) $ CAT_DESC
      GO TOP
    ELSE
      SET EXACT OFF
      SEEK ALLTRIM(I_CODE)
      SET EXACT ON
    ENDIF
	ENDIF

  pop key
RETURN
