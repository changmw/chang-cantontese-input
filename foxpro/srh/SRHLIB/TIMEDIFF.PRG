FUNCTION timediff
PARAMETERS t_1, t_2
PRIVATE t_1, t_2, rvalue

************************************************************
*  timediff(<expC1>,<expC2>)                               *
*  Version # 1.0  FP          Date: 01-15-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the number of seconds between    *
*  two time strings up to a maximum of 24 hours.  <expC1>  *
*  is the first time mark, <expC2> is the second time      *
*  mark.                                                   *
************************************************************

IF parameters() # 2
  rvalue = pnumerr('timediff')
ENDIF

rvalue = ttos(t_2) - ttos(t_1)

IF rvalue <= 0                &&  we have passed midnight
  rvalue = rvalue + 86400
ENDIF

RETURN(rvalue)