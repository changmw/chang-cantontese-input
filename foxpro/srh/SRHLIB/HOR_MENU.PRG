FUNCTION hor_menu
PARAMETERS rr, cc, opt_spc, m_rr, m_cc, m_choice1, mess_1, ;
           m_choice2, mess_2, m_choice3, mess_3, ;
           m_choice4, mess_4, m_choice5, mess_5, ;
           m_choice6, mess_6, m_choice7, mess_7, ;
           m_choice8, mess_8
PRIVATE rr, cc, opt_spc, m_rr, m_cc, m_choice1, m_choice2, ;
        m_choice3, m_choice4, m_choice5, m_choice6, ;
        m_choice7, m_choice8, mess_1, mess_2, mess_3
PRIVATE mess_4, mess_5, mess_6, mess_7, mess_8, ch_count, ;
        num, trigger, cc1, cc2, cc3, cc4, cc5, cc6, cc7, ;
        cc8
PRIVATE cur_esc, max_mess, vscreen, i , optcolor, cur_col
PRIVATE mess_len, rvalue

************************************************************
*  hor_menu(<expN1>,<expN2>,<expN3>,<expN4>,<expN5>,;      *
*           <expC1>,<expC2>,<expC3>,<expN4>,[<expC5>,;     *
*           <expC6>[,<expC7>,<expN8>[,<expC9>,<expC10>;    *
*           [,<expC11>,<expN12>[,<expC13>,<expC14>;        *
*           [,<expC15>,<expC16>]]]]]])                     *
*                                                          *
*  Version #  2.0 FP           Date: 01-22-91              *
*  Programmed by: Malcolm C.  Rubel                        *
*                                                          *
*  Copyright (c) 1990,91                                   *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function performs horizontal bounce bar menu      *
*  without the aid of outside support modules.  Will do a  *
*  menu with up to eight choices, each with its own        *
*  message.  Function returns the value of the choice.     *
*  Modified 1-22-91 to eliminate macro expansion where     *
*  possible.                                               *
************************************************************

ch_count = (parameters() - 5)/2
max_mess = 0
trigger = ''
optcolor = scheme(1,2)

cur_esc = set('escape') = 'ON'
SET ESCAPE off

FOR i = 1 to ch_count         &&  paint and determine
  num = ltrim(str(i))
  @ rr,cc SAY ' ' + evaluate('m_choice' + num) + ' '
  cur_col = 'cc' + num
  STORE cc TO (cur_col)      &&  col locat.  for each option
  cc = col() + opt_spc

***  how long is the longest message

  mess_len = len(evaluate('mess_' + num))
  max_mess = iif(mess_len>max_mess,mess_len,max_mess)

***  Assemble the trigger string from first letters of
***  passed parameters.
  trigger = trigger + substr(evaluate('m_choice' + num),1,1)

ENDFOR

SAVE SCREEN TO vscreen
choice = ch_count
key = 24                  &&  cursor down

DO WHILE key # 13         &&  Enter key

  RESTORE SCREEN FROM vscreen

  DO CASE

***  if keypress is cursor down, cursor right, or
***  spacebar

    CASE key = 24 .or.  key = 4 .or.  key = 32
      choice = iif(choice = ch_count,1,choice+1)

***  if keypress is cursor up or cursor left

    CASE key = 5 .or.  key = 19
      choice = iif(choice = 1,ch_count,choice-1)

    CASE at(upper(chr(key)),trigger) > 0
      choice = at(upper(chr(key)),trigger)
      EXIT

***  if keypress is home or PgUp

    CASE key = 1 .or.  key = 18
      choice = 1

    CASE key = 6  .or.  key = 3      &&  End or PgDn
      choice = ch_count

  ENDCASE

***  Paint the new option and the new message

  num = ltrim(str(choice))
  SET COLOR OF NORMAL TO (optcolor)
  @ rr,evaluate('cc' + num) SAY ' ' + ;
                 evaluate('m_choice' + num) + ' '
  SET COLOR TO
  @ m_rr,m_cc SAY space(max_mess+2)
  @ m_rr,m_cc SAY ' ' + evaluate('mess_' + num)

  key = inkey(0,'h')       &&  hide the cursor

ENDDO

SET COLOR TO

IF cur_esc
  SET ESCAPE on
ENDIF

RETURN(choice)