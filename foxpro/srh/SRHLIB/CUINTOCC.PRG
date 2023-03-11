FUNCTION cuintocc
PARAMETERS pass_vol
PRIVATE pass_vol, rvalue

************************************************************
*  cuintocc(<expN>)                                        *
*  Version #  1.0   FP        Date: 11-02-89               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts cubic inches to cubic           *
*  centimeters.                                            *
************************************************************

IF type('pass_vol') = 'N'
  rvalue = pass_vol * 16.387064
ELSE
  rvalue = parerror('cuintocc','n')
ENDIF

RETURN(rvalue)
