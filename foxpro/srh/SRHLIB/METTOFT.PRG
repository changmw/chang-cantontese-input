FUNCTION mettoft
PARAMETERS value
PRIVATE value, rvalue

************************************************************
*  mettoft(<expN>)                                         *
*  Version # 1.0  FP          Date: 01-31-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts meters to feet.                 *
************************************************************

IF type('value') # 'N'
  rvalue = parerror('METTOFT','N')
ELSE
  rvalue = value / 0.3048
ENDIF

RETURN(rvalue)