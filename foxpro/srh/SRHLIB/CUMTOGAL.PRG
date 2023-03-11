FUNCTION cumtogal
PARAMETERS cu_mets
PRIVATE cu_mets, rvalue

************************************************************
*  cumtogal(<expN>)                                        *
*  Version # 1.0  FP          Date: 02-06-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts cubic meters into gallons.      *
************************************************************

IF type('cu_mets') # 'N'
  rvalue = parerror('CUMTOGAL','N')
ELSE
  rvalue = cu_mets * 264.17205

ENDIF

RETURN(rvalue)
