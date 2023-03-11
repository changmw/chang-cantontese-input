*---------------------------------------------------------------------------*
* Filename   :  ML_LABEL.PRG                                                *
*                                                                           *
* Description:  Program for report generator module                         *
*                                                                           *
* Author     :  Kai wing Fung, Chicken                                      *
* Revision   :  Chang Man Wai
*                                                                           *
* Owner      :  Survey Research Hong Kong Limited (System Development Team) *
*                                                                           *
* Init. Date :  23-May-1990                                                 *
*                                                                           *
* Prog. Lang.:  FoxPro Version 1.02 (Multi-user)                            *
*                                                                           *
* Modification History :-                                                   *
*                                                                           *
* Date              Modification Detail                      Remark         *
* ----              -------------------                      ------         *
* 23-May-1990       Init. coding                                            *
* June 1991         REVISED AND ENHANCED BY CHANG MAN WAI, REPLACE ODD
*                   CODING WITH FOXPRO/LAN's features
*                   Update to FoxPro/LAN 1.02
* OCT 29, 1991      Revised with FoxPro/LAN 2.0
* OCT 1992          performance tuning leading to a faster record selection process
*---------------------------------------------------------------------------*
  private W_HEAD

  W_HEAD=SHOWHEAD('PRINT CLIENT LABELS')

  SET COLOR TO N/W,W+/N
  define popup W_SELMETH FROM 10,20 SHADOW
  define bar 1 OF W_SELMETH PROMPT 'LABEL WITH TITlE'
  define bar 2 OF W_SELMETH PROMPT 'LABEL WITHOUT TITLE'
  define bar 3 OF W_SELMETH PROMPT 'CLIENT REPORT'
  define bar 4 OF W_SELMETH PROMPT 'ADDRESS BOOK'
  define bar 5 OF W_SELMETH PROMPT 'WORDPERFECT MAILMERGE'
  define bar 6 OF W_SELMETH PROMPT 'EXPORT TO DBASE FILE'
  on selection POPUP W_SELMETH DO BUILDFIL WITH BAR()

  ACTIVATE POPUP W_SELMETH

  release window (W_HEAD)
  release popup  W_SELMETH
return

procedure BUILDFIL
  parameters M_BAR
  private M_CURSOR, TMP1, TMP2, M_HOME, M_MSG, M_FILTER, M_FNAME, M_COUNT
  private M_AUXMAS
  private SEL_STR          && FILTER STRINGS FOR AUX_MAS.DBF
  declare SEL_STR[8]

  SELECT 0
  USE &ML_PATH.CATEG ALIAS CATEG
  IF USED('CATEG')
    set order to tag CAT_CODE
  ELSE
    =ERRMSG('DATABASES IN USE. TRY LATER')
    CLOSE DATABASES
    RETURN
  ENDIF

  SELECT 0
  USE &ML_PATH.COMPANY ALIAS COMPANY
  IF USED('COMPANY')
    set order to tag COM_CODE
  ELSE
    =ERRMSG('DATABASES IN USE. TRY LATER')
    CLOSE DATABASES
    RETURN
  ENDIF

  SELECT 0
  USE &ML_PATH.CLIENT ALIAS CLIENT
  IF USED('CLIENT')
    set order to tag MAS_CODE
  ELSE
    =ERRMSG('DATABASES IN USE. TRY LATER')
    CLOSE DATABASES
    RETURN
  ENDIF

  SELECT 0
  USE &ML_PATH.AUX_MAS ALIAS AUX_MAS
  IF USED('AUX_MAS')
    set order to tag AUX_CODE
  ELSE
    =ERRMSG('DATABASES IN USE. TRY LATER')
    CLOSE DATABASES
    RETURN
  ENDIF

  * establish scope parent
  FOR TMP1 = 1 TO 8
    SEL_STR[TMP1]=''
  ENDFOR

  IF ML_FILT()          && get filter string SEL_STR[8]
    DEFINE WINDOW W_MSG FROM 10,30 TO 20,70 SHADOW PANEL ;
           COLOR W/N,W/N,W/N,W/N
    ACTIVATE WINDOW W_MSG
    ? SPACE(2)+'PLEASE BE PATIENT ...'
    ? SPACE(2)+'SEARCHING RECORD ...'

*    SELECT CLIENT
*    IF FLOCK()
*      SELECT AUX_MAS
*      IF FLOCK()
        * count number of non-empty filter string in SEL_STR[8]
        TMP2 = 0
        FOR TMP1 = 1 TO 8
          IF .NOT. EMPTY(SEL_STR[TMP1])
            TMP2 = TMP2 + 1
          ENDIF
        ENDFOR

        * label and reports are to be sorted by company code
        * so the SQL statement SORT BY COM_CODE
        DO CASE
          CASE TMP2 = 0            && print all records
            SELECT AUX_MAS
            M_CURSOR=sys(3)
            set talk on
            select distinct MAS_CODE, COM_CODE, space(10) as COM_NAME ;
                 from AUX_MAS ;
                 order by COM_CODE ;
                 where MAS_CODE > 0 ;
                 into table (M_CURSOR)
            set talk off
          CASE TMP2 = 1            && exactly one filter
            TMP1 = 1
            DO WHILE EMPTY(SEL_STR[TMP1])    && locate for the specified filter
              TMP1=TMP1 + 1
            ENDDO
	
            M_FILTER=SEL_STR[TMP1]
            M_CURSOR=sys(3)
            set talk on
            select distinct MAS_CODE, COM_CODE, space(10) as COM_NAME ;
                 from AUX_MAS ;
                 where &M_FILTER and MAS_CODE > 0;
                 order by COM_CODE ;
                 into table (M_CURSOR)
            set talk off
          OTHERWISE                && more than one filter strings
            DO FILT_MAS WITH SEL_STR    && mark records in AUX_MAS.DBF

            M_CURSOR = SYS(3)     && obtain a unqiue temporary file name
            set talk on
            select distinct MAS_CODE, COM_CODE, space(10) as COM_NAME ;
                 from AUX_MAS ;
                 where .not.empty(FLAG) ;
                 order by COM_CODE ;
                 into table (M_CURSOR)
            set talk off
        ENDCASE
        M_AUXMAS=alias()

        * mark clients that are owner of the attribute records
        * selected by FILT_MAS.PRG
        select CLIENT                 && clear attributes
        set order to tag MAS_CODE
        set relation to COM_CODE into COMPANY

        select COMPANY
        set relation to COU_CODE into CATEG

        select (M_AUXMAS)
        count to M_COUNT
        set relation to MAS_CODE into CLIENT
        replace all COM_CODE with CLIENT.COM_CODE
        * report is to be sorted by name
        set relation to COM_CODE into COMPANY
        replace all COM_NAME with COMPANY.COM_NAME
        index on COM_NAME tag COM_NAME
        set order to tag COM_NAME

        set relation to MAS_CODE into CLIENT
        go top

        IF M_COUNT = 0        && there are reports to print
          =INKEYBOX('NO RECORDS FOUND ...')
        ELSE
          ACTIVATE WINDOW W_MSG
          CLEAR
          @ 04,05 SAY 'NUMBER OF RECORDS: '+STR(M_COUNT,5,0)
          IF 'Y'=ASKYN('PRINT LABELS/REPORT NOW')
            * relations are established just before report are printed

            ACTIVATE WINDOW W_MSG

            SET CONSOLE OFF
            DO CASE
              CASE M_BAR=1   && Print label with title
                @ 02, 05 SAY 'PRINTING LABELS (WITH TITLE)...'  color w+/n
                select (M_AUXMAS)
                LABEL FORM SRH_WT ALL SAMPLE to printer
              CASE M_BAR=2   && Print label without title
                @ 02, 05 SAY 'PRINTING LABEL (NO TITLE) ...' color w+/n
                select (M_AUXMAS)
                LABEL FORM SRH ALL SAMPLE to printer
              CASE M_BAR=3   && report CLIENT1
                @ 02, 05 SAY 'PRINTING CLIENT REPORTS ...' color w+/n
                select (M_AUXMAS)
                REPORT FORM CLIENT1 ALL to printer
              CASE M_BAR=4          && output text file address book
                clear
                M_HOME='ADDRBOOK'
                set confirm on
                @ 01, 05 say 'OUTPUT FILE: ' get M_HOME picture '@!' ;
                                             valid V_FNAME(rtrim(M_HOME))
                read
                set confirm off
                if lastkey()#K_ESC
                  M_HOME=rtrim(M_HOME)
                  @ 02, 02 SAY 'WRITING ADDRESS BOOK TO '+;
                               alltrim(M_HOME)+'.TXT' color W+*/N
                  select (M_AUXMAS)
                  REPORT FORM ADDRBOOK ALL to file &M_HOME.
                  wait 'PLS USE WORDPERFECT TO PRINT '+;
                       alltrim(M_HOME)+'.TXT!' window
                endif
              CASE M_BAR=5          && output text file for mail merge
                @ 02, 05 SAY 'STORING SECONDARY FILE AS MM.TXT ...' color w+/n

                set alternate to MM
                set alternate on
                set console off

                ? "<NAME>"
                ? "<TITLE>"
                ? "<COMPANY NAME>"
                ? "<COMPANY ADDR 1>"
                ? "<COMPANY ADDR 2>"
                ? "<COMPANY ADDR 3>"
                ? "<COMPANY ADDR 4>"
                ? chr(12)
                select (M_AUXMAS)
                scan
                  ? alltrim(proper(CLIENT.INIT))+space(1)+;
                    alltrim(proper(CLIENT.F_NAME))+space(1)+;
                    alltrim(proper(CLIENT.L_NAME))
                  ? rtrim(proper(CLIENT.TIT))
                  ? rtrim(proper(COMPANY.COM_NAME))
                  ? rtrim(proper(COMPANY.COM_ADD1))
                  ? rtrim(proper(COMPANY.COM_ADD2))
                  ? rtrim(proper(COMPANY.COM_ADD3))
                  ? rtrim(COMPANY.COM_ADD4)
                  ? chr(12)
                endscan

                set alternate to
                set alternate off
                set console on

                wait 'YOU MAY NOW USE MM.TXT FOR MAIL MERGE!' window
              CASE M_BAR=6          && export databases
                M_FNAME = "CLI"

                create table &M_FNAME. ( ;
                  INITIAL C(len(CLIENT.INIT)), ;
                  LASTNAME C(len(CLIENT.L_NAME)), ;
                  FIRSTNAME C(len(CLIENT.F_NAME)), ;
                  TITLE C(len(CLIENT.TIT)), ;
                  COMPANY C(len(COMPANY.COM_NAME)), ;
                  ADDRESS1 C(len(COMPANY.COM_ADD1)), ;
                  ADDRESS2 C(len(COMPANY.COM_ADD2)), ;
                  ADDRESS3 C(len(COMPANY.COM_ADD3)), ;
                  ADDRESS4 C(len(COMPANY.COM_ADD4)), ;
                  TEL_DIR  C(len(CLIENT.TEL_DIR)), ;
                  TEL      C(len(CLIENT.TEL)), ;
                  FAX      C(len(CLIENT.FAX)) ;
                )
                use

                select 0
                use &M_FNAME. alias OUTDBF

                @ 02, 05 SAY 'EXPORTING DATABASE FILES ...' color w+/n

                select (M_AUXMAS)
                scan
                  select OUTDBF
                  append blank
                  replace INITIAL    with CLIENT.INIT,  ;
                          FIRSTNAME  with CLIENT.F_NAME, ;
                          LASTNAME   with CLIENT.L_NAME, ;
                          TITLE      with CLIENT.TIT, ;
                          COMPANY    with COMPANY.COM_NAME, ;
                          ADDRESS1   with COMPANY.COM_ADD1, ;
                          ADDRESS2   with COMPANY.COM_ADD2, ;
                          ADDRESS3   with COMPANY.COM_ADD3, ;
                          ADDRESS4   with COMPANY.COM_ADD4, ;
                          TEL        with CLIENT.TEL, ;
                          TEL_DIR    with CLIENT.TEL_DIR, ;
                          FAX        with CLIENT.FAX
                endscan

                wait M_FNAME+'.DBF STORED IN YOUR DIRECTORY!' window
            ENDCASE
            SET CONSOLE ON
          ENDIF   && INKEYBOX('PRINT NOW?')
        ENDIF     && (M_COUNT > 0)

        SELECT CATEG
        REPLACE ALL FLAG WITH SPACE(1) FOR .NOT. EMPTY(FLAG)
*      ELSE
*        =ERRMSG('AUX_MAS.DBF is in use. Try later!')
*      ENDIF       && FLOCK(AUX_MAS)
*    ELSE
*      =ERRMSG('CLIENT.DBF is in use. Try later!')
*    ENDIF         && FLOCK(CLIENT)

    RELEASE WINDOW W_MSG
  ENDIF           && ML_FILT()

  CLOSE DATABASES
  delete file &M_CURSOR..DBF
  delete file &M_CURSOR..CDX
RETURN

procedure FILT_MAS
  *
  * INPUT PARAMETERS: SEL_STR[8]
  *
  * SEL_STR are ANDed together
  *
  * This module is the most complicate part of the whole SRHIS-ML.
  * It aims to mark the right records in AUX_MAS.DBF using the filtering
  * criteria specified by SEL_FILT[1..8] in the shortest possible time.
  *
  parameters SEL_STR
  private M_I, M_FIRST, F_TEMP, M_KEY, M_COUNT

  *  Filter out -- AUX_MAS.DBF  *
  * CREATE A TEMPORARY FILE NAME in F_TEMP

  select AUX_MAS
  replace all FLAG with space(1)

  F_TEMP = sys(3)
  M_FIRST = .T.
  M_COUNT="1"
  for M_I = 1 to 8    && incrementally mark records
    if .not. empty(SEL_STR[M_I])
      select AUX_MAS
      set order to 0

      set talk on
      select MAS_CODE from AUX_MAS ;
             where &SEL_STR[M_I] and MAS_CODE > 0 ;
             into cursor &F_TEMP
      set talk off

      select AUX_MAS
      set order to tag MAS_CODE

      * Mark records selected in AUX_MAS
      if M_FIRST
        select (F_TEMP)
        scan
          M_KEY=MAS_CODE
          select AUX_MAS
          seek M_KEY
          replace FLAG with M_COUNT
        endscan
        M_FIRST=.f.
      else
        select (F_TEMP)
        scan
          M_KEY=MAS_CODE
          select AUX_MAS
          seek M_KEY
          if found() and .not.empty(FLAG)
            replace FLAG with M_COUNT
          endif
        endscan
      endif

      select AUX_MAS
      M_COUNT=iif(M_COUNT="1","2","1")
      replace all FLAG with space(1) for FLAG=M_COUNT
    endif
  endfor
return
