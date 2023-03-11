FUNCTION std_devi
PARAMETERS d_field, dbf_file
PRIVATE d_field, dbf_file, rvalue

************************************************************
*  std_devi(<expC1>[,<expC2>])                             *
*  Version # 1.0              Date: 02-14-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the standard deviation of the    *
*  numeric field specified in expC1. If only one parameter *
*  is passed, the function assumes that you want to work   *
*  in the currently selected data table.  If the second    *
*  parameter is passed, it names the open but unselected   *
*  table to use.  Function returns the standard deviation  *
*  of the entire data table (unless a filter has been set).*
************************************************************

IF parameters() = 1
  dbf_file = alias()
ENDIF

rvalue = sqrt(variance(d_field,dbf_file))

RETURN(rvalue)