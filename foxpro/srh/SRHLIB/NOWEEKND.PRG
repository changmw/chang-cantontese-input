FUNCTION noweeknd
PARAMETERS p_date
PRIVATE p_date, r_char, rvalue

************************************************************
*  noweeknd(<expC/D>                                       *
*  Version # 1.0  FP          Date: 10-19-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Determines if the date passed is on a weekend     *
*  and, if it is, returns the date for the next Monday.    *
*  If the date is a weekday, the function returns that     *
*  date.  The return value is either character or date     *
*  depending on the type of data passed.                   *
************************************************************

IF type('p_date') = 'C'       &&  passed as character data
  p_date = ctod(p_date)       &&  convert to date
  r_char = .t.                &&  mark for return value
ELSE
  r_char = .f.
ENDIF

IF type('p_date') # 'D' .or. empty(p_date)
  = poperror('Invalid parameter passed to NOWEEKND.  '+;
             'Function will return a null date.')
  rvalue = {}                 &&  null date
ELSE

  IF dow(p_date) = 7          &&  Saturday
    rvalue = p_date + 2
  ELSE

    IF dow(p_date) = 1        &&  Sunday
      rvalue = p_date + 1
    ELSE 
      rvalue = p_date         &&  all other days
    ENDIF

  ENDIF

ENDIF

IF r_char                     &&  if passed as character
  rvalue = dtoc(rvalue)       &&  return it as character
ENDIF

RETURN(rvalue)