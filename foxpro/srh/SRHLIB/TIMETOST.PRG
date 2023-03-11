FUNCTION timetost
PARAMETER t_str
PRIVATE t_str, ismil, rvalue

************************************************************
*  timetost(<expC>)                                        *
*  Version # 1.0  FP          Date: 10-25-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Converts a time string to English.                *
************************************************************

IF type('t_str') # 'C'
  = poperror('Invalid parameter passed to TIMETOST.  ' +;
             'Function will return a null string.')
  RETURN('')
ENDIF

t_str = ltrim(lower(t_str))

IF at(':',t_str) = 2           &&  only one hour digit
  t_str = '0' + t_str
ENDIF

DO CASE

  CASE 'p'$t_str               &&  if it is after noon

    rvalue = trim(ntoengl(val(substr(t_str,1,2)))) + ;
             iif(empty(val(substr(t_str,4,2))),'', ;
             ' ' + ;
             iif(val(substr(t_str,4,2))<10,'Zero ','') + ;
             trim(ntoengl(val(substr(t_str,4,2))))) + ;
             ' PM'

  CASE 'a'$t_str               &&  if it is before noon
    rvalue = trim(ntoengl(val(substr(t_str,1,2)))) + ;
             iif(empty(val(substr(t_str,4,2))),'', ;
             ' ' + ;
             iif(val(substr(t_str,4,2))<10,'Zero ','') + ;
             trim(ntoengl(val(substr(t_str,4,2))))) + ;
             ' AM'

  OTHERWISE                   &&  if passed in 24-hour mode
    rvalue = iif(val(substr(t_str,1,2))<10,'Zero ','') + ;
             trim(ntoengl(val(substr(t_str,1,2)))) + ;
             iif(empty(val(substr(t_str,4,2))),' Hundred', ;
             ' ' + ;
             iif(val(substr(t_str,4,2))<10,'Zero ','') + ;
             trim(ntoengl(val(substr(t_str,4,2)))))+' Hours'

ENDCASE

RETURN(rvalue)