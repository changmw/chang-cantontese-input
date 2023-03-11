FUNCTION knttomph
PARAMETERS speed
PRIVATE speed, rvalue

************************************************************
*  knttomph(<expN>)                                        *
*  Version # 1.0  FP          Date: 02-06-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts knots into miles per hour.  Can *
*  also be used to convert nautical miles to statute miles.*
************************************************************

IF type('speed') # 'N'
  rvalue = parerror('KNTTOMPH','N')
ELSE
  rvalue = speed * 1.15078
ENDIf

RETURN(rvalue)