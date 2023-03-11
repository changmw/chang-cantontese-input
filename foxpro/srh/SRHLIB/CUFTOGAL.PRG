FUNCTION cuftogal
PARAMETERS cu_ft
PRIVATE cu_ft, rvalue

************************************************************
*  cuftogal(<expN>)                                        *
*  Version # 1.0  FP          Date: 02-06-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts cubic feet liquid measure to    *
*  gallons.                                                *
************************************************************

IF type('cu_ft') # 'N'
  rvalue = parerror('CUFTOGAL','N')
ELSE
  rvalue = 7.480520 * cu_ft
ENDIF

RETURN(rvalue)