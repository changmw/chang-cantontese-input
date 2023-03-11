FUNCTION galtolit
PARAMETERS volume
PRIVATE  volume, rvalue

************************************************************
*  galtolit(<expN>)                                        *
*  Version # 1.0  FP          Date:  1-8-90                *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts gallons to liters.              *
************************************************************

IF type('volume') # 'N'
  rvalue = parerror('galtolit','n')
ELSE
  rvalue = volume * 3.785306
ENDIF

RETURN(rvalue)