*****************************************************************************
* Filename    : ML_FILT.PRG           Survey Research Hongkong Limited
*---------------------------------------------------------------------------
* Description : allow user to choose selection criteria when searching data
*               written using FOXPRO LAN ver 1.0
*---------------------------------------------------------------------------
* INPUT PARAMATERS:  SEL_STR[8]
* OUTPUT PARAMETERS: SEL_STR[8]
*
* Modification History
*
* Date         Programmer      Description
* --------     -------------   ---------------------------------------------
* 14/05/90     Daniel Chu      Initial coding
* June 1991    Chang Man Wai   Revised and ehannced using FoxPro/LAN
*                              1.02 features: BROWSE, ON KEY LABEL,
*                              windowing and menuing
* NOV 1, 1991  Chang Man Wai   Ported to FoxPro 2.0
*****************************************************************************
  private AGAIN, M_KEY, M_RC
  M_RC = .F.

  define window W_FKEY50 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W

  define window W_CURRENT FROM 05,02 TO 15,74 ;
                TITLE ' CURRENT CLIENT SELECTION CRITERIA ' SHADOW ;
                COLOR W+/N,W/N,W/N,N/W PANEL

  DO SHOWFKEY WITH 01,'ESC','QUIT','W_FKEY50'
  DO SHOWFKEY WITH 30,'ENTER','EDIT FILTER','W_FKEY50'
  DO SHOWFKEY WITH 65,'F10','DONE','W_FKEY50'

  SELECT CATEG
  IF FLOCK()
    REPLACE ALL FLAG WITH SPACE(1) FOR .NOT. EMPTY(FLAG)
    AGAIN = .T.
    DO WHILE AGAIN
      ACTIVATE WINDOW W_CURRENT
      CLEAR
      IF EMPTY(SEL_STR[1]+SEL_STR[2]+SEL_STR[3]+SEL_STR[4]+;
               SEL_STR[5]+SEL_STR[6]+SEL_STR[7]+SEL_STR[8])
        @ 01,05 SAY 'ALL CLIENTS !!' COLOR W*/N
      ELSE
        @ 01,05 SAY SEL_STR[1] + ' ; ' + SEL_STR[2] + ' ; ' + ;
                    SEL_STR[3] + ' ; ' + SEL_STR[4] + ' ; ' + ;
                    SEL_STR[5] + ' ; ' + SEL_STR[6] + ' ; ' + ;
                    SEL_STR[7] + ' ; ' + SEL_STR[8] COLOR GR+/N
      ENDIF

      M_KEY=INKEY(0)

      DO CASE
        CASE M_KEY=K_ENTER
          DO DATA_SEL
          AGAIN = .T.
        CASE M_KEY=K_ESC
          AGAIN = .F.
        CASE M_KEY=K_F10
          AGAIN = .F.
          M_RC = .T.
      ENDCASE
    ENDDO

    SELECT CATEG
    SET FILTER TO
    GO TOP
    REPLACE ALL FLAG WITH " "
    UNLOCK
  ELSE
    =ERRMSG('CATEGORY DATABASE IN USE. TRY AGAIN!')
  ENDIF

  release window W_CURRENT
  release window W_FKEY50
return M_RC

**************************
* SELECT FILTER CRITERIA *
**************************
procedure DATA_SEL
  private AGAIN, M_LOOP, DUMKEY, WIN_NO, I_COUNT, M_I, ;
          WIN_NAME, C_W_REC, I_SEL_KEY, I_SEL_TYPE, M_WTITLE
  declare C_W_REC[8], I_SEL_KEY[8], I_SEL_TYPE[8], M_WTITLE[8]

  define window W_FKEY51 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W

  define window W_CRITERIA FROM 04,03 TO 21,25 TITLE ' CRITERIA ' ;
                           COLOR N/W,N/W,N/W,N/W,N/W,N/W SHADOW

  define window W_BRATTR FROM 04,30 TO 22,75 SHADOW ;
                PANEL COLOR W/N,N/W,N/W, N/W,W/N,N/W, N/W,N/N,N/W, W/N,N/W

  do SHOWFKEY with 01, 'ESC', 'QUIT', 'W_FKEY51'
  do SHOWFKEY with 20, '',   'NEXT CRITERIA', 'W_FKEY51'
  do SHOWFKEY with 40, '',   'PREV CRITERIA', 'W_FKEY51'
  do SHOWFKEY with 65, 'F10', 'FINISH', 'W_FKEY51'

  * define windows to be used in browsing the attributes
  FOR M_I = 1 TO 8
    I_SEL_KEY[M_I]  = 0   &&
    I_SEL_TYPE[M_I] = ''  && filter for filtering attributes in each window
    M_WTITLE[M_I]   = space(1)  && window titles
  ENDFOR

  WIN_NO  = 1        && current window number
  I_COUNT = 0        && ACTUAL number of attribute windows to open

  DO SEL_KEY_SEQ

  IF KEY_WIN_F()  && user has selected some attributes to report
    * show all windows first

    FOR M_I = 1 TO I_COUNT
      SELECT CATEG
      GO TOP
      locate for CAT_TYPE = I_SEL_TYPE[M_I]
      if found()
        C_W_REC[M_I] = RECNO()   && initialize current record in each window
      else
        C_W_REC[M_I] = 1
      endif
    ENDFOR

    SELECT CATEG
    SET FILTER TO

    M_LOOP = .T.
    do while M_LOOP
      AGAIN = .F.

      on key label rightarrow do NEXTWIN
      on key label leftarrow  do PREVWIN

      * goto last record position
      * debugging
      SELECT CATEG
      IF not C_W_REC[WIN_NO] > reccount()
        goto C_W_REC[WIN_NO]  && restore last location of the record pointer in window
      ENDIF

      * let user to pick attributes in current window
      WIN_NAME=STR(WIN_NO,1,0)+space(1)+M_WTITLE[WIN_NO]
      browse fields FLAG:H=" X ", ;
                    CAT_DESC:H=" DESCRIPTION ":R ;
             for CAT_TYPE = I_SEL_TYPE[WIN_NO] ;
             freeze FLAG ;
             nodelete noappend ;
             window W_BRATTR title WIN_NAME

      on key label rightarrow
      on key label leftarrow

      if .not. AGAIN
        do case
          CASE LASTKEY()=K_ESC
            M_LOOP = .F.
          CASE LASTKEY()=K_C_W
            M_LOOP = .F.
            do OPT_FILT with I_SEL_TYPE
        endcase
      endif
    enddo    && M_LOOP
  endif

  release window W_CRITERIA
  release window W_FKEY51
  release window W_BRATTR
return

procedure PREVWIN
  *
  * variable AGAIN passed from caller
  *
  push key clear

  C_W_REC[WIN_NO]=RECNO()

  WIN_NO = WIN_NO - 1
  IF WIN_NO < 1
     WIN_NO = I_COUNT
  ENDIF

  AGAIN=.T.
  KEYBOARD CHR(K_ESC)

  pop key
RETURN

procedure NEXTWIN
  * variable AGAIN passed from caller
  push key clear

  C_W_REC[WIN_NO]=RECNO()

  WIN_NO = WIN_NO + 1
  IF WIN_NO > I_COUNT
     WIN_NO = 1
  ENDIF

  AGAIN=.T.
  keyboard chr(K_ESC)
  pop key
RETURN

************************
* SELECT SEQUENCE OF ATTRIBUTES
************************
procedure SEL_KEY_SEQ
  * browse the attributes within a window
  private AGAIN, TMP1, TMP2, PMT, MSG
  declare PMT[8],MSG[8]

  define window W_FKEY57 FROM 24,00 TO 24,79 NONE NOSHADOW COLOR N/W,N/W,N/W
  do SHOWFKEY with 01,'ESC','DONE','W_FKEY57'
  do SHOWFKEY with 15,'ENTER','SELECT/DESELECT','W_FKEY57'

  FOR TMP1 = 1 TO 8
      PMT[TMP1] = ''
      MSG[TMP1] = ''
  ENDFOR

  activate window W_CRITERIA

  TMP2  = 0
  AGAIN = .T.
  do while AGAIN
     * shown chosen criteria with sequence number on the left
     IF I_SEL_KEY(1)=0
        PMT(1) = '  ' + 'Business   '
        MSG(1) = 'Select business nature'
     ELSE
        PMT(1) = STR(I_SEL_KEY(1),1) + ' ' + 'Business   '
        MSG(1) = 'Unselect business nature'
     ENDIF
     IF I_SEL_KEY(2)=0
        PMT(2) = '  ' + 'Country    '
        MSG(2) = 'Select country'
     ELSE
        PMT(2) = STR(I_SEL_KEY(2),1) + ' ' + 'Country    '
        MSG(2) = 'Unselect country'
     ENDIF
     IF I_SEL_KEY(3)=0
        PMT(3) = '  ' + 'Director   '
        MSG(3) = 'Select director'
     ELSE
        PMT(3) = STR(I_SEL_KEY(3),1) + ' ' + 'Director   '
        MSG(3) = 'Unselect director'
     ENDIF
     IF I_SEL_KEY(4)=0
        PMT(4) = '  ' + 'Publication'
        MSG(4) = 'Select publication'
     ELSE
        PMT(4) = STR(I_SEL_KEY(4),1) + ' ' + 'Publication'
        MSG(4) = 'Unselect publication'
     ENDIF
     IF I_SEL_KEY(5)=0
        PMT(5) = '  ' + 'Circulation'
        MSG(5) = 'Select publication'
     ELSE
        PMT(5) = STR(I_SEL_KEY(5),1) + ' ' + 'Circulation'
        MSG(5) = 'Unselect Circulation'
     ENDIF
     IF I_SEL_KEY(6)=0
        PMT(6) = '  ' + 'Position'
        MSG(6) = 'Select publication'
     ELSE
        PMT(6) = STR(I_SEL_KEY(6),1) + ' ' + 'Position'
        MSG(6) = 'Unselect Position'
     ENDIF
     IF I_SEL_KEY(7)=0
        PMT(7) = '  ' + 'Key Clients'
        MSG(7) = 'Select Key Client '
     ELSE
        PMT(7) = STR(I_SEL_KEY(7),1) + ' ' + 'Key Client '
        MSG(7) = 'Unselect Misc 1     '
     ENDIF
     IF I_SEL_KEY(8)=0
        PMT(8) = '  ' + 'SRG News   '
        MSG(8) = 'Select SRG News   '
     ELSE
        PMT(8) = STR(I_SEL_KEY(8),1) + ' ' + 'SRG News   '
        MSG(8) = 'Unselect SRG News   '
     ENDIF

     * menu
     SET COLOR TO N/W,W+/N
     SET MESSAGE TO 23
     FOR TMP1 = 1 TO 8
        @ TMP1,3 PROMPT PMT[TMP1]
     ENDFOR
     SET COLOR TO
     MENU TO TMP2

     DO CASE
        CASE READKEY() = 12 .OR. TMP2 = 0    && ESC terminates selection
           AGAIN  = .F.
        CASE TMP2 <> 0
           DO SHUFFLE WITH TMP2
           IF TMP2 < 8
              TMP2 = TMP2 + 1
           ELSE
              TMP2 = 1
           ENDIF
     ENDCASE
  ENDDO

  release window W_FKEY57
return

*****************************
* RE-SHUFFLE CRITERIA SEQUENCE *
*****************************
* number the sequence of chosen criteria
procedure SHUFFLE
  PARAMETER I_INDEX
  PRIVATE I_MAX_VAL, I_MIN_VAL, ORG_VAL

  I_MAX_VAL = 0
  I_MIN_VAL = 0
  ORG_VAL   = I_SEL_KEY(I_INDEX)

  * locate maximum sequence number since last selection
  FOR TMP1 = 1 TO 8
    IF I_MAX_VAL < I_SEL_KEY[TMP1]
      I_MAX_VAL = I_SEL_KEY[TMP1]
    ENDIF
  ENDFOR

  IF I_SEL_KEY(I_INDEX) = 0      && newly selected attribute, give it a number
    I_SEL_KEY(I_INDEX) = I_MAX_VAL + 1
  ELSE
    I_SEL_KEY(I_INDEX) = 0       && re-assign numbers to selected attributes
    FOR TMP1 = 1 TO 8
      IF TMP1 <> I_INDEX and I_SEL_KEY[TMP1] > ORG_VAL
        I_SEL_KEY[TMP1] = I_SEL_KEY[TMP1] - 1
      ENDIF
    ENDFOR
  ENDIF
RETURN

* browse selections in four windows
* set maximum number of windows to open
*
function KEY_WIN_F
  private TEMP, TMP1, TMP2, M_RC

  * check which window are selected
  I_COUNT = 0
  for TMP1 = 1 to 8
    if I_SEL_KEY[TMP1] <> 0
      I_COUNT = I_COUNT + 1
    endif
  endfor

  if I_COUNT > 0
    * match filter string I_SEL_TYPE with numbered selection criteria
    * assign window to each selection criteria

    for TMP1 = 1 to I_COUNT
      for TEMP = 1 to 8
        if I_SEL_KEY[TEMP] = TMP1
          do case
            case TEMP = 1
                 I_SEL_TYPE[TMP1] = 'B'
                 M_WTITLE[TMP1] = 'BUSINESS'
            case TEMP = 2
                 I_SEL_TYPE[TMP1] = 'C'
                 M_WTITLE[TMP1] = 'COUNTRY'
            case TEMP = 3
                 I_SEL_TYPE[TMP1] = 'D'
                 M_WTITLE[TMP1] = 'DIRECTOR'
            case TEMP = 4
                 I_SEL_TYPE[TMP1] = 'P'
                 M_WTITLE[TMP1] = 'PUBLICATION'
            case TEMP = 5
                 I_SEL_TYPE[TMP1] = 'T'
                 M_WTITLE[TMP1] = 'CIRCULATION'
            case TEMP = 6
                 I_SEL_TYPE[TMP1] = 'O'
                 M_WTITLE[TMP1] = 'POSITION'
            case TEMP = 7
                 I_SEL_TYPE[TMP1] = '1'
                 M_WTITLE[TMP1] = 'KEY CLIENT'
            case TEMP = 8
                 I_SEL_TYPE[TMP1] = '2'
                 M_WTITLE[TMP1] = 'SRG NEWS'
          endcase
        endif
      endfor
    endfor
  endif
return I_COUNT > 0

**************************
*  CHECK FILTER SELECTED *
**************************
procedure OPT_FILT
  parameter I_SEL_TYPE
  private ALL_REC, SEL_REC, M_FIRST, TMP_STR, V_NAME, M_BEGIN, TMP1

  define window W_MSG from 05,20 to 07,50 color W+/N,W+/N,W+/N shadow
  activate window W_MSG
  ? SPACE(1)+'OPTIMIZING FILTER ...'

  * clear previous filter values
  for TMP1 = 1 to 8
     SEL_STR[TMP1]=SPACE(1)
  endfor

  select CATEG
  for TMP1 = 1 to I_COUNT
    TMP_STR = ''
    ALL_REC = 0        && no of records matching filter
    SEL_REC = 0        && no of records matching filter and are being selected
    M_BEGIN = .T.

    select CATEG
    set filter to
    go top
    * count size of selected category
    count all FOR CAT_TYPE = I_SEL_TYPE[TMP1] TO ALL_REC
    * count number of selected attribute category
    count all FOR CAT_TYPE = I_SEL_TYPE[TMP1] and .not. EMPTY(FLAG) TO SEL_REC

    if ALL_REC = 0  .or. SEL_REC = 0
       loop
    endif

    go top
    if M_BEGIN       && build the filter string, begins with a '('
       TMP_STR = TMP_STR + '('
       M_BEGIN = .F.
    endif

    * field name in AUX_MAS database to be used to build filter
    if upper(I_SEL_TYPE[TMP1]) = 'C'
       V_NAME = 'COU_CODE'      && country code
    else
       V_NAME = 'AUX_CODE'      && publication/director/business nature
    endif

    * optimize the filter by replaceing .NOT. and .AND. connectives
    * with .OR. connectives if over half of the CATEG records
    * are selected ...
    if SEL_REC > (ALL_REC / 2)
      set filter to CAT_TYPE = I_SEL_TYPE[TMP1] and EMPTY(FLAG)
      go top
      M_FIRST = .T.
      if (SEL_REC = ALL_REC and I_SEL_TYPE[TMP1] <> 'C')
        TMP_STR = TMP_STR + "AUX_TYPE='" + I_SEL_TYPE[TMP1] + "')"
      else
        scan
          if M_FIRST
            TMP_STR = TMP_STR + ".NOT.(" + V_NAME + "='" + CAT_CODE + "'"
            M_FIRST = .F.
          else
            TMP_STR = TMP_STR + ".OR." + V_NAME + "='" + CAT_CODE + "'"
          endif
        endscan
        TMP_STR=TMP_STR+")"
        * added by Chang Man Wai
        TMP_STR = TMP_STR + ".AND.(AUX_TYPE = '"+I_SEL_TYPE[TMP1]+"') )"
      endif && SEL_REC = ALL_REC
    else
      set filter to CAT_TYPE = I_SEL_TYPE[TMP1] and .NOT. EMPTY(FLAG)
      go top
      M_FIRST = .T.
      scan
        if M_FIRST        && start of string - no connective required
          TMP_STR = TMP_STR + V_NAME + "='" + CAT_CODE + "'"
          M_FIRST=.F.
        else
          TMP_STR = TMP_STR + ".OR." + V_NAME + "='" + CAT_CODE + "'"
        endif
      endscan
      * added by Chang Man Wai
      if upper(I_SEL_TYPE[TMP1])='C' .or. upper(I_SEL_TYPE[TMP1])='B'
         TMP_STR = TMP_STR + ")"
      else
         TMP_STR = TMP_STR + ".AND.(AUX_TYPE = '"+I_SEL_TYPE[TMP1]+"') )"
      endif
    endif

    if TMP_STR = ')'    && reset TMP_STR to start another loop
      TMP_STR = ""
    endif

    SEL_STR[TMP1] = TMP_STR
  endfor

  release window W_MSG
return
