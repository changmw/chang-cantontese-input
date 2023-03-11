FUNCTION lastdoq
PARAMETERS p_date, delta
PRIVATE p_date, delta, rvalue

************************************************************
*  lastdoq(<expD/C>[,<expN>])                              *
*  Version # 1.0  FP          Date: 01-31-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the last day of the quarter      *
*  either forward or backward from the passed date.  If    *
*  the second parameter is not passed, the function        *
*  returns the last day of the current quarter.            *
************************************************************

IF parameters() = 1           &&  if no delta was passed
  delta = 0                   &&  assume current quarter
ENDIF

IF type('p_date') = 'C'
  p_date = ctod(p_date)
ENDIF

IF type('p_date') # 'D' .or. empty(p_date)
  rvalue = parerror('LASTDOQ','D')
ELSE
  delta = delta + 1           &&  add an extra quarter
  rvalue = firstdoq(p_date,delta) -1  &&  subtract a day
ENDIF

RETURN(rvalue)