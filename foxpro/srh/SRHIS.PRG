*
*  Survey Research Hongkong Limited
*  SRH Information Systems
*  Copyright Survey Research Company Limited 1991-
*  SRH Internal Use Only
*
*  Menu shell for all projects of SRH Information Systems
*
  clear all
  set path to F:\SRHIS\PROGRAM
  set procedure to SRHLIB

  on error do ERRPROC with error(), message(), message(1), program(), lineno()
  do MYSET

  *-sysstem variables
  public SYSDATE        && machine system date
  public SYSNAME        && System name
  public PROGBY         && programmed by
  public SYSVERSION     && version of system

  *-user-specific information
  public U_LEVEL        && user's security level
  public U_NAME         && Director ID

  *-screen attributes
  public A_NORMAL

  SYSDATE   = date()       && today's date
  SYSNAME   = 'SRHIS-JB: AD HOC JOB SHEET SYSTEM'
  PROGBY    = 'WAI'
  SYSVERSION= 'VERSION 2.07'
  A_NORMAL  = 'w/n,n/w'

  set color to n/w,w+/n
  define popup W_SRHIS from 05,05 shadow
  define bar 1 of W_SRHIS prompt 'Ah Hoc Job Control Sheet'
  define bar 2 of W_SRHIS prompt 'Mailing List'
  define bar 3 of W_SRHIS prompt 'Full-time Payroll'
  define bar 4 of W_SRHIS prompt 'Personnel'
  define bar 5 of W_SRHIS prompt 'Time Cost Analysis'
  define bar 6 of W_SRHIS prompt 'Database Administrator'
  on selection popup W_SRHIS do P_TOP with bar()

  define window W_MSG from 14,10 to 16,50 color n/w,n/w,n/w,n/w,n/w,n/w shadow

  do APP_PATH
  do KEYCODE

  =SRHWALL()
  do while lastkey()#K_ESC
    activate popup W_SRHIS
  enddo

  clear all     && dealloc all mem var, window, popup, dbf, ...
  do reset
  set color to w/n
  clear
return

procedure P_TOP
  parameters M_CHOICE

  hide popup W_SRHIS

  do case
    case M_CHOICE=1
      do JOBSHEET
    case M_CHOICE=2
      do MAILLIST
    case M_CHOICE=3
      do PAYROLL
    case M_CHOICE=4
      do PERSON
    case M_CHOICE=5
      do TIMECOST
    case M_CHOICE=6
      do DBA
  endcase

  set path to F:\SRHIS\PROGRAM
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

  set help off
return

procedure HOOKF10
  on key label f10 keyboard chr(K_C_W)        && F10 always save changes
return
