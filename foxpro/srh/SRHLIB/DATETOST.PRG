FUNCTION datetost
PARAMETERS p_date
PRIVATE p_date, rvalue

************************************************************
*  datetost([<expD>]                                       *
*  Version # 1.0  FP          Date: 02-06-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns a character string containing    *
*  the complete expansion of the date to a character       *
*  string.  If no parameter is passed, the function uses   *
*  the system date.                                        *
************************************************************

IF parameters() = 0
  p_date = date()
ENDIF

IF type('p_date') # 'D'

  = poperror('The parameter passed to the function '+;
             'DATETOST is not a date.  Function '+;
             'will return "************".')
  rvalue = '**********'

ELSE                          &&  if we have a date

  IF .not. empty(p_date)
    rvalue = cdow(p_date) + ', ' + cmonth(p_date) + ' ' + ;
             ltrim(str(day(p_date))) + ', ' + ;
             ltrim(str(year(p_date)))
  ELSE
    rvalue = 'Null Date'
  ENDIF

ENDIF

RETURN(rvalue)