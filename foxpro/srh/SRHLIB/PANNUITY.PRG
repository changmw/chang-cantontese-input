FUNCTION pannuity
PARAMETERS int_rate, num_yrs
PRIVATE int_rate, num_yrs, i, rvalue

************************************************************
*  pannuity(<expN1>,<expN2>)                               *
*  Version # 1.0  FP          Date: 02-01-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function is passed the annual rate of interest    *
*  and the number of years for the annuity.  Function      *
*  returns the number representing the present value of    *
*  the annuity with the payment received on the last day   *
*  of the year.                                            *
************************************************************

rvalue = 0

IF parameters() # 2 .or. type('int_rate') # 'N';
   .or. type('num_yrs') # 'N'

    rvalue = parerror('PANNUITY','N')

ELSE
  int_rate = int_rate/100       && convert to a decimal
  FOR i = 1 TO num_yrs
   rvalue = rvalue + (1/(1+int_rate)^(num_yrs+1-i))
  ENDFOR

ENDIF

RETURN(rvalue)