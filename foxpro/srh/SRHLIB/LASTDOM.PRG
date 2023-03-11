FUNCTION lastdom
PARAMETERS p_date
PRIVATE p_date, rvalue

************************************************************
*  lastdom(<expD/C>)                                       *
*  Version # 1.0  FP          Date: 01-31-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Returns the last day of the month specified.      *
*  Function takes into account month lengths and leap year.*
************************************************************

IF type('p_date') = 'C'
  p_date = ctod('p_date')
ENDIF

IF type('p_date') # 'D' .or. empty(p_date)
  rvalue = parerror('LASTDOM','D')
ELSE
  rvalue = firstdom(gomonth(p_date,1))-1
ENDIF

RETURN(rvalue)