FUNCTION isundef
PARAMETERS expr
PRIVATE expr, rvalue

************************************************************
*  isundef(<expC>)                                         *
*  Version # 1.0  FP          Date: 11-02-89               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (C) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns TRUE if named variable is        *
*  undefined.  The variable must be passed as a character  *
*  string.                                                 *
************************************************************

IF .not. type('expr') = 'C'
  = poperror('Variable passed to ISUNDEF must be '+;
             'passed as a character expression.  '+;
             'Function will return TRUE.')
  rvalue = .t.
ELSE
  rvalue = iif(type(expr) = 'U' ,.t.,.f.)
ENDIF

RETURN(rvalue)