FUNCTION password
PARAMETERS pw_len
PRIVATE pw_len, pass_str, key, cur_curs

************************************************************
*  password([<expN1>])                                     *
*  Version #  2.1 FP          Date: 08-29-91               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990, 91                                  *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Displays a password entry box on the screen and   *
*  echoes stars as the user enters his or her password.    *
*  Returns the password string.                            *
*  Modified 7-20-91 to clear ON KEY LABELs with PUSH KEY   *
*  CLEAR/POP KEY.                                          *
*  Modified 8-29-91 to use WOUTPUT to control windows.     *
************************************************************

PUSH KEY CLEAR

IF parameters() = 0           &&  if no parameters passed
  pw_len = 6                  &&  use password length of 6
ENDIF

pass_str = ''
key = 0

cur_curs = set('cursor') = 'ON'   &&  current cursor state
SET CURSOR on
cur_win = woutput()

DEFINE WINDOW pass_win FROM 08,20 TO 15,60 DOUBLE ;
              COLOR SCHEME 21
ACTIVATE WINDOW pass_win

@ 02,09 SAY 'Type in your password'
@ 03,12 SAY '(' + ltrim(str(pw_len)) + ' characters.)'
@ 05,15 SAY ''

DO WHILE key # 13             &&  accept until car_return
  SET COLOR OF NORMAL TO x
  m.key = inkey(0)

  DO CASE

    CASE isalpha(chr(m.key)) .or. ;
         (m.key >= 32 .and. m.key <= 64)
      pass_str = pass_str + chr(m.key)

    CASE m.key = 19 .or. m.key = 127 .or. m.key = 7
      @ row(),col()-1 SAY ' '
      @ row(),col()-1 SAY ''
      pass_str = substr(pass_str,1,len(pass_str)-1)

  ENDCASE

  IF len(pass_str) >= pw_len
    m.key = 13
  ENDIF

  SET COLOR OF NORMAL TO 
  @ 05,15 SAY space(pw_len)
  @ 05,15 SAY replicate('*',len(pass_str))
ENDDO

RELEASE WINDOW pass_win

IF empty(cur_win)
  ACTIVATE SCREEN
ENDIF

IF .not. cur_curs             &&  if cursor was off
  SET CURSOR OFF              &&  set it back on
ENDIF

POP KEY

RETURN(pass_str)