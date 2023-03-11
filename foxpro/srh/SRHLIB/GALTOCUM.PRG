FUNCTION galtocum
PARAMETERS gallons
PRIVATE gallons, rvalue

************************************************************
*  galtocum(<expN>)                                        *
*  Version # 1.0  FP          Date: 02-06-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts gallons to cubic meters.        *
************************************************************

IF type('gallons') # 'N'
  rvalue = parerror('GALTOCUM','N')
ELSE
  rvalue = gallons/264.17205
ENDIF

RETURN(rvalue)
