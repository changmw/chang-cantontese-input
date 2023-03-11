FUNCTION kgtolbs
PARAMETERS weight
PRIVATE weight, rvalue

************************************************************
*  kgtolbs(<expN>)                                         *
*  Version # 1.0  FP          Date: 01-31-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts kilograms to pounds.            *
************************************************************

IF type('weight') # 'N'
  rvalue = parerror('KGTOLBS','N')
ELSE
  rvalue = weight * 2.2046226
ENDIF

RETURN(rvalue)