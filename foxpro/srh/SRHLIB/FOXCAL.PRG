FUNCTION foxcal
PARAMETERS s_row, s_col
PRIVATE s_row, s_col, startdate, cur_col, cur_row, cur_win
PRIVATE m_row, m_col, fdom

************************************************************
*  foxcal([<expN1>[,<expN2>]],[<expD>])                    *
*  Version # 2.2  FP          Date: 08-29-91               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1991                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note:  Function uses the FoxPro calendar (slightly      *
*  disabled) to present a calendar.  The calendar is       *
*  fully mousable.  Pressing Enter or double clicking on   *
*  a date selects the date.  Pressing Escape returns the   *
*  starting date.                                          *
*  Modified 7-20-91 to clear and restore ON KEY LABELs     *
*  using PUSH KEY CLEAR and POP KEY.                       *
*  Modified 8-29-91 to use WOUTPUT to control windows.     *
************************************************************

PUSH KEY CLEAR
cur_win = woutput()

DO CASE 

  CASE parameters() = 0       &&  no parameters passed
    s_row = row()
    s_col = col()
    startdate = date()

  CASE parameters() = 1

    IF type('s_row') = 'N'
      s_col = col()
      startdate = date()
    ELSE
      start_date = s_row
      s_row = row()
      s_col = col()
    ENDIF

  CASE parameters() = 2

     IF type('s_col') = 'N'
       startdate = date()
     ELSE
       startdate = s_col
       s_col = col()
     ENDIF

ENDCASE

***  make sure that we have the right parameters!

IF type('s_row') # 'N' .or. type ('s_col') # 'N' .or. ;
   type('startdate') # 'D'
  = poperror('Invalid parameters passed to the FOXCAL.  '+;
             'The function will return the system date.')
  RETURN(date())
ENDIF

***  make sure everything will fit on the screen.

s_row = iif(s_row<10,s_row,9)
s_col = iif(s_col<58,s_col,58)

***  Do the menu.

DEFINE WINDOW _mycal FROM s_row,s_col TO s_row+15,s_col+21;
                          TITLE ' Calendar ';
                          FOOTER '<M-><M+><Y-><Y+>';
                          PANEL

ACTIVATE WINDOW _mycal        &&  our window

***  now activate the FoxPro calendar in our window

ACTIVATE WINDOW calendar IN WINDOW _mycal
MOVE WINDOW calendar TO -1,-1  &&  move it to correct spot

***  loop to make the calendar work

DO WHILE .t.
  key = inkey(0,'m')

  DO CASE 

    CASE key = 13             &&  Enter
      EXIT

    CASE key = 27             &&  Escape
      _diarydate = startdate
      EXIT

    CASE key = 5              &&  Up arrow
      _diarydate = _diarydate - 7

    CASE key = 24             &&  Down arrow
      _diarydate = _diarydate + 7

    CASE key = 19             &&  Left arrow
      _diarydate = _diarydate - 1

    CASE key = 4              &&  Right arrow
      _diarydate = _diarydate + 1

    CASE key = 151            &&  mouse

***  first find out where the current date is located
***  on the calendar

      cur_col = (3 * dow(_diarydate)) - 3
      fdom = dow(_diarydate - day(_diarydate)+1)
      cur_row = 3 + 2*int((fdom - 2 + day(_diarydate))/7)

***  next find out where the mouse was clicked
      m_row = mrow()
      m_col = mcol()

      DO CASE

        CASE m_row = -1       &&  mouse row is off window

          DO CASE

            CASE between(m_col,2,5)        &&  <M->
              _diarydate = gomonth(_diarydate,-1)

            CASE between(m_col,6,9)        &&  <M+>
              _diarydate = gomonth(_diarydate,1)

            CASE between(m_col,10,13)      &&  <Y->
              _diarydate = gomonth(_diarydate,-12)

            CASE between(m_col,14,17)      &&  <Y+>
              _diarydate = gomonth(_diarydate,12)

            CASE m_col = 1 .or. m_col = 18
              LOOP

            OTHERWISE
              _diarydate = startdate
              EXIT

          ENDCASE

***   here are the real choices for day selection

        CASE mod(m_row,2) # 0 .and. m_row > 2 .or. ;
             mod(m_col,3) = 0

***  move the date the column difference between current 
***  date and the selected date

          _diarydate = _diarydate - int(cur_col/3) + ;
                       int(m_col/3)

***  move the date the row difference between the current
***  date and the selected date

          _diarydate = _diarydate + 7 * ;
                      ((m_row-cur_row)/2)

          dbl_click = inkey(_dblclick,'hm')

          IF dbl_click = 151  &&  mouse hit twice
            EXIT
          ENDIF

        CASE m_col = -1       &&  way off the ranch
          _diarydate = startdate
          EXIT

      ENDCASE

  ENDCASE

ENDDO

RELEASE WINDOW _mycal

IF empty(cur_win)
  ACTIVATE SCREEN
ENDIF

POP KEY

RETURN(_diarydate)