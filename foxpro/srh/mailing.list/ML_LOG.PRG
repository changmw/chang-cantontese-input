*
* Activity Logging facility for SRHIS-ML.
*
  SET COLOR TO N/W,W+/N
  DEFINE POPUP W_ACTLOG FROM 10,35 SHADOW
  DEFINE BAR 1 OF W_ACTLOG PROMPT 'VIEW ACTIVITY LOG'
  DEFINE BAR 2 OF W_ACTLOG PROMPT 'PRINT ACTIVITY LOG'
  DEFINE BAR 3 OF W_ACTLOG PROMPT 'DELETE RECORDS'
  ON SELECTION POPUP W_ACTLOG DO PU_SYS WITH BAR()

  ACTIVATE POPUP W_ACTLOG

  RELEASE POPUP W_ACTLOG
RETURN

PROCEDURE PU_SYS
  PARAMETER M_BAR

  DO CASE
    CASE M_BAR=1
      DO VIEWLOG
    CASE M_BAR=2
      DO PRINTLOG
    CASE M_BAR=3
      DO DELLOG
  ENDCASE
RETURN

* Input parameters:
*    M_DATE         : date of log entry
*    M_USERID       : user login id
*    M_ACTION       : action performed
*    M_DBF          : database which receive the action
*    M_TEXT         : descriptive text
*                     eg the value of the key changed/added/deleted
*
procedure ENTERLOG
  parameters M_DATE, M_USERID, M_ACTION, M_DBF, M_TEXT
  private M_AREA

  M_AREA = select()
  select 0
  use &ML_PATH.ML_LOG alias ACTLOG
  if used("ACTLOG")
    append blank
    replace DATE with M_DATE, USERID with M_USERID, ;
            ACTION with M_ACTION, ;
            DBF with M_DBF, TEXT with M_TEXT
    use in ACTLOG
  endif
  select (M_AREA)
return

procedure VIEWLOG
  define window W_VLOG from 04,01 to 23,78 shadow ;
         COLOR W/N,N/W,N/W,N/W,W/N,N/W,N/W,N/N,N/W,W/N,N/W
  select 0
  use &ML_PATH.ML_LOG alias ACTLOG
  if used("ACTLOG")
    set order to tag DATE descending
    go top
    browse fields DATE:h="DATE", ;
                  USERID:h="USER ID", ;
                  ACTION:h="ACTION", ;
                  DBF:h="DATA FILE", ;
                  TEXT:h="REMARKS" ;
           noappend nomodify nodelete ;
           window W_VLOG title "ACTIVITY LOG"
    use in ACTLOG
  else
    =ERRMSG("ACTIVITY LOG FILE IN USE. TRY LATER!")
  endif
  release window W_VLOG
return

procedure PRINTLOG
  private M_BEGIN, M_END, M_DEVICE

  select 0
  use &ML_PATH.ML_LOG alias ACTLOG
  if used("ACTLOG")
    define window W_PRINTLOG from 06,15 to 15,65 ;
                  shadow color g/n,,rg+/n,rg+/n title " PRINT LOG "
    activate window W_PRINTLOG

    M_BEGIN  = ctod('')
    M_END    = date()
    M_DEVICE = padr("LOG",8)

    @ 00,05 say "Specify date range of log:"
    @ row()+2,05 say "Starting Date: " get M_BEGIN
    @ row()+1,05 say "Ending Date:   " get M_END
    @ row()+1,05 say "Output Device: " get M_DEVICE
    @ row()+1,05 say "(Enter 'PRN' to output to printer)"
    @ row()+1,05 say "(Or a filename to output to text file)"
    read cycle

    if lastkey()#K_ESC
      if M_DEVICE="PRN"
        set device to print
        set console off
      else
        set alternate to &M_DEVICE
        set alternate on
        set console off
      endif

      select ACTLOG
      set order to tag DATE descending
      if .not.empty(M_BEGIN)
        locate for DATE >= M_BEGIN
      endif
      scan rest
        ? dtoc(DATE)+space(1)+;
          USERID+space(1)+;
          ACTION+space(1)+;
          DBF+space(1)+;
          TEXT
        if .not.empty(M_END) and DATE > M_END
          exit
        endif
      endscan

      if M_DEVICE="PRN"
        set device to screen
        set console on
      else
        set alternate off
        set alternate to
        set console on
      endif
    endif

    release window W_PRINTLOG
    use in ACTLOG
  else
    =ERRMSG("ACTIVITY LOG FILE IN USE. TRY LATER!")
  endif
return

procedure DELLOG
  private M_BEGIN, M_END, M_DEVICE

  select 0
  use &ML_PATH.ML_LOG alias ACTLOG
  if used("ACTLOG")
    define window W_DEL_LOG from 06,20 to 15,60 ;
           shadow color g/n,,rg+/n,rg+/n title "DELETE LOG ENTRIES"
    activate window W_DEL_LOG

    M_BEGIN  = ctod('')
    M_END    = ctod('')

    @ 01,05 say "Enter date range of log to delete:"
    @ row()+2,05 say "Starting Date: " get M_BEGIN
    @ row()+1,05 say "Ending Date:   " get M_END
    read cycle

    if lastkey()#K_ESC
      if "Y"=askyn("CONFIRM DELETION?")
        select ACTLOG
        delete all for (DATE >= M_BEGIN) and (DATE <= M_END)
      endif
    endif

    release window W_DEL_LOG
    use in ACTLOG
  else
    =ERRMSG("ACTIVITY LOG FILE IN USE. TRY LATER!")
  endif
return
