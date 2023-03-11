  * ---------------------------------------------------
  *  Print reports
  * ---------------------------------------------------
  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_RPT_POP FROM 08,15 SHADOW
  DEFINE BAR 1 OF W_RPT_POP PROMPT 'CLIENT LIST'
  DEFINE BAR 2 OF W_RPT_POP PROMPT 'COMPANY LIST'
  DEFINE BAR 3 OF W_RPT_POP PROMPT 'ATTRBUTES LIST'
  ON SELECTION POPUP W_RPT_POP DO PU_RPT WITH BAR()

  ACTIVATE POPUP W_RPT_POP

  RELEASE W_RPT_POP
RETURN

PROCEDURE PU_RPT
  PARAMETER M_BAR

  DO CASE
    CASE M_BAR = 1
      DO RPT_CLI
    CASE M_BAR = 2
      DO RPT_COM
    CASE M_BAR = 3
      DO RPT_CATEG
  ENDCASE
RETURN

*------------------------*
*  Report Client Master  *
*------------------------*
*  RPT_GEN.
PROCEDURE RPT_CLI
  private W_HEAD

  DEFINE WINDOW W_FKEY20 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W
 
  W_HEAD=SHOWHEAD('FULL REPORT -- CLIENT MASTER FILE')

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_PTYPE FROM 10,20 SHADOW
  DEFINE BAR 1 OF W_PTYPE PROMPT 'CLIENT DETAIL '
  DEFINE BAR 2 OF W_PTYPE PROMPT 'CLIENT DETAIL W/ COMPANY ADDRESS'
  DEFINE BAR 3 OF W_PTYPE PROMPT 'ATTRIBUTES FOR CLIENTS'
  ON SELECTION POPUP W_PTYPE DO SETPTYPE WITH BAR()

  ACTIVATE POPUP W_PTYPE

  RELEASE POPUP W_PTYPE
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_FKEY20
RETURN

PROCEDURE SETPTYPE
  * client reports
  PARAMETERS M_PRNTYPE

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_SELCRI FROM 13,40 SHADOW
  DEFINE BAR 1 OF W_SELCRI PROMPT 'BY COMPANY CODE'
  DEFINE BAR 2 OF W_SELCRI PROMPT 'BY CLIENT NAME'
  ON SELECTION POPUP W_SELCRI DO PRINTRPT WITH M_PRNTYPE, BAR()

  ACTIVATE POPUP W_SELCRI

  RELEASE POPUP W_SELCRI
RETURN

PROCEDURE PRINTRPT
  PARAMETERS PRN_TYPE, M_ORDER
  *
  * PRN_TYPE is the type of report
  * M_ORDER  is the sorting order
  *
  PRIVATE I_FRDATE, I_TODATE, I_FR, I_TO, TMP1, TMP2, I_FILTER, M_REPORT

  SELECT 0
  USE &ML_PATH.COMPANY ALIAS COMPANY
  IF USED('COMPANY')
    set order to tag COM_CODE
  ELSE
    DO ERRMSG WITH 'COMPANY DATABASE IN USE'
    CLOSE DATABASES
    RETURN
  ENDIF

  SELECT 0
  USE &ML_PATH.CATEG ALIAS CATEG
  IF USED('CATEG')
    set order to tag CAT_CODE
  ELSE
    DO ERRMSG WITH 'ATTRIBUTES DATABASE IN USE'
    CLOSE DATABASES
    RETURN
  ENDIF

  SELECT 0
  USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
  IF USED('AUX_MAS')
    set order to tag MAS_CODE
    SET FILTER TO AUX_TYPE <> "B"
    GO TOP
  ELSE
    DO ERRMSG WITH 'RELATIONS DATABASE IN USE'
    CLOSE DATABASES
    RETURN
  ENDIF

  SELECT 0
  USE &ML_PATH.CLIENT ALIAS CLIENT
  IF USED('CLIENT')
    set order to tag NAME
  ELSE
    DO ERRMSG WITH 'CLIENT DATABASE IN USE'
    CLOSE DATABASES
    RETURN
  ENDIF

  DEFINE WINDOW W_RANGE FROM 10,05 TO 20,75 SHADOW COLOR W+/N,W/N,W/N PANEL
  DEFINE WINDOW W_MSG   FROM 15,05 TO 17,40 ;
         COLOR N/W,N/W,N/W,N/W,N/W,N/W SHADOW

  **  Init. input value  **
  I_FRDATE=CTOD('')       && STARTING DATE
  I_TODATE=CTOD('')       && ENDING DATE

  ** obtain range of data to report
  ACTIVATE WINDOW W_RANGE
  DO CASE
    CASE M_ORDER = 1 and PRN_TYPE <> 3
      I_FR = SPACE(LEN(CLIENT.COM_CODE))
      I_TO = SPACE(LEN(CLIENT.COM_CODE))
      @ 01,05 SAY 'COMPANY CODE' color g+/n
      @ 03,05 SAY 'From:' GET I_FR PICTURE '@!'
      @ 05,05 SAY 'To  :' GET I_TO PICTURE '@!'

      @ 01,25 SAY 'MODI. DATE:' color g+/n
      @ 03,25 SAY 'From:' GET I_FRDATE PICTURE '@D'
      @ 05,25 SAY 'To  :' GET I_TODATE PICTURE '@D'
    CASE M_ORDER = 2            && client name
      I_FR = SPACE(LEN(CLIENT.L_NAME))
      I_TO = SPACE(LEN(CLIENT.L_NAME))
      @ 01,05 SAY "CLIENT'S LAST NAME" color g+/n
      @ 03,05 SAY 'From:' GET I_FR PICTURE '@!'
      @ 05,05 SAY 'To  :' GET I_TO PICTURE '@!'

      @ 01,35 SAY 'MODIFICATION DATE' color g+/n
      @ 03,35 SAY 'From:' GET I_FRDATE PICTURE '@D'
      @ 05,35 SAY 'To  :' GET I_TODATE PICTURE '@D'
    CASE M_ORDER = 3            && position code
      I_FR = space(1)
      I_TO = space(1)
      @ 01,05 SAY 'CLIENT POSITION CODE' color g+/n
      @ 03,05 SAY 'From:' GET I_FR PICTURE '9'
      @ 05,05 SAY 'To  :' GET I_TO PICTURE '9'
    CASE PRN_TYPE = 3
      I_FR = SPACE(LEN(CLIENT.COM_CODE))
      I_TO = SPACE(LEN(CLIENT.COM_CODE))
      @ 01,05 SAY 'COMPANY CODE' color g+/n
      @ 03,05 SAY 'From:' GET I_FR PICTURE '@!'
      @ 05,05 SAY 'To  :' GET I_TO PICTURE '@!'
  ENDCASE
  READ

  IF LASTKEY()#K_ESC
    * validate range of codes to report
    IF I_FR > I_TO and (not EMPTY(I_TO))
      TMP2 = I_FR
      I_FR = I_TO
      I_TO = TMP2
    ENDIF

    * validate range of date to report
    IF PRN_TYPE <> 3 and I_FRDATE > I_TODATE and (not EMPTY(I_TODATE))
      TMP2 = I_FRDATE
      I_FRDATE = I_TODATE
      I_TODATE = TMP2
    ENDIF

    ** BUILD FILTER STRING  **
    ** first set up range of company/client codes be included in report
    I_FILTER = ''

    do case
      case M_ORDER = 1                  && By company
        IF not EMPTY(I_FR)
          I_FILTER = ' COM_CODE >= I_FR '
          IF not EMPTY(I_TO)
            I_FILTER = I_FILTER + 'and COM_CODE <= I_TO'
          ENDIF
        ELSE
          IF not EMPTY(I_TO)
            I_FILTER = ' COM_CODE <= I_TO'
          ENDIF
        ENDIF
      case M_ORDER = 2                  && By client name
        IF not EMPTY(I_FR)
          I_FILTER = ' L_NAME >= I_FR '
          IF not EMPTY(I_TO)
            I_FILTER = I_FILTER + 'and L_NAME <= I_TO'
          ENDIF
        ELSE
          IF not EMPTY(I_TO)
            I_FILTER = ' L_NAME <= I_TO'
          ENDIF
        ENDIF
      case M_ORDER = 3
        if not empty(I_FR)
          I_FILTER = ' POS_CODE >= val(I_FR) '
          if not empty(I_TO)
            I_FILTER = I_FILTER + ' and POS_CODE <= val(I_TO) '
          endif
        else
          if not empty(I_TO)
            I_FILTER = ' POS_CODE <= val(I_TO)'
          endif
        endif
    endcase

    ** data must be within given modification dates
    IF PRN_TYPE <> 3
      IF not EMPTY(I_FRDATE)
        IF EMPTY(I_FILTER)
          I_FILTER = ' MODI_DATE >= I_FRDATE '
        ELSE
          I_FILTER = I_FILTER + 'and MODI_DATE >= I_FRDATE '
        ENDIF
      ELSE
        IF not EMPTY(I_TODATE)
          IF EMPTY(I_FILTER)
            I_FILTER = ' MODI_DATE <= I_TODATE'
          ELSE
            I_FILTER = I_FILTER + 'and MODI_DATE <= I_TODATE'
          ENDIF
        ENDIF
      ENDIF
    ENDIF

    **  SELECT INDEX FILE AND ESTABLISH RELATIONS BETWEEN DATABASES **
    DO CASE
      CASE PRN_TYPE = 3
        select CLIENT
        SET ORDER TO tag MAS_CODE     && CLIENT1 - MAS_CODE
        SELECT AUX_MAS
        SET ORDER TO tag COM_CODE
        SET RELATION TO COM_CODE INTO COMPANY
        SET RELATION TO MAS_CODE INTO CLIENT ADDITIVE
      CASE M_ORDER = 1 and PRN_TYPE <> 3
        SELECT CLIENT
        SET ORDER TO tag COM_CODE     && CLIENT3 - COM_CODE
        SET RELATION TO COM_CODE INTO COMPANY
      CASE M_ORDER = 2
        SELECT CLIENT
        SET ORDER TO tag NAME     && CLIENT2 - L_NAME+F_NAME
        SET RELATION TO COM_CODE INTO COMPANY
      CASE M_ORDER = 3
        select CLIENT
        set order to tag COM_CODE
        set relation to COM_CODE into COMPANY
    ENDCASE

    IF 'Y'=ASKYN('PRINT REPORT TO PRINTER')
      ACTIVATE WINDOW W_MSG
      ? 'PRINTING REPORT ....'

      SET CONSOLE OFF
      DO CASE
        CASE PRN_TYPE = 1        && CLIENT DETAIL 1
          M_REPORT = 'COMPANY3'
          SELECT CLIENT
        CASE PRN_TYPE = 2        && CLIENT DETAIL 2
          M_REPORT='CLIENT1'
          SELECT CLIENT
        CASE PRN_TYPE = 3        && CLIENT ATTRIBUTES
          M_REPORT='CLIENT2'
          SELECT AUX_MAS
        OTHERWISE
          M_REPORT = space(1)
      ENDCASE

      IF EMPTY(I_FILTER)
        REPORT FORM &M_REPORT ALL FOR left(COM_CODE,1) <= 'E' to printer
        REPORT FORM &M_REPORT ALL ;
               FOR left(COM_CODE,1) > 'E' and left(COM_CODE,1) <= 'J' ;
               to printer
        REPORT FORM &M_REPORT ALL ;
               FOR left(COM_CODE,1) > 'J' and left(COM_CODE,1) <= 'O' ;
               to printer
        REPORT FORM &M_REPORT ALL ;
               FOR left(COM_CODE,1) > 'O' and left(COM_CODE,1) <= 'T' ;
               to printer
        REPORT FORM &M_REPORT ALL FOR left(COM_CODE,1) > 'T' to printer
      ELSE
        REPORT FORM &M_REPORT ;
               FOR &I_FILTER and left(COM_CODE,1) <= 'E' to printer
        REPORT FORM &M_REPORT ;
               FOR &I_FILTER and left(COM_CODE,1) > 'E' and ;
                   left(COM_CODE,1) <= 'J' ;
               to printer
        REPORT FORM &M_REPORT ;
               FOR &I_FILTER and left(COM_CODE,1) > 'J' and ;
                   left(COM_CODE,1) <= 'O' ;
               to printer
        REPORT FORM &M_REPORT ;
               FOR &I_FILTER and left(COM_CODE,1) > 'O' and ;
                   left(COM_CODE,1) <= 'T' ;
               to printer
        REPORT FORM &M_REPORT ;
               FOR &I_FILTER and left(COM_CODE,1) > 'T' to printer
      ENDIF
      SET CONSOLE ON
    ENDIF
  ENDIF

  RELEASE WINDOW W_RANGE
  RELEASE WINDOW W_MSG
  CLOSE DATABASES
RETURN


*---------------------------*
*  Report COMPANY DETAIL
*---------------------------*
*  RPT_GEN.
PROCEDURE RPT_COM
  private W_HEAD

  DEFINE WINDOW W_FKEY21 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W

  W_HEAD=SHOWHEAD('FULL REPORTS -- COMPANY MASTER FILE')

  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_COMRPT FROM 10,10 SHADOW
  DEFINE BAR 1 OF W_COMRPT PROMPT 'COMPANY DETAIL'
  DEFINE BAR 2 OF W_COMRPT PROMPT 'COMPANY WITH BUSINESS NATURE'
  DEFINE BAR 3 OF W_COMRPT PROMPT 'COMPANY WITH CLIENTS'
  DEFINE BAR 4 OF W_COMRPT PROMPT 'COMPANY WITHOUT BUSINESS NATURE'
  ON SELECTION POPUP W_COMRPT DO SETCTYPE WITH BAR()

  DO WHILE LASTKEY()#K_ESC
    ACTIVATE POPUP W_COMRPT
  ENDDO

  RELEASE POPUP W_COMRPT
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_FKEY21
  CLOSE DATABASES
RETURN

PROCEDURE SETCTYPE
  PARAMETER M_BAR

  DO CASE
    CASE M_BAR = 1      && company master list
      DO COM_DET
    CASE M_BAR = 2      && company with business nature
      DO COM_NAT
    CASE M_BAR = 3      && company with clients
      DO COM_CLI
    CASE M_BAR = 4      && company without business natures
      DO COM_NNAT
  ENDCASE
RETURN

PROCEDURE COM_NNAT
  PRIVATE M_TEMP

  DEFINE WINDOW W_MSG FROM 15,05 TO 17,40 ;
                      COLOR N/W,N/W,N/W,N/W,N/W,N/W SHADOW

  SELECT 0
  USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
  IF used('AUX_MAS') and FLOCK()
    set order to tag COM_CODE
    SET FILTER TO AUX_TYPE = 'B'
    GO TOP

    SELECT 0
    USE &ML_PATH.COMPANY ALIAS COMPANY
    IF FLOCK()
      IF 'Y'=ASKYN('PRINT REPORT NOW')
        ACTIVATE WINDOW W_MSG
        ? 'PRINTING ...'

        SET CONSOLE OFF
        SET PRINTER ON
        
        ?
        ? 'COMPANIES WITHOUT BUSINESS NATURE ('
        ?? SYSDATE
        ?? ')'
        ?

        SELECT COMPANY
        SCAN
          SELECT AUX_MAS
          SEEK COMPANY.COM_CODE
          IF not FOUND()
            ? COMPANY.COM_CODE
          ENDIF
        ENDSCAN
        ?
        
        SET PRINTER OFF
        SET CONSOLE ON
      ENDIF
    ELSE
      DO ERRMSG WITH 'COMPANY.DBF IN USE. TRY LATER !'
    ENDIF
  ELSE
    DO ERRMSG WITH 'AUX_MAS IN USE. TRY LATER !'
  ENDIF

  CLOSE DATABASES
  RELEASE WINDOW W_MSG
RETURN

*-------------------------*
*  Report Company Detail  *
*-------------------------*
*  RPT_GEN.
PROCEDURE COM_DET
  PRIVATE I_FR, I_TO, I_FRTYPE, I_TOTYPE, I_FILTER, TMP1, W_HEAD

  DEFINE WINDOW W_RANGE FROM 10,20 TO 20,60 SHADOW COLOR W+/N,W/N,W/N PANEL
  DEFINE WINDOW W_MSG FROM 15,05 TO 17,40 COLOR N/W,N/W,N/W,W/N,N/W,N/W,N/W ;
  SHADOW

  W_HEAD=SHOWHEAD('PRINT COMPANY DETAIL LISTING')

  SELECT 0
  USE &ML_PATH.COMPANY ALIAS COMPANY
  set order to tag COM_CODE
*  SET INDEX TO &ML_PATH.COMPANY1

  I_FR = SPACE(LEN(COMPANY.COM_CODE))
  I_TO = SPACE(LEN(COMPANY.COM_CODE))
  I_FRTYPE = space(len(COMPANY.CLI_TYPE))
  I_TOTYPE = space(len(COMPANY.CLI_TYPE))

  ACTIVATE WINDOW W_RANGE
  @ 01,05 SAY 'COMPANY CODE' color G+/N
  @ 03,05 SAY 'From:' GET I_FR PICT '@!'
  @ 05,05 SAY 'To  :' GET I_TO PICT '@!'

  @ 01,25 SAY 'COMPANY TYPE' color G+/N
  @ 03,25 SAY 'From:' GET I_FRTYPE PICT '@!'
  @ 05,25 SAY 'To  :' GET I_TOTYPE PICT '@!'
  READ
	
  IF LASTKEY()#K_ESC
    * validate from-value and to-value
    IF I_FR > I_TO and (not EMPTY(I_TO))
      TMP1 = I_FR
      I_FR = I_TO
      I_TO = TMP1
    ENDIF

    **  Filter String  **
    I_FILTER=space(1)
    IF not EMPTY(I_FR)
      I_FILTER = ' COM_CODE >= I_FR '
    ENDIF

    IF not EMPTY(I_TO)
      if not empty(I_FILTER)
        I_FILTER = I_FILTER + 'and COM_CODE <= I_TO'
      else
        I_FILTER = ' COM_CODE <= I_TO'
      endif
    ENDIF

    if not empty(I_FRTYPE)
      if not empty(I_FILTER)
        I_FILTER = ' and CLI_TYPE >= I_FRTYPE '
      else
        I_FILTER = ' CLI_TYPE >= I_FRTYPE '
      endif
    endif

    if not empty(I_TOTYPE)
      if not empty(I_FILTER)
        I_FILTER = ' and CLI_TYPE <= I_TOTYPE '
      else
        I_FILTER = ' CLI_TYPE <= I_TOTYPE '
      endif
    endif

    IF 'Y'=ASKYN('PRINT REPORT NOW')
      ACTIVATE WINDOW W_MSG
      ? 'PRINTING ...'

      SET CONSOLE OFF
      IF empty(I_FR) and empty(I_TO) and empty(I_FRTYPE) and ;
         empty(I_TOTYPE)
        REPORT FORM COMPANY1 ALL to printer
      ELSE
        REPORT FORM COMPANY1 FOR &I_FILTER to printer
      ENDIF
      SET CONSOLE ON
    ENDIF
  ENDIF

  RELEASE WINDOW W_RANGE
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_MSG
  CLOSE DATABASES
RETURN

*-------------------------------------*
*  Report Company -- Business Nature  *
*-------------------------------------*
PROCEDURE COM_NAT
  PRIVATE I_FR, I_TO, I_FRTYPE, I_TOTYPE, I_FILTER, TMP1, W_HEAD

  DEFINE WINDOW W_RANGE FROM 10,20 TO 20,60 SHADOW COLOR W+/N,W/N,W/N PANEL
  DEFINE WINDOW W_MSG FROM 15,05 TO 17,40 COLOR N/W,N/W,N/W,N/W,N/W,N/W ;
         SHADOW

  W_HEAD=SHOWHEAD('COMPANY LISTING WITH NATURE')

  SELECT 0
  USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
  set order to tag COM_CODE
  SET FILTER TO AUX_TYPE = 'B'
  GO TOP

  SELECT 0
  USE &ML_PATH.COMPANY ALIAS COMPANY
  set order to tag COM_CODE

  SELECT 0
  USE &ML_PATH.CATEG ALIAS CATEG
  set order to tag CAT_CODE

  SELECT AUX_MAS
  SET RELATION TO COM_CODE INTO COMPANY
  SET RELATION TO AUX_CODE INTO CATEG ADDITIVE

  I_FR = SPACE(LEN(COMPANY.COM_CODE))
  I_TO = SPACE(LEN(COMPANY.COM_CODE))
  I_FRTYPE = SPACE(LEN(COMPANY.CLI_TYPE))
  I_TOTYPE = SPACE(LEN(COMPANY.CLI_TYPE))

  ACTIVATE WINDOW W_RANGE
  @ 01,05 SAY 'COMPANY CODE'
  @ 03,05 SAY 'FROM:' GET I_FR PICT '@!'
  @ 05,05 SAY 'TO  :' GET I_TO PICT '@!'

  @ 01,25 SAY 'COMPANY TYPE'
  @ 03,25 SAY 'FROM:' GET I_FRTYPE PICT '@!'
  @ 05,25 SAY 'TO  :' GET I_TOTYPE PICT '@!'
  READ
	
  IF LASTKEY() # K_ESC
    IF I_FR > I_TO and (not EMPTY(I_TO))
      TMP1 = I_FR
      I_FR = I_TO
      I_TO = TMP1
    ENDIF

    **  Filter String  **
    I_FILTER=space(1)
    IF not EMPTY(I_FR)
      I_FILTER = ' COM_CODE >= I_FR '
    ENDIF

    IF not EMPTY(I_TO)
      if not empty(I_FILTER)
        I_FILTER = I_FILTER + 'and COM_CODE <= I_TO'
      else
        I_FILTER = ' COM_CODE <= I_TO'
      endif
    ENDIF

    if not empty(I_FRTYPE)
      if not empty(I_FILTER)
        I_FILTER = ' and CLI_TYPE >= I_FRTYPE '
      else
        I_FILTER = ' CLI_TYPE >= I_FRTYPE '
      endif
    endif

    if not empty(I_TOTYPE)
      if not empty(I_FILTER)
        I_FILTER = ' and CLI_TYPE <= I_TOTYPE '
      else
        I_FILTER = ' CLI_TYPE <= I_TOTYPE '
      endif
    endif
    IF 'Y'=('PRINT REPORT NOW')
      ACTIVATE WINDOW W_MSG
      ? 'PRINTING ...'

      SET CONSOLE OFF
      IF EMPTY(I_FR) and EMPTY(I_TO) and ;
         empty(I_FRTYPE) .and empty(I_TOTYPE)
        REPORT FORM COMPANY2 ALL to printer
      ELSE
        REPORT FORM COMPANY2 FOR &I_FILTER to printer
      ENDIF
      SET CONSOLE ON
    ENDIF
  ENDIF

  CLOSE DATABASES
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_RANGE
  RELEASE WINDOW W_MSG
RETURN

*----------------------------*
*  Report Company -- Client  *
*----------------------------*
*  RPT_GEN.
PROCEDURE COM_CLI
  PRIVATE I_FR, I_TO, I_FILTER, TMP1, W_HEAD

  DEFINE WINDOW W_RANGE FROM 10,20 TO 20,60 SHADOW COLOR W+/N,W/N,W/N PANEL
  DEFINE WINDOW W_MSG FROM 15,05 TO 17,40 COLOR N/W,N/W,N/W,N/W,N/W,N/W ;
         SHADOW
  W_HEAD=SHOWHEAD('COMPANY WITH CLIENT')

  I_FR = SPACE(LEN(COMPANY.COM_CODE))
  I_TO = SPACE(LEN(COMPANY.COM_CODE))

  ACTIVATE WINDOW W_RANGE
  @ 01,05 SAY 'COMPANY'
  @ 03,05 SAY 'FROM:' GET I_FR PICTURE '@!'
  @ 05,05 SAY 'TO  :' GET I_TO PICTURE '@!'
  READ
	
  IF LASTKEY() # K_ESC
    IF I_FR > I_TO and (not EMPTY(I_TO))
      TMP1 = I_FR
      I_FR = I_TO
      I_TO = TMP1
    ENDIF

    **  Filter String  **
    IF not EMPTY(I_FR)
      I_FILTER = ' COM_CODE >= I_FR '
      IF not EMPTY(I_TO)
        I_FILTER = I_FILTER + 'and COM_CODE <= I_TO'
      ENDIF
    ELSE
      IF not EMPTY(I_TO)
        I_FILTER = ' COM_CODE <= I_TO'
      ENDIF
    ENDIF

    IF 'Y'=ASKYN('PRINT REPORT NOW')
      SELECT 0
      USE &ML_PATH.COMPANY ALIAS COMPANY
      if used('COMPANY')
        set order to tag COM_CODE

        SELECT 0
        USE &ML_PATH.CLIENT ALIAS CLIENT
        if used('CLIENT')
          set order to tag COM_CODE
          set relation to COM_CODE into COMPANY

          ACTIVATE WINDOW W_MSG
          ? 'PRINTING ...'

          SET CONSOLE OFF
          IF EMPTY(I_FR) and EMPTY(I_TO)
            REPORT FORM COMPANY3 ALL to printer
          ELSE
            REPORT FORM COMPANY3 FOR &I_FILTER to printer
          ENDIF
          SET CONSOLE ON
        else
          =ERRMSG('Client in use. Try later!')
        endif
      else
        =ERRMSG('Company master in use. Try later!')
      endif
    ENDIF
  ENDIF

  CLOSE DATABASES
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_RANGE
  RELEASE WINDOW W_MSG
RETURN

*--------------------------*
*  Report Business Nature  *
*--------------------------*
*  RPT_GEN.
PROCEDURE RPT_CATEG
  PRIVATE I_FR, I_TO, I_FILTER, TMP1, W_HEAD, M_KEY

  DEFINE WINDOW W_RANGE FROM 10,20 TO 20,60 SHADOW COLOR W+/N,W/N,W/N PANEL
  DEFINE WINDOW W_MSG FROM 15,05 TO 17,40 COLOR N/W,N/W,N/W,N/W,N/W,N/W ;
         SHADOW

  W_HEAD=SHOWHEAD('LIST ALL ATTRIBUTES')

  SELECT 0
  USE &ML_PATH.CATEG ALIAS CATEG
  if used("CATEG")
    set order to tag CAT_TYPE

    I_FR = SPACE(LEN(CATEG.CAT_CODE))
    I_TO = SPACE(LEN(CATEG.CAT_CODE))

    ACTIVATE WINDOW W_RANGE

    @ 03,05 SAY 'FROM:' GET I_FR PICT '@!'
    @ 05,05 SAY 'TO  :' GET I_TO PICT '@!'
    READ

    IF LASTKEY() # K_ESC
      IF I_FR > I_TO and (not EMPTY(I_TO))
        TMP1 = I_FR
        I_FR = I_TO
        I_TO = TMP1
      ENDIF

      **  Filter String  **
      IF not EMPTY(I_FR)
        I_FILTER = ' CAT_CODE >= I_FR '
        IF not EMPTY(I_TO)
          I_FILTER = I_FILTER + 'and CAT_CODE <= I_TO'
        ENDIF
      ELSE
        IF not EMPTY(I_TO)
          I_FILTER = ' CAT_CODE <= I_TO'
        ENDIF
      ENDIF

      IF 'Y'=ASKYN('PRINT REPORT NOW')
        ACTIVATE WINDOW W_MSG
        ? 'PRINTING ...'

        SELECT CATEG

        SET CONSOLE OFF
        IF EMPTY(I_FR) and EMPTY(I_TO)
          REPORT FORM CATEG ALL to printer
        ELSE
          REPORT FORM CATEG FOR &I_FILTER to printer
        ENDIF
        SET CONSOLE ON
      ENDIF
    ENDIF
  ELSE
    =ERRMSG("CATEGORY DATABASE IN USE. TRY LATER!")
  ENDIF

  CLOSE DATABASES
  RELEASE WINDOW (W_HEAD)
  RELEASE WINDOW W_MSG
  RELEASE WINDOW W_RANGE
RETURN

*
*  NOTE: this function is required by REPORT FORM CATEG
*
function LONG_TYPE
  parameter M_KEY

  do case
    case M_KEY = "B"
      return 'BUSINESS NATURE'
    case M_KEY = "P"
      return 'PUBLICATION'
    case M_KEY = "D"
      return 'DIRECTOR CODES'
    case M_KEY = "C"
      return 'COUNTRY CODES'
    case M_KEY = "O"
      return 'POSITION'
    case M_KEY = "T"
      return 'CIRCULATION'
    case M_KEY = "1"
      return 'KEY CLIENT'
    case M_KEY = "2"
      return 'SRG NEWS'
  endcase
return M_STRING
