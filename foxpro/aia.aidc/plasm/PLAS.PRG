function G_MTCHRSLT
parameter m_code
private m_s
  m_s = 'Unexpected Error!'
  do case
    case m_code = 'P'
      m_s = 'Policy paid already!'
    case m_code = 'R'
      m_s = 'Not relevant!'
    case m_code = 'U'
      m_s = 'Not in policy master!'
    case m_code = 'I'
      m_s = 'Insuffcient Payment!'
    case m_code = 'E'
      m_s = 'No Day-End Action!'
    case m_code = 'Z'
      m_s = 'Zero payment amount!'
    case empty(m_code)
      m_s = 'OK'
    otherwise
      m_s = 'Unexpected error!'
  endcase
return padr(m_s,25)

function G_AGTLVL
parameter m_code
return space(1)
function G_COMPANY
parameter M_COMPID
private   M_S, M_AREA
  m_area=select()
  m_s = space(1)
  do case
    case m_compid = '011'
      m_s = 'SINGAPORE'
    case m_compid = '041'
      m_s = 'HONGKONG'
    case m_compid = '016'
      m_s = 'MALAYSIA'
    case m_compid = '014'
      m_s = 'BRUNEI'
  endcase
  select (m_area)
return M_S


function MMDDYY
parameter m_date
private m_s
  m_s = dtos(m_date)
return substr(m_s,5,2)+right(m_s,2)+substr(m_s,3,2)


function ADDSLASH
parameter m_path
if right(m_path,1)!='\'
  return m_path+'\'
endif
return m_path


function REVERSE
paramete m_in
private i, m_out
  m_out = right(m_in,1)
  for i = len(m_in)-1 to 1 step -1
    m_out=m_out+substr(m_in,i,1)
  endfor
return m_out


function AMT2STR
parameter m.inamt, m_length, m_dec
private m_s, m_a, m_b
  m_s=str(m.inamt,15,4)
  m_a=alltrim(left(m_s,10))
  m_b=right(m_s,4)
return padl(m_a,m_length,'0')+;
       left(m_b,m_dec)


function STR2AMT
parameter m.instr, m_dec
private m_str
  if parameter() = 1
    m_dec = 2
  endif
  m_str = left(m.instr,len(m.instr)-m_dec)+'.'+right(m.instr,m_dec)
return val(m_str)


function WEEKNO
parameter m_date
private m_year,m_month,m_day,m_cur,m_stdate,m_stcent

  m_stdate = sys(2001,'date')
  m_stcent = sys(2001,'century')
  set date ansi
  set century on

  m_year = year(m_date)
  m_month= month(m_date)
  m_day  = day(m_date)
  m_cur  = 0
  for i = 1 to m_month-1
    do case
      case i=2
        m_cur=m_cur+iif(m_year%4=0,29,28)
      case i=1 or i=3 or i=5 or i=7 or i=8 or i=10 or i=12
        m_cur=m_cur+31
      case i=4 or i=6 or i=9 or i=11
        m_cur=m_cur+30
    endcase
  endfor
  m_cur=m_cur + m_day + dow(ctod(str(m_year,4,0)+'.01.01'))-1

  set date &m_stdate
  set century &m_stcent
return int(m_cur/7)+1


*
* input parameter in date format
* outpout parameter string format date eg Nov 1, 1993
*
function CHR_DATE
parameter m_date
private m_s
return upper(left(cmonth(m_date),3)) + ' ' +;
       ltrim(str(day(m_date),2,0)) + ', ' +;
       str(year(m_date),4,0)

* get name of financial institute
function G_FINNAME
parameter m_code
private M_AREA, M_NAME
  m_area = select()
  select FININST
  m_name = lookup(FIN_NAME,M_CODE,FIN_NO,'FIN_NO')
  select (M_AREA)
return m_name


* get agent name
function G_AGENT
parameter M_AGTNO
private M_AREA, M_NAME
  m_area = select()
  select AATAB
  M_NAME = lookup(AGT_NAME,M_AGTNO,POL_AGENT)
  select (m_area)
return M_NAME


* get name of agency
function G_AGENCY
parameter M_AGYNO
private M_AREA, M_NAME
  m_area = select()
  select AATAB
  m_name = lookup(AGY_NAME,M_AGYNO,POL_AGENCY)
  select (M_AREA)
return M_NAME


*
* The following five functions convert time from military to civilian format
* 24 hours will be passed into or returned as character string
* 12 hours minute and hour hands will be expressed as numeric while
* 'AM' and 'PM' will be expressed as strings.
*
function TM_12TO24
parameter m.hour, m.minute, m.am_pm
private m.time24
  if upper(m.am_pm) = 'AM'
    m.time24 = amt2str(m.hour,2,0)+amt2str(m.minute,2,0)
  else
    m.time24 = amt2str(m.hour+12,2,0)+amt2str(m.minute,2,0)
    if left(m.time24,2)='24'
      m.time24 = '00'+right(m.time24,2)
    endif
  endif
return m.time24

function TM_24TO12
parameter m.time24
return amt2str(hour12(m.time24),2,0)+':'+;
       amt2str(minute12(m.time24),2,0)+ampm(m.time24)

function HOUR12
parameter m.time24
private m.hour
  m.hour = val(left(m.time24,2))
  if m.hour = 0
    m.hour = 12
  endif
  if m.hour > 12
    m.hour = m.hour-12
  endif
return m.hour

function MINUTE12
parameter m.time24
return val(right(m.time24,2))

function AMPM
parameter m.time24
private m.hour, m.minute
  m.hour   = val(left(m.time24,2))
  m.minute = val(right(m.time24,2))
  if (m.hour >= 0) and (m.hour < 12)
    return 'AM'
  endif
return 'PM'

*
* ACTTHERM(<text>) - Activate thermometer.
*
* adapted from GENSCRN.PRG of FoxPro/LAN by Janathan Tam
*
* Activates thermometer.  Update the thermometer with UPDTHERM().
* Thermometer window is named "thermometer."  Be sure to RELEASE
* this window when done with thermometer.
* Creates the global m.g_thermwidth.
*
*!*****************************************************************************
*!
*!      Procedure: ACTTHERM
*!
*!*****************************************************************************
PROCEDURE acttherm
PARAMETER m.text
PRIVATE m.prompt

m.g_graphic = .t.
m.g_outfile = 'Processing'
c_dlgface  = 'Arial'
c_dlgsize  = 10
c_dlgstyle = 'BI'

IF m.g_graphic
   m.prompt = LOWER(m.g_outfile)
   IF TXTWIDTH(m.prompt, c_dlgface, c_dlgsize, c_dlgstyle) > 43
      DO WHILE TXTWIDTH(m.prompt+"...", c_dlgface, c_dlgsize, c_dlgstyle) > 43
         m.prompt = LEFT(m.prompt, LEN(m.prompt)-1)
      ENDDO
      m.prompt = m.prompt + "..."
   ENDIF

   DEFINE WINDOW W_METER ;
      AT  INT((SROW() - (( 5.615 * ;
      FONTMETRIC(1, c_dlgface, c_dlgsize, c_dlgstyle )) / ;
      FONTMETRIC(1, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2), ;
      INT((SCOL() - (( 63.833 * ;
      FONTMETRIC(6, c_dlgface, c_dlgsize, c_dlgstyle )) / ;
      FONTMETRIC(6, WFONT(1,""), WFONT( 2,""), WFONT(3,"")))) / 2) ;
      SIZE 5.615,63.833 ;
      FONT c_dlgface, c_dlgsize ;
      STYLE c_dlgstyle ;
      NOFLOAT ;
      NOCLOSE ;
      NONE ;
      COLOR RGB(0, 0, 0, 192, 192, 192)
   MOVE WINDOW W_METER CENTER
   ACTIVATE WINDOW W_METER NOSHOW

   @ 0.5,3 SAY m.text FONT c_dlgface, c_dlgsize STYLE c_dlgstyle
   @ 1.5,3 SAY m.prompt FONT c_dlgface, c_dlgsize STYLE c_dlgstyle
   @ 0.000,0.000 TO 0.000,63.833 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 0.000,0.000 TO 5.615,0.000 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 0.385,0.667 TO 5.231,0.667 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 0.308,0.667 TO 0.308,63.167 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 0.385,63.000 TO 5.308,63.000 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 5.231,0.667 TO 5.231,63.167 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 5.538,0.000 TO 5.538,63.833 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 0.000,63.667 TO 5.615,63.667 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 3.000,3.333 TO 4.231,3.333 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 3.000,60.333 TO 4.308,60.333 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   @ 3.000,3.333 TO 3.000,60.333 ;
      COLOR RGB(128, 128, 128, 128, 128, 128)
   @ 4.231,3.333 TO 4.231,60.500 ;
      COLOR RGB(255, 255, 255, 255, 255, 255)
   m.g_thermwidth = 56.269

   SHOW WINDOW W_METER TOP
ELSE
   m.prompt = SUBSTR(SYS(2014,m.g_outfile),1,48)+;
      IIF(LEN(m.g_outfile)>48,"...","")

   DEFINE WINDOW W_METER;
      FROM INT((SROW()-6)/2), INT((SCOL()-57)/2) ;
      TO INT((SROW()-6)/2) + 6, INT((SCOL()-57)/2) + 57;
      DOUBLE COLOR SCHEME 5
   ACTIVATE WINDOW W_METER NOSHOW
   m.g_thermwidth = 50
   @ 0,3 SAY m.text
   @ 1,3 SAY UPPER(m.prompt)
   @ 2,1 TO 4,m.g_thermwidth+4 &g_boxstrg
   SHOW WINDOW W_METER TOP
ENDIF
RETURN

*
* UPDTHERM(<percent>) - Update thermometer.
*
*!*****************************************************************************
*!
*!      Procedure: UPDTHERM
*!
*!*****************************************************************************
PROCEDURE updtherm
PARAMETER m.percent
PRIVATE m.nblocks
m.g_graphic = .t.

ACTIVATE WINDOW W_METER

* Map to the number of platforms we are generating for
m.percent = MIN(m.percent, 100)

m.nblocks = (m.percent/100) * (m.g_thermwidth)
IF m.g_graphic
   @ 3.000,3.333 TO 4.231,m.nblocks + 3.333 ;
      PATTERN 1 COLOR RGB(128, 128, 128, 128, 128, 128)
ELSE
   @ 3,3 SAY REPLICATE("Û",m.nblocks)
ENDIF
RETURN

*
* DEACTTHERMO - Deactivate and Release thermometer window.
*
*!*****************************************************************************
*!
*!      Procedure: DEACTTHERMO
*!
*!*****************************************************************************
procedure DEACTTHERMO
IF WEXIST("W_METER")
   RELEASE WINDOW W_METER
ENDIF
RETURN

function G_COLLECT
parameter m_company, m_branch
private m_s
  do case
    case m_company = '041'
      if m_branch = '49'
        m_s = '049'
      else
        m_s = '062'
      endif
    case m_company = '041'
      m_s = '062'
    case M_COMPANY = '011'
      m_s = '051'
    case M_COMPANY = '016'
      m_s = '055'
    otherwise
      m_s = space(3)
  endcase
return m_s


function INIT_SETS
  set intensity on
  set delimited off

  set deleted on
  set unique off
  set exact on

  set debug off
  set help off
*  set development off

  set bell to 2050,2
  set notify off
  set century off
  set talk off
  set echo off
  set date american
  set escape off
  set safety off

  set reprocess to 30
  set exclusive off
  set multilock off
  set udfparms to reference
  set readborder on
return

function REST_SETS
  set debug off
*  set development on
  set help on
  set delimiter off
  set intensity off
  set deleted off
  set bell on
  set notify on
  set talk on
  set escape on
  set safety on
  set exclusive on
  set reprocess to automatic
  set udfparms to value
  set century off
  set talk on
  set readborder off
return


procedure ERRPROC
*
* general program error trap for PLAS
* CopyRight, Chang Man Wai, 1993.
*
* Parameters:
*       P_ERRNO  FoxPro internal error number
*       P_MSG1  FoxPro Error message line 1
*       P_MSG2  FoxPro Error message line 2
*       P_PROG  Offending program
*       P_LINENO Line number of the offending instruction
*
parameter P_ERRNO, P_MSG1, P_MSG2, P_PROG, P_LINENO
  do case
    case P_ERRNO=20     && record is not in index (file locked)
    case P_ERRNO=1683
    case P_ERRNO=26     && database in not ordered
      set fullpath off
      wait "Please re-indexe "+dbf() window timeout 1
      set fullpath on
    case P_ERRNO=42     && CONTINUE without LOCATE
    case P_ERRNO=109    && Record exclusively used by another
    case P_ERRNO=114    && index damaged
      set fullpath off
      wait "Index of "+dbf()+" damaged. Please rebuild it!" window timeout 1
      set fullpath on
    case P_ERRNO=130    && Record exclusively used by another
    case P_ERRNO=108    && File exclusively use by another
    case P_ERRNO=1707   && Structural index not found
      set fullpath off
      wait "Please re-indexe "+dbf() window timeout 1
      set fullpath on
    case P_ERRNO=125    && Printer Not Ready
      do while !printstatus()
        wait 'Check Printer Connection' window
      enddo
    otherwise
      on error
      set device to screen
      set console on
      set alternate off
      if _DOS
        define window W_ALERT from 03,05 to 23,75 ;
            shadow title " PLEASE COPY THE ERROR MESSAGE AND REPORT IT " ;
            color w+/r,w+/r,w+/r,w+/r,w+/r
        move window W_ALERT center
        activate window W_ALERT
      endif
      if _WINDOWS
        define window W_ALERT from 03,05 to 23,75 ;
            shadow title " PLEASE COPY THE ERROR MESSAGE AND REPORT IT " ;
            color w+/r,w+/r,w+/r,w+/r,w+/r font 'Courier',10
        move window W_ALERT center
        activate window W_ALERT
      endif
      =writelog('ERR '+transform(P_ERRNO,'9999') + ;
       ' at LINE '+transform(P_LINENO,'99999') + ;
       ' of procedure '+P_PROG ;
      )
      @ 00,     05 say "ERROR NUMBER: "+transform(P_ERRNO,'9999')
      @ row()+1,05 say left(P_MSG1,70)
      @ row()+1,05 say left(P_MSG2,70)
      @ row()+2,05 say "PROGRAM NAME: "+P_PROG
      @ row()+1,05 say "LINE NUMBER:  "+transform(P_LINENO,'99999')
      @ wrow()-1,00 say 'Press <ENTER> to quit --> '
      =inkey(0)
      pop menu _MSYSMENU
      clear read all
      on key label enter
      on key label del
      on key label ins
      on key label esc
      close databases
      set escape on
      set proc to
      set path to
      set escape on
      set sysmenu to defa
      set procedure to
      cancel
  endcase
return

function WRITELOG
  parameter M_ACTION, M_LEVEL
  push key clear
  private M_AREA

  if parameters() = 1
    M_LEVEL = 0
  endif

  M_AREA = select()
  if !file('LOG.DBF')
    wait 'Creating log file ...' window nowait
    create table LOG ( ;
      DATE D,          ;
      TIME C(8),       ;
      ACTION C(50)     ;
    )
  else
    select 0
    use LOG share
  endif
  if used('LOG')
    insert into LOG (  ;
      date,            ;
      time,            ;
      action           ;
    ) values (         ;
      date(),          ;
      time(),          ;
      space(M_LEVEL*2)+M_ACTION ;
    )
    use
  else
    wait 'Cannot write log file!!!!' window nowait
  endif
  select (M_AREA)
  pop key
return .t.

procedure DELBATCH
parameter M_PREFIX
  private m_count, i
  declare a_fname[1]

  * delete old set of files
  m_count = adir(a_fname, M_PREFIX+'*.TXT')
  if m_count > 0
    for i = 1 to m_count
      m_file = a_fname[1,1]
      =WRITELOG('Delete '+M_FILE,2)
      delete file (m_file)
      if file(m_file)
        =WRITELOG('Cannot delete '+M_FILE,3)
        wait 'Cannot delete '+M_FILE window
      endif
    endfor
  endif
return m_count

procedure UL_BATCH
parameter M_PREFIX
  private m_count, m_file, i, m_k
  declare a_fname[1]

  m_k = 'GH'
  if m_prefix = 'AM'
    m_k = 'GM'
  endif
  m_count = adir(a_fname, M_PREFIX+'*.TXT')
  if m_count > 0
    for i = 1 to m_count
      m_file = a_fname[1,1]
      =WRITELOG('Upload '+m_file,2)
      do FILEXFER with 'UACC', m_file, m_k
    endfor
  endif
return m_count

procedure KEYCODE
  *
  * procedure KEYCODE
  *
  * Written: Chang Man Wai
  *
  * inkey() and readkey() return codes
  *
  * variables naming conventions (follow Clipper 5.01's INKEY.CH)
  *
  * K_<key>             the <key> alone
  * K_C_<key>           CTRL + <key>
  * K_A_<key>           ALT + <key>
  * K_S_<key>           SHIFT + <key>
  *
  public K_ESC, K_ENTER, K_SPACE, ;
         K_PGUP, K_PGDN, K_UP, K_DOWN, K_LEFT, K_RIGHT, K_HOME, K_END, ;
         K_C_W, ;
         K_F1, K_F2, K_F3, K_F5, K_F10, ;
         K_BS, K_INS, K_DEL

  K_ESC   = 27
  K_BS    = 127
  K_SPACE = 32

  K_PGUP  = 18
  K_PGDN  = 3
  K_HOME  = 1
  K_END   = 6

  K_LEFT  = 19
  K_RIGHT = 4
  K_DOWN  = 24
  K_UP    = 5

  K_ENTER = 13
  K_INS   = 22
  K_DEL   = 7

  K_F1    = 28
  K_F2    = -1
  K_F3    = -2
  K_F4    = -3
  K_F5    = -4
  K_F10   = -9

  K_C_W   = 23
return

procedure VW_LOG
  set sysmenu off
  if file('LOG.DBF')
    select 0
    use LOG alias LOG
    if used('LOG')
      browse fields ;
           LOG.DATE  :h='Date', ;
           LOG.TIME  :h='Time', ;
           LOG.ACTION:h='Activity' ;
           nomodify noappend nodelete ;
           font 'Courier',10

      if S_WARN('Purge log entries that are 1 week old?')
        select LOG
        if flock()
          delete for date()-LOG.DATE > 7
        endif
      endif
    else
      wait 'Log file in use. Try later!' window
    endif
    close databases
  else
    wait 'No activity logged!!' window
  endif
  set sysmenu on
return

function MK_DIGIT
parameter I_PNO
*
* FUNCTION:     Create the check digit of a policy number.
*               The digits in policy number can never be zero.
* ADAPTED FROM: A+PLUS's program
*
private M.SUMVAL
  M.SUMVAL = val(substr(I_PNO,1,1))*3 +;
             val(substr(I_PNO,2,1))*7 +;
             val(substr(I_PNO,3,1)) +;
             val(substr(I_PNO,4,1))*3 +;
             val(substr(I_PNO,5,1))*7 +;
             val(substr(I_PNO,6,1)) +;
             val(substr(I_PNO,7,1))*3 +;
             val(substr(I_PNO,8,1))*7
  M.RESULT = 10 - mod(M.SUMVAL, 10)
  if M.RESULT = 10
     M.RESULT = 0
  endif
return str(M.RESULT, 1)

function ALLDIGIT
parameter I_PNO
private M.POINTER
  * check if every characters are digits
  for M.POINTER=1 to len(I_PNO)
     if asc(substr(I_PNO, M.POINTER, 1)) < asc('0') .or.;
        asc(substr(I_PNO, M.POINTER, 1)) > asc('9')
        return .f.
     endif
  endfor
return .t.

function mmmddyy
parameter m_date
private m_mm, m_yy, m_dd
  m_yy = alltrim(str(year(m_date),4,0))
  m_mm = left(cmonth(m_date),3)
  m_dd = alltrim(str(day(m_date),2,0))
return m_mm+space(1)+m_dd+', '+m_yy
