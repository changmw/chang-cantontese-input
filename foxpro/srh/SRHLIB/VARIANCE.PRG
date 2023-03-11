FUNCTION variance
PARAMETERS d_field, dbf_file
PRIVATE d_field, dbf_file, cur_buff, cur_comp, alias
PRIVATE mean, counter, pcount, rvalue

************************************************************
*  variance(<expC1>[,<expC2>])                             *
*  Version # 1.0  FP          Date: 02-14-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the statistical variance of the  *
*  numeric field specified in <expC1>.  If specified,      *
*  function will change to a different data file before    *
*  starting its calulations.  If a filter is set on the    *
*  named table, the function takes it into account.        *
************************************************************

pcount = parameters()

rvalue = 0                    &&  starting value
counter = 0

cur_comp = set('compat') = 'ON' &&  dBase IV compatibility
SET COMPAT off
cur_buff = select()

d_field = alltrim(upper(d_field))

IF pcount = 1

  alias = alias()

  IF len(alias) = 0           &&  open buffer
    = poperror('No data table specified for the '+;
               'function VARIANCE.  Function will '+;
               'return a divide overflow.')
    rvalue = 1/0

  ELSE

    IF type('&alias->&d_field') # 'N'  && no field
      = poperror('No numeric field in the ' + alias +;
                 ' data table called ' + d_field +;
                 '.  Function VARIANCE will return a '+;
                 'divide overflow.')
      RVALUE = 1/0
    ENDIF

  ENDIF

ELSE                          &&  if two parameters passed

  dbf_file = upper(dbf_file)

  IF .not. used(dbf_file)     &&  if data file not open

    = poperror('Data table specified in the '+;
               'function VARIANCE is not open.  '+;
               'Function will return a divide '+;
               'overflow.')
    rvalue = 1/0

  ELSE

    SELECT(dbf_file)          &&  select file

    IF type('&dbf_file->&d_field') # 'N'
      = poperror('No numeric field in the '+dbf_file+;
                 ' data table called ' + d_field +;
                 '.  Function VARIANCE will return a '+;
                 'divide overflow.')
      rvalue = 1/0
    ENDIF

  ENDIF

ENDIF

IF rvalue = 0                 &&  if we got thru the mess
  AVERAGE &d_field TO mean    &&  do what we need to do
  GO TOP

  DO WHILE .not. eof()
    rvalue = rvalue + (mean - &d_field)^2
    counter = counter + 1
    SKIP
  ENDDO

  rvalue = rvalue / counter

ENDIF

IF pcount = 2
  SELECT(cur_buff)            &&  go back to original
ENDIF

IF cur_comp                   &&  dBase IV compatibility
  SET COMPAT on
ENDIF

RETURN(rvalue)
