  clear all
  private U_NAME, U_LEVEL, W_HEAD, SIC_PATH

  do MYSET

  set procedure to SRHLIB
  on error do ERRPROC with error(), message(), message(1), program(), lineno()

  * this variable points to the path holding the HKSIC.DBF from
  * the HK Census and Statistics Depart. Note that the path must
  * be ended with a slash
  SIC_PATH  = "\DP\HKSIC\"

  SYSDATE   = date()       && today's date
  SYSNAME   = 'HONGKONG STANDARD INDUSTRIAL CLASSFICATION'
  PROGBY    = 'WAI'
  SYSVERSION= 'VERSION 1.0'
  A_NORMAL  = 'w/n,n/w'
  U_NAME    =space(1)
  U_LEVEL   =space(1)

  do KEYCODE
  do SRHWALL

  W_HEAD=SHOWHEAD("MAIN MENU")
  set color to n/w,w+/n
  define popup W_TOP from 05,05 shadow
  define bar 1 of W_TOP prompt "SAMPLE SPECIFICATION"
  define bar 3 of W_TOP prompt "RANDOM SAMPLING"
  define bar 4 of W_TOP prompt "GROUP SAMPLING"
  define bar 5 of W_TOP prompt "VIEW SAMPLES"
  define bar 7 of W_TOP prompt "SYSTEM MAINTENANCE"
  on selection popup W_TOP do P_TOP with bar()
  activate popup W_TOP
  release popup W_TOP
  clear all
  on error
return

procedure P_TOP
  parameters M_BAR
  do case
    case M_BAR=1
      do SS_SPEC
    case M_BAR=3
      do RND_SAMP
    case M_BAR=5
      do SS_VIEW
    case M_BAR=7
  endcase
return

procedure RND_SAMP
  set color to n/w,w+/n
  define popup W_RAND from 08,08 shadow title "RANDOM SAMPLING"
  define bar 1 of W_RAND prompt "using INDUSTRY and MPS"
  define bar 2 of W_RAND prompt "using TPU and MPS"
  define bar 3 of W_RAND prompt "using INDUSTRY, TPU and MPS"
  on selection popup W_RAND do P_RAND with bar()
  activate popup W_RAND
  release popup W_RAND
return

procedure P_RAND
  parameters M_BAR
  do case
    case M_BAR=1
      do SS_RSIM
  endcase
return

procedure RESET
  * reset system environment
  set color to
  set exclusive on

  set delimiters to default
  set delimiters off

  set talk on
  set echo off
  set safety on
  set escape on
  set deleted off
  set bell on

  set udfparms to value

  set reprocess to 0    && single user default
  set exclusive on

  set escape on
  set debug on
  set sysmenu on

  on key label f10      && release F10
  on error
return

procedure MYSET
  set escape off        && disallow user from stopping the program
  set debug off         && for running under FoxPro Runtime
  set notify on

  set color on
  set talk off
  set bell off
  set status off
  set echo off          && standard settings for running programs
  set safety off

  set century off       && date settings
  set date british

  set intensity off     && field editing attribute
  set delimiters to '[]'
  set delimiters on

  set udfparms to reference  && paramaters passed-by-reference by default

  * affect index construction
  set unique off        && DO NOT use unique as active and deleted
                        &&       records of the same key are kept
  set exact on          && string comparison must be exact
  set deleted on        && deleted record will not be displayed

  set scoreboard off    && won't need to see Ins,Num status
  set sysmenu off
  set shadow on
  set clock off

  * multi-user database, set up locking methods and timeout period
  set exclusive off     && shared access unless specified otherwise
  set reprocess to 30   && wait to lock file/record for at most 30 seconds
  set multilocks on     && allow locking multiple records
  set resource off
  set odometer to 1000

  set help off
return

procedure HOOKF10
  on key label f10 keyboard chr(K_C_W)        && F10 always save changes
return
