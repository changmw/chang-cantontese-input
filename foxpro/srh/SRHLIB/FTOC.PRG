FUNCTION ftoc
PARAMETERS temp
PRIVATE temp, rvalue

************************************************************
*  ftoc(<expN>)                                            *
*  Version #  1.0   FP        Date: 11-21-89               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts a Fahrenheit temperature to a   *
*  Centigrade temperature.                                 *
************************************************************

IF type('temp') = 'N'
  rvalue = (temp - 32) / 1.8
ELSE
  rvalue = parerror('FTOC','N')
ENDIF

RETURN(rvalue)
