FUNCTION workdays
PARAMETERS s_date, e_date
PRIVATE s_date, e_date, sdow, num_days, add_days, num_weeks
PRIVATE rvalue

************************************************************
*  workdays(<expD1>,<expD2>)                               *
*  Version # 1.0  FP          Date: 02-06-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the number of workdays  between  *
*  the two dates including the starting day and the ending *
*  day in the total but excluding Saturdays and Sundays.   *
*  The function knows nothing about Presidents' Day etc.   *
************************************************************

DO CASE

  CASE parameters() # 2
    = poperror('Incorrect number of parameters '+;
               'passed to the function WORKDAYS.  '+;
               'Function will return a divide overflow.')
    rvalue = 1/0

  CASE type('s_date') # 'D' .or. type('e_date') # 'D'
    = poperror('Parameter passed to function '+;
               'WORKDAYS is not a DATE.  Function '+;
               'will return a divide overflow.')
    rvalue = 1/0

  CASE e_date < s_date
    = poperror('Ending date passed to function '+;
               'WORKDAYS is before starting date. '+;
               'Function will return zero.')
    rvalue = 0

  OTHERWISE                   &&  everything is okay
    sdow = dow(s_date)
    num_days = e_date - s_date
    num_weeks = int(num_days/7)
    add_days = mod(num_days,7)

    DO CASE

      CASE add_days + sdow <= 6 
        add_days = add_days + 1

      CASE add_days + sdow = 7
        add_days = add_days 

      CASE add_days + sdow > 7
        add_days = add_days - 1

    ENDCASE

    rvalue = num_weeks*5 + add_days

ENDCASE

RETURN(rvalue)