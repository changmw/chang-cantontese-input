FUNCTION lbstokg
PARAMETERS weight
PRIVATE weight, rvalue

************************************************************
*  lbstokg(<expN>)                                         *
*  Version # 1.0  FP          Date: 01-31-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts pounds to kilograms.            *
************************************************************

IF type('weight') # 'N'
  rvalue = parerror('LBSTOKG','N')
ELSE
  rvalue = weight/2.2046226
ENDIF

RETURN(rvalue)