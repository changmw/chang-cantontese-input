*
* MAIN PROGRAM FOR GINUS -- MOTOR INSURANCE
*
* written by Chang Man Wai, Oct 1993 till
* Copyright AIDCHK, 1993.
*
  push key clear

  set sysmenu to default
  clear all

  private m_temp

  m_temp = curdir()

  set default to (m_temp)
  set procedure to PLAS

  * coverage type code to be used in PIAM file generation
  * and month-end reinsurance
  public CV_WNDSCRN, CV_CMPRHNV, CV_THRDPTY, CV_LIBPSGR, ;
         CV_FITING1, CV_FITING2

  CV_WNDSCRN = '000100000004'
  CV_CMPRHNV = '000100000001'
  CV_THRDPTY = '000100000002'
  CV_LIBPSGR = '000100000008'
  CV_FITING1 = '000100000011'
  CV_FITING2 = '000100000012'

  public GM_PATH, GMP_PATH, GM_DPATH, ;
         HOST_DPATH, PIAM_DPATH, BMP_PATH, BAK_PATH
  public U_NAME, U_LEVEL
  public SYS_DATE, SYS_DEBUG, SYS_HIDEMNU, SYS_ACTION, SYS_VERSION
  public GM_BP, GM_TAXRATE, GM_STAMP, GM_CRRNCY, GM_COMPCODE
  public GM_LENYR, GM_LENMN, GM_LENWK
  public sys_diff

  =INIT_SETS()           && initialize the sexy of motor insurance

  SYS_VERSION="MAL-MOTOR-U5.3"

  SYS_DEBUG = file('DEMO.$$$')
  if SYS_DEBUG
    ?? chr(7)
    wait 'System running in evaluation mode!' window
  else
    ** on shutdown wait 'You cannot go away this way!' window
    on error do ERRPROC with error(), message(), message(1), program(), lineno()
    wait 'Loading program ...' nowait window
  endif

  * shared directory
  GMP_PATH = getenv('PLAS')
  if empty(GMP_PATH) or SYS_DEBUG
    GMP_PATH = 'C:\PLAS\'
  endif
  GMP_PATH=ADDSLASH(GMP_PATH)

  * program directory for Motor
  GM_PATH  = getenv('PLASM')
  if empty(GM_PATH) or SYS_DEBUG
    GM_PATH = 'C:\PLASM\'
  endif
  GM_PATH=ADDSLASH(GM_PATH)

  BMP_PATH   = GMP_PATH+'BITMAP\'
  GM_DPATH   = GM_PATH+'DATA\'
  HOST_DPATH = GM_PATH+'HOST\'
  PIAM_DPATH = GM_PATH+'PIAM\'
  BAK_PATH   = GM_PATH+'BACKUP\'

  private m_temp
  m_temp = BMP_PATH+';'+GM_PATH
  set path to &m_temp.

  SYS_DATE = date()     && system date
  SYS_ACTION = space(1)

  GM_LENYR = 365        && length of one year (days)
  GM_LENMN = 30         && length of one month (days)
  GM_LENWK = 7          && length of one week (days)

  GM_BP    = 26.00      && increments for basic premium
  GM_STAMP = 2          && stamp duty
  sys_diff = 1          && adjustment in date calculation

  =PLASWALL(SYS_VERSION)
  =KEYCODE()            && define keyboard codes (in MYLIB.APP)

  set color to
  define popup MPD_PIAM margin shadow
  define bar 1 of MPD_PIAM prompt "Export \<Policies"
  define bar 2 of MPD_PIAM prompt "Export Claims \<Information" skip for .t.
  define bar 3 of MPD_PIAM prompt "Export Claims \<Outstanding" skip for .t.
  define bar 4 of MPD_PIAM prompt "Export \<All Three" skip for .t.
  on selection popup MPD_PIAM do MPDF_PIAM with bar()

  define popup MPD_APPL margin shadow
  define bar 1 of MPD_APPL prompt "\<Contract Maintenance"

  define popup MPD_PROC margin shadow
  define bar 1 of MPD_PROC prompt "\<Day End Process"
  define bar 2 of MPD_PROC prompt "\<Month End Process"
  define bar 3 of MPD_PROC prompt "\<AA Master Update"
  on selection popup MPD_PROC do MPDF_PROC with bar()

  define popup MPD_CODE margin shadow
  define bar  1 of MPD_CODE prompt "Vehicle Class" skip for .t.
  define bar  2 of MPD_CODE prompt "Vehicle Usage" skip for .t.
  define bar  3 of MPD_CODE prompt "Vheicle Capacity" skip for .t.
  define bar  4 of MPD_CODE prompt "Vheicle Type" skip for .t.
  define bar  5 of MPD_CODE prompt "Occupation Codes" skip for .t.
  define bar  6 of MPD_CODE prompt "Driver Characteristics" skip for .t.
  define bar  7 of MPD_CODE prompt "Insurer List" skip for .t.
  define bar  8 of MPD_CODE prompt "Nature of Endorsement" skip for .t.
  define bar  9 of MPD_CODE prompt "Nature of Loss" skip for .t.
  define bar 10 of MPD_CODE prompt "NCD Allowed Code" skip for .t.

  define popup MPD_AIA margin shadow
  define bar 1 of MPD_AIA prompt "Occupation codes" skip for .t.
  define bar 2 of MPD_AIA prompt "Schedule of Premium" skip for .t.
  define bar 3 of MPD_AIA prompt "Additonal Benefits" skip for .t.
  define bar 4 of MPD_AIA prompt "Financial Institutes" skip for .t.
  define bar 5 of MPD_AIA prompt "Endorsement forms" skip for .t.
  define bar 6 of MPD_AIA prompt "Product Codes" skip for .t.
  define bar 7 of MPD_AIA prompt "Agency/Agent Codes" skip for .t.
  define bar 8 of MPD_AIA prompt "Vehicle Maker" skip for .t.

  define popup MPD_HSKP margin shadow
  define bar 1 of MPD_HSKP prompt "\<Reindex Databases"
  define bar 2 of MPD_HSKP prompt "\<Pack Databases"
  define bar 3 of MPD_HSKP prompt "\<Change Passwords" skip for .t.
  define bar 4 of MPD_HSKP prompt "\<System Profile"
  define bar 5 of MPD_HSKP prompt "\<PIAM Code Maintenance"
  define bar 6 of MPD_HSKP prompt "\<AIA Code Maintenance"
  define bar 7 of MPD_HSKP prompt "\<View Activity Log"
  define bar 8 of MPD_HSKP prompt "\<Backup Data"
  define bar 9 of MPD_HSKP prompt "\<Restore Data"
  define bar 10 of MPD_HSKP prompt "\<File Transfer Parameters"
  on selection popup MPD_HSKP do MPDF_HSKP with bar()
  on bar 5 of MPD_HSKP activate popup MPD_CODE
  on bar 6 of MPD_HSKP activate popup MPD_AIA

*  define popup MPD_HOST margin shadow
*  define bar 2 of MPD_HOST prompt "\<Refresh AA Master"
*  define bar 3 of MPD_HOST prompt "Download \<Suspense Accounts"
*  define bar 4 of MPD_HOST prompt "Account \<Matching"
*  define bar 5 of MPD_HOST prompt "\<Reinsurance"
*  define bar 6 of MPD_HOST prompt "Upload Accounting \<Vcouher"
*  on selection popup MPD_HOST do MPDF_HOST with bar()

  SYS_HIDEMNU=.f.
  U_LEVEL = space(1)
  U_NAME = space(1)

  set sysmenu to
  set sysmenu automatic
  define pad APPSLIST of _MSYSMENU prompt "\<Contract Maintenance" ;
         KEY ALT-C, "ALT+C" ;
         skip for SYS_HIDEMNU
  define pad PROCESS of _MSYSMENU prompt "\<Process" ;
         KEY ALT-P, "ALT+P" ;
         skip for SYS_HIDEMNU
  define pad PIAMLINK of _MSYSMENU prompt "P\<IAM Link" ;
         KEY ALT-I, "ALT+I" ;
         skip for SYS_HIDEMNU or U_LEVEL = 'U'
  define pad HOUSKEEP of _MSYSMENU prompt "\<Supervisory" ;
         KEY ALT-S, "ALT+S" ;
         skip for SYS_HIDEMNU or U_LEVEL = 'U'
  define pad QUIT     of _MSYSMENU prompt "E\<xit" ;
         KEY ALT-X, "ALT+X" ;
         skip for SYS_HIDEMNU
  on selection menu _MSYSMENU do MNUF_MAIN with pad()
  on pad PROCESS  of _MSYSMENU activate popup MPD_PROC
  on pad PIAMLINK of _MSYSMENU activate popup MPD_PIAM
  on pad HOUSKEEP of _MSYSMENU activate popup MPD_HSKP

  private m_shutdown, m_quit
  
  if LD_PROFI()          && load system profile
    wait clear
    set sysmenu off
    do while login(U_NAME, U_LEVEL)
      set sysmenu on
      activate menu _MSYSMENU nowait
      m_shutdown = .f.
      read valid m_shutdown
      set sysmenu off
      if SYS_DEBUG
        exit
      endif
    enddo
  endif

  set sysmenu to default
  set sysmenu automatic

  if !SYS_DEBUG
    on error
    clear all
    clear
  endif

  =REST_SETS()
  set path to
  set procedure to
  pop key
return

procedure MNUF_MAIN
parameter M.PAD
  do case
    case M.PAD = 'APPSLIST'
      do GM_ENQ
    case M.PAD = 'QUIT'
      keyboard chr(K_ESC)
      m_shutdown = .t.
      clear read
  endcase
return

procedure MPDF_HOST
parameter M_BAR
  do case
    case M_BAR = 1
      if S_AADOWN(GM_COMPCODE)
        if HST_OPEN()
          wait 'Download AA.TXT from host ...' window nowait

          =WRITELOG('*** Download AA.TXT',0)
          M.FILE = HOST_DPATH+'AA.TXT'
          do FILEXFER with 'DAGT', M.FILE, 'GM'

          if HST_AA(M.FILE)
            wait 'AA Master updated!' window
          else
            wait 'AA Master not updated!' window
          endif
        endif
      endif
    case M_BAR = 3
      if HST_OPEN()
        wait 'Download LIFECOMM suspense file ...' window nowait
        =WRITELOG('*** Download ACC.TXT',0)
        M.FILE = HOST_DPATH+'ACC.TXT'
        do FILEXFER with 'DSSP', M.FILE, 'GM'
      endif
    case M_BAR = 4
      if HST_OPEN()
        if S_WARN('Delete previous set of transaction batches?')
            =DELBATCH('AM')
        endif
        M.FILE = HOST_DPATH+'ACC.TXT'
        if HST_SUSP(m.file, 'M')
          wait 'Account Matching ...' window nowait
          if HST_ACC(.t., .f.)
            wait 'Printing accounting reports ...' window nowait
            do ACCT_RPT
          endif
        else
          wait 'Suspense control file not available' window
        endif
      endif
    case M_BAR = 5
      if HST_OPEN()
        if S_WARN('Delete previous set of transaction batches?')
            =DELBATCH('AM')
        endif
        wait 'Re-insure ...' window nowait
        if HST_ACC(.f., .t.)
          * move all reinsured entries to a backup file
          select BATCTRL
          locate for BAT_PREFIX='AM'
          m_s = dtos(BATCTRL.BAT_DATE)
          m_file = HOST_DPATH+'ZU'+right(m_s,6)

          =WRITELOG('Move ZUSRCOMP.DBF to '+M_FILE,2)
          select ZUSRCOMP
          copy to (m_file)
          zap
        endif
      endif
    case M_BAR = 6
      if HST_OPEN()
        wait 'Upload accounting vouchers ...' window nowait
        if UL_BATCH('AM')=0
          wait 'no file uploaded!' window
          if S_WARN('Delete transaction batches just uploaded?')
            =DELBATCH('AM')
          endif
        endif
      endif
  endcase
  close databases
return

procedure MPDF_PROC
parameter M.BAR
private PP_MONTH

  PP_MONTH=month(date())-1
  if PP_MONTH=0
    PP_MONTH=12
  endif

  set sysmenu off
  do case
    case M.BAR = 1
      do S_DAYEND
    case M.BAR = 2
      do S_MTHEND
    case M.BAR = 3
      do MPDF_HOST with 1
  endcase
  set sysmenu on
return

procedure MPDF_PIAM
parameter M_BAR
private m.piam_comp, m.comp_name, m.piam_date, m.outpath
  set sysmenu off
  select 0
  use &GM_DPATH.GM_PROFI alias PROFILE
  if not used('PROFILE')
    wait 'Cannot open profile. Try later!' window nowait
    close databases
    return .f.
  endif

  select 0
  use &GM_DPATH.GM_PLCY alias POLICY exclusive
  if not used('POLICY') and flock()
    wait 'Policy file in use. Try later!' window nowait
    close databases
    return .f.
  endif

  select 0
  use &GM_DPATH.VEHICLE alias VEHICLE
  if not used('VEHICLE')
    wait 'Cannot open policy file. Try later!' window nowait
    close databases
    return .f.
  endif

  select 0
  use &GM_DPATH.PERSON alias PERSON
  if not used('PERSON')
    wait 'Cannot open person file. Try later!' window nowait
    close databases
    return .f.
  endif

  select 0
  use &PIAM_DPATH.PM_VH_CL alias PM_VH_CL
  if not used('PM_VH_CL')
    wait 'Cannot open PIAM vehicle class file. Try later!' window nowait
    close databases
    return .f.
  endif

  select 0
  use &PIAM_DPATH.PM_VH_CP alias PM_VH_CP
  if not used('PM_VH_CP')
    wait 'Cannot open PIAM capacity code file. Try later!' window nowait
    close databases
    return .f.
  endif

  select 0
  use &GM_DPATH.GM_BNFIT alias COVERAGE
  if not used('COVERAGE')
    wait 'Cannot open selected coverage file. Try later!' window nowait
    close databases
    return .f.
  endif

  select 0
  use &GM_DPATH.CARMKR alias MAKER
  if not used('MAKER')
    wait 'Cannot open car manufacturer. Try later!' window nowait
    close databases
    return .f.
  endif

  select PROFILE
  go top
  if not eof()
    M.PIAM_COMP = PROFILE.PIAM_COMP
    M.COMP_NAME = PROFILE.COMP_NAME
    M.PIAM_DATE = date()
    M.OUT_PATH  = curdir()

    if S_PIAM()
      do case
        case M_BAR = 1
          do PM_POL
        case M_BAR = 2
        case M_BAR = 3
        otherwise
      endcase
    endif

    select PROFILE
    replace PROFILE.PIAM_COMP with M.PIAM_COMP, ;
            PROFILE.COMP_NAME with M.COMP_NAME, ;
            PROFILE.PIAM_DATE with M.PIAM_DATE
  else
    wait 'System Profile LOST!' window
  endif
  wait 'PIAM file generation completed !!!' window nowait
  close databases
  set sysmenu on
return

procedure MPDF_HSKP
parameter M.BAR
  set sysmenu off
  do case
    case M.BAR = 1
      do GM_INDEX
    case M.BAR = 2
      do GM_PACK
    case M.BAR = 3
      * do GM_SECU
    case M.BAR = 4
      do GM_PROFI
    case M.BAR = 7
      do VW_LOG
    case M.BAR = 8
      do BACKUP
    case M.BAR = 9
      do RESTORE
    case M.BAR = 10
      do S_MFPROF with GMP_PATH,'GM'
  endcase
  set sysmenu on
return

function ZCHKDGT
parameters I_PNO
*
* FUNCTION      : Verify the correctness of the supplied policy number
* ADAPTED FROM  : zchkdgt()@aplus.polnoget.prg
*
private M.DIGIT, M.SUM, M_BRANCH, M_AREA

  if len(I_PNO)<10
    return .f.
  endif

  M_AREA = select()
* check the branch digit
  M_BRANCH = substr(I_PNO,2,2)
*
* valid branch codes are 30,49,60,88,99
*
* select BRANCH
* locate for M_BRANCH = branch.brnch_code
* if not found()
*   wait 'Invalid branch digit in policy number!' window
*   return .t.
* endif
*
  if !ALLDIGIT(substr(I_PNO,2,9))
    return .f.
  endif

  * verify check digit entered

  if right(I_PNO, 1) != MK_DIGIT(substr(I_PNO, 2, 8)) or ;
     !alldigit(right(I_PNO,9))
    return .f.
  endif

  select (m_area)
return .t.

function LD_PROFI
  private m.sheet_no

  GM_STMPDTY  = 2
  GM_TAXRATE  = 5
  GM_TIMEON   = '0000'
  GM_CRRNCY   = '025'
  GM_PRODUCT  = '000100'
  GM_COMPCODE = '016'

  RIN_SHRATE  = 0.10
  RIN_CMRATE  = 0.075

  select 0
  use &GM_DPATH.GM_PROFI alias GM_PROFI
  if used('GM_PROFI')
    go top
    if eof()
      select max(SHEET_NO) as SHEET_NO ;
             from GM_PLCY ;
             into cursor TEMP
      m.sheet_no = TEMP.SHEET_NO
      if used('GM_PLCY')
        select GM_PLCY
        use
      else
        =WRITELOG('Profile rebuilding failed!',0)
        wait 'Cannot rebuild profile. Report problem!' window
        close databases
        return .f.
      endif
      select GM_PROFI
      zap
      insert into GM_PROFI ( ;
        STAX_RATE, ;
        STAMP_DUTY, ;
        TIME_ON, ;
        CURR_CODE, ;
        PROD_CODE, ;
        COMP_CODE, ;
        SHEET_NO, ;
        RIN_SHRATE, ;
        RIN_CMRATE ;
      ) values (   ;
        GM_TAXRATE, ;
        GM_STMPDTY, ;
        GM_TIMEON, ;
        GM_CRRNCY, ;
        GM_PRODUCT, ;
        GM_COMPCODE, ;
        val(right(m.sheet_no,4)), ;
        RIN_SHRATE, ;
        RIN_CMRATE ;
      )
      wait 'System profile re-generated. Check settings!' window
      =WRITELOG('Profile re-generated!!',0)
    else
      * load gloabl variables
      GM_STMPDTY = GM_PROFI.STAMP_DUTY
      GM_TIMEON  = GM_PROFI.TIME_ON
      GM_CRRNCY  = GM_PROFI.CURR_CODE
      GM_TAXRATE = GM_PROFI.STAX_RATE
      GM_PRODUCT = GM_PROFI.PROD_CODE
      GM_COMPCODE= GM_PROFI.COMP_CODE
    endif
    select GM_PROFI
    use
  else
    wait 'PROFILE in use. Cannot continue!' window nowait
    return .f.
  endif
return .t.

function G_OCCDESC
parameter m_occ
private m_area, m_name
  m_area = select()
  select 0
  use &GM_DPATH.OCCUPAT alias T_OCC again noupdate
  if used('T_OCC')
    m_name = lookup(OCC_DESC,M_OCC,OCC_CODE)
    use
  endif
  select (m_area)
return m_name

* get full description of product
function G_PRODDESC
parameter m_occ
private m_area, m_name
  m_area = select()
  select 0
  use &GM_DPATH.PRODUCT alias T_PROD again noupdate
  if used('T_PROD')
    m_name = lookup(PROD_DESC,M_OCC,PROD_CODE)
    use
  endif
  select (m_area)
return m_name

* get name of coverage (basic or additonal)
function G_COVNAME
parameter m_code
private m_area, m_name
  m_area = select()
  select COVERAGE
  m_name = lookup(PCOV_NAME,M_CODE,PCOV_CODE)
  select (m_area)
return M_NAME

* fully describe the current state of a contract
function G_STATE
parameter p_state, p_action
  do case
    case empty(p_state)
    case p_state = 'QT'
      return 'QUOTATION'
    case p_state = 'NB'
      return 'NEW BUSINESS'
    case p_state = 'IF'
      do case
        case empty(p_action)
          return 'IN FORCE'
        case p_action = 'A_NDRS'
          return 'ENDORSE. AT DAYEND'
        case p_action = 'A_CNCL'
          return 'CANCELL. AT DAYEND'
        case p_action = 'A_RNW'
          return 'PRE-RENEWED AT DAYEND'
      endcase
    case p_state = 'XPRD'
      do case
        case p_action = 'A_RNW'
          return 'RENEWED AT DAYEND'
        otherwise
          return 'EXPIRED'
      endcase
    case p_state = 'NDRS'
      return 'ENDORSED'
    case p_state = 'RNW'
      return 'RENEWED'
    case p_state = 'PRNW'
      return 'RENEWED IN ADVANCE'
    case p_state = 'TBIF'
      return 'IN FORCE WHEN EXPIRED!'
    case p_state = 'CNCL'
      return 'CANCELLED'
    otherwise
      return p_state+'???'
  endcase
return 'WELCOME'

* obtain the next state of a the new version of contract
function G_NXTSTATE
parameter m_state, m_action
private m_reply
  m_reply = space(1)
  do case
    case m_state = 'QT'
      m_reply = 'QT'
    case m_state = 'NB'
      m_reply = 'IF'
    case m_state = 'IF'
      do case
        case m_action = 'A_NDRS'
          m_reply = 'IF'
        case m_action = 'A_CNCL'
          m_reply = 'CNCL'
        case m_action = 'A_RNW'
          m_reply = 'TBIF'
      endcase
    case m_state = 'XPRD'
      do case
        case m_action = 'A_RNW'
          m_reply = 'IF'
      endcase
  endcase
return m_reply

* get actual value of NCD percentage using code
function G_NCD
parameter m_ncdcode
private M_AREA, M_NCD
  M_AREA = select()
  select NCD
  m_pct = lookup(NCD_VALUE,M_NCDCODE,NCD_CODE)
  select (M_AREA)
return m_pct

* get full name of car manufacturer
function G_MAKENAME
parameter m_code
private M_AREA, M_NAME
  M_AREA = select()
  select MAKER
  m_name = lookup(MAKE_NAME,M_CODE,MAKE_CODE,'MAKE_CODE')
  select (M_AREA)
return m_name

*
* get agent commission rate from product master
*
function G_ARATE
parameter m_code
private m_area, m_rate
  m_area = select()
  select PRODUCT
  m_rate = lookup(COMM_ARATE,M_CODE,PROD_CODE)
  select (m_area)
return m_rate

*
* get agent leader commission rate from product master
*
function G_LRATE
parameter m_code
private m_area, m_rate
  m_area = select()
  select PRODUCT
  m_rate = lookup(COMM_LRATE,M_CODE,PROD_CODE)
  select (m_area)
return m_rate

*
* short rate table
*
function G_SHRATE
parameter M_LENGTH
  do case
    case M_LENGTH <= GM_LENWK
      return 1/8
    case M_LENGTH <= GM_LENMN
      return 1/4
    case M_LENGTH <= GM_LENMN*2
      return 3/8
    case M_LENGTH <= GM_LENMN*3
      return 1/2
    case M_LENGTH <= GM_LENMN*4
      return 5/8
    case M_LENGTH <= GM_LENMN*6
      return 3/4
    case M_LENGTH <= GM_LENMN*8
      return 7/8
  endcase
return 1

function NXT_NCD
parameter m_code
private m_reply, m_area
  m_area = select()
  select distinct NCD_CODE from NCD ;
         order by NCD_CODE ;
         into cursor TEMP
  select TEMP
  scan while M_CODE >= TEMP.NCD_CODE
  endscan
  if eof()
    go bottom
  endif
  m_reply = TEMP.NCD_CODE
  select (m_area)
return m_reply

function IS_POLICY
parameter M_POLID
return left(M_POLID,1)='M'

* obtain next sheet number
function NXT_SHT
parameter m_sheetno
  if m_sheetno+1 > 9999
    return 1
  endif
return m_sheetno+1

function G_STATNAME
parameter p_action
  do case
    case p_action = 'A_IF'
      return 'NEW BUSINESS'
    case p_action = 'A_NDRS'
      return 'ENDORSEMENT'
    case p_action = 'A_CNCL'
      return 'CANCELLATION'
    case p_action = 'A_RNW'
      return 'RENEWAL'
  endcase
return '**UNKNOWN**'

function G_ACTNAME
parameter p_action
  do case
    case p_action = 'A_IF'
      return 'NEW BUSINESS'
    case p_action = 'A_NDRS'
      return 'ENDORSEMENT'
    case p_action = 'A_CNCL'
      return 'CANCELLATION'
    case p_action = 'A_RNW'
      return 'RENEWAL'
  endcase
return '**UNKNOWN**'


function GET_BP
parameter M.B_COVER, M.CC, M_SUMINS
private   M_BASE, M_AREA, M_LENGTH, M_PRM
    m_area = select()
    select SCHEDULE
    locate for M.CC > SCHEDULE.FROM and M.CC <= SCHEDULE.TO
    if found()
      if M.B_COVER = '000100000001'
        M_BASE = SCHEDULE.COMP
      else
        M_BASE = SCHEDULE.THIRD
      endif
    else
      =writelog('Error in Schedule of Premium with '+AMT2STR(M.CC,5,0))
      wait 'Error in Schedule of Premium!' window
      M_BASE = 0
    endif
    select (m_area)

    M_PRM = M_BASE + MAX(M_SUMINS-1000,0)/1000*GM_BP
    M_LENGTH = m.xprtn_date-m.eff_date+sys_diff
    do case
      case M_LENGTH > GM_LENYR
        M_PRM = M_PRM * M_LENGTH/GM_LENYR
      case M_LENGTH < GM_LENYR
        M_PRM = M_PRM * G_SHRATE(M_LENGTH)
    endcase
return m_prm


* calculate the ACT premium required for a vehicle of given capacity
*
function GET_ACTP
private M_AREA, M_ACTP

  m_area = select()
  select SCHEDULE
  locate for m.cc >= SCHEDULE.FROM and m.cc < SCHEDULE.TO
  if found()
    M_ACTP = SCHEDULE.ACT
  else
    M_ACTP = 0
  endif
  select (m_area)
return M_ACTP

function G_COVTYPE
parameter M_PCOVCODE
private M_COVTYPE
  do case
    case M_PCOVCODE = CV_THRDPTY
      M_COVTYPE = 1
    case M_PCOVCODE = CV_CMPRHNV
      M_COVTYPE = 2
  endcase
return m_covtype
