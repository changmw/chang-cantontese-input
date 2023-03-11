FUNCTION ctof
PARAMETERS pass_temp
PRIVATE pass_temp, rvalue

************************************************************
*  ctof(<expN>)                                            *
*  Version #  1.0   FP        Date: 11-01-89               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts a Centigrade temperature to     *
*  a Fahrenheit temperature.                               *
************************************************************

IF type('pass_temp') = 'N'
  rvalue = (pass_temp * 1.8) + 32
 ELSE
  rvalue = parerror('ctof','n')
ENDIF

RETURN(rvalue)
