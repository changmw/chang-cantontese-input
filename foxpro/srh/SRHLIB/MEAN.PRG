FUNCTION mean
PARAMETERS d_field, dbf_file
PRIVATE d_field, dbf_file, cur_buff, cur_comp, alias
PRIVATE pcount, rvalue

************************************************************
*  mean(<expC1>[,<expC2>])                                 *
*  Version # 1.0              Date: 02-14-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the mean (average) of all        *
*  numeric data in an data table.  If only one parameter is*
*  passed, the function assumes that you want to work on   *
*  the currently selected data table.  If the second       *
*  parameter is passed, it names the open but unselected   *
*  table to use.  Function returns the mean of the entire  *
*  data table (unless a filter has been set.)              *
************************************************************

pcount = parameters()

rvalue = 0                    &&  starting value

cur_comp = set('compat') = 'ON' &&  dBase IV compatibility
SET COMPAT off
cur_buff = select()

d_field = alltrim(upper(d_field))

IF pcount = 1

  alias = alias()

  IF len(alias) = 0           &&  open buffer
    = poperror('No data table specified for the '+;
               'function MEAN.  Function will '+;
               'return a divide overflow.')
    rvalue = 1/0

  ELSE

    IF type('&alias->&d_field') # 'N'  && no field 
      = poperror('No numeric field in the ' + alias +;
                 ' data table called ' + d_field +;
                 '.  Function MEAN will return a '+;
                 'divide overflow.')
      RVALUE = 1/0
    ENDIF

  ENDIF

ELSE                          &&  if two parameters passed

  dbf_file = upper(dbf_file)

  IF .not. used(dbf_file)     &&  if data file not open

    = poperror('Data table specified in the '+;
               'function MEAN is not open.  '+;
               'Function will return a divide overflow.')
    rvalue = 1/0

  ELSE

    SELECT(dbf_file)

    IF type('&dbf_file->&d_field') # 'N'
      = poperror('No numeric field in the '+dbf_file+;
                 ' data table called ' + d_field +;
                 '.  Function MEAN will return a '+;
                 'divide overflow.')
      rvalue = 1/0
    ENDIF

  ENDIF

ENDIF

IF rvalue = 0                 &&  if we got thru the mess
  AVERAGE &d_field TO rvalue  &&  do what we need to do
ENDIF

SELECT(cur_buff)              &&  reset to original buffer

IF cur_comp                   &&  dBase IV compatibility
  SET COMPAT on
ENDIF

RETURN(rvalue)
