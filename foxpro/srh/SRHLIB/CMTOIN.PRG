FUNCTION cmtoin
PARAMETERS value
PRIVATE value, rvalue

************************************************************
*  cmtoin(<expN>)                                          *
*  Version #  1.0    FP       Date:  11-21-89              *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts centimeters to inches.          *
************************************************************

IF type('value') = 'N'
  rvalue = value * 0.393701
ELSE  
  = poperror('The parameter passed to the function '+;
             'CMTOIN is not numeric.  Function '+;
             "will return a '***' divide "+;
             'overflow.')
  rvalue =  1/0
ENDIF

RETURN(rvalue)
