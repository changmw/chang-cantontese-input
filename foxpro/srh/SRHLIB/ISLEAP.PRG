FUNCTION isleap
PARAMETERS p_date
PRIVATE p_date, p_year, rvalue

************************************************************
*  isleap(<expC/D/N>)                                      *
*  Version # 1.0  FP          Date: 11-02-89               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns TRUE if the date or the year     *
*  passed is a leap year.                                  *
************************************************************

rvalue = .t.                  &&  starting value

DO CASE

  CASE type('p_date') = 'N'   &&  passed as a number
    p_year = ltrim(str(p_date))

  CASE type('p_date') = 'C'   &&  if passed as a character

    IF ctod(p_date) # ctod('  /  /  ')  &&  valid string
      p_year = ltrim(str(year(ctod(p_date))))
    ELSE
      rvalue = .f.
    ENDIF

  CASE type('p_date') = 'D'   &&  passed as a date
    p_year = ltrim(str(year(p_date)))

  OTHERWISE
    rvalue = .f.              &&  invalid parameter
ENDCASE

IF rvalue                     &&  we passed the test

***  if two days before the First of March is not 
***  February 28th (a leap year) the rvalue = .f.

  IF ctod('03/01/' + p_year) - ctod('02/28/' + p_year) # 2
    rvalue = .f.              &&  change return value to F
  ENDIF

ELSE                          &&  invalid data

  = poperror('Invalid data passed to function ISLEAP.  '+;
             'Function will return FALSE.')

ENDIF

RETURN(rvalue)