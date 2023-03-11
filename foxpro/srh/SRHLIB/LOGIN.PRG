  *
  *- function LOGIN
  *-
  *
  * Function:
  * 1. prompt user name and password
  *    user can try 3 times at most to get the correct password
  *
  * input : SYSNAME    - system name
  *         SYSVER - version of system
  *         PROGBY     - Programmer Name
  *         PACKAGE   - sub-title
  *         U_NAME     - Login name
  *         U_LEVEL    - Security Level
  *
  * Return: .T. if identity verified
  *         .F. otherwise
  *
  parameters SYSNAME, SYSVER, PROGBY, PACKAGE, U_NAME, U_LEVEL

  private M_PASS, M_TRY, M_SUCCEED, M_NETNAME, M_PATH
  private M_TALK_SET, M_CONF_SET, M_DELI_SET

  M_PATH="F:\SRHIS\PUBLIC\DATA\"

  on error do MY_ERRHAND with error(), message(), message(1), program(), lineno()
  M_TALK_SET=set('TALK')
  M_CONF_SET=set('TALK')
  M_DELI_SET=set('DELI')
  set talk off
  set confirm off
  set delimiter on
  set delimiter to '[]'

  define window W_LOGIN from 05,15 to 16,55 panel shadow ;
         color W/N,W/N,W/N,N/W title PACKAGE float
  activate window W_LOGIN

  set color to gb+/n
  @ 01,CENTRE(SYSNAME,wcol()) say SYSNAME
  set color to r+/n
  @ row()+1,CENTRE(SYSVER,wcol()) say SYSVER
  set color to b+/n
  @ row()+1,CENTRE(PROGBY,wcol()) say PROGBY
  set color to w/n

  *
  * load USERNAME
  * M_NETNAME=space(48)
  * call USERNAME with M_NETNAME
  *

  M_SUCCEED = .F.
  M_TRY     = 0

  @ 05, 07 say "Please login:"
  do while M_TRY < 3 .and. .not. M_SUCCEED
    M_PASS    = space(8)
    U_NAME    = space(8)
    @ 08, 23 say space(10)
    @ 07, 07 say 'LOGIN NAME:  '+space(2) get U_NAME  ;
             picture '@!' valid .not.empty(U_NAME) ;
             error 'ENTER LOGIN NAME'
    read

    if lastkey() = 27  && ESC aborts login
      exit
    else
      @ 08,07 say 'PASSWORD:       ['+space(8)+']'
      if 27 = GETPASWD(row(), 23, 8, M_PASS)
        M_SUCCEED= .F.  && ESC terminates
        exit
      else
        select 0
        use &M_PATH.USERS noupdate alias USERS
        if used('USERS')
          locate for USERID=U_NAME .and. USERS.SYSTEM=PACKAGE
          if .not. found()
            =ERRMSG('INVALID USERID-PASSWORD PAIR')
            M_TRY=M_TRY+1
          else
            if alltrim(USERS.PASSWORD)=ENCRYPT(M_PASS)
              U_LEVEL=USERS.LEVEL
              M_SUCCEED=.t.
            else
              =ERRMSG('INVALID USERID-PASSWORD PAIR')
              M_TRY=M_TRY+1
            endif
          endif
          use in USERS
        else
          =ERRMSG('SYSTEM BUSY.. PLEASE WAIT A MOMENT!')
        endif
      endif
    endif
  enddo

  on error
  set talk &M_TALK_SET
  set conf &M_CONF_SET
  set deli &M_DELI_SET

  release window W_LOGIN
return M_SUCCEED

procedure MY_ERRHAND
  parameter P_ERRNO, P_MSG1, P_MSG2, P_PROG, P_LINENO

  do case
*   case P_ERRNO=20     && record is not in index (file locked)
    case P_ERRNO=26     && database in not ordered
      set fullpath off
      wait "Please ask supervisor to re-indexe "+dbf() window
      set fullpath on
    case P_ERRNO=109    && Record exclusively used by another
    case P_ERRNO=114    && index damaged
    case P_ERRNO=130    && Record exclusively used by another
    case P_ERRNO=108    && File exclusively use by another
    case P_ERRNO=1707   && Structural index not found
    otherwise
      set device to screen

      define window W_ALERT from 15,00 to 20,79 ;
            shadow title " SYSTEM ERROR " ;
            color w+/r,w+/r,w+/r,w+/r,w+/r

      activate window W_ALERT
      @ 01,     (wcols()-len(P_MSG1))/2 say P_MSG1
      @ row()+1,(wcols()-len(P_MSG2))/2 say P_MSG2
      wait 'CALL SYSTEM TEAM' window
      release window W_ALERT

      on error
      pop menu _MSYSMENU
      clear read all
      release workarea,exact,safety
      on key label enter
      on key label del
      on key label ins
      cancel
  endcase
return
