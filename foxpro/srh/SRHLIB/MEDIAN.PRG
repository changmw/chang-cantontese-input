FUNCTION median
PARAMETERS d_field, dbf_file
PRIVATE d_field pcount, cur_buff, cur_comp, alias, pcount
PRIVATE rvalue, cur_order, cur_key, key_field, num_elems
PRIVATE mcenter, idx_no

************************************************************
*  median(<expC1>[,<expC2>])                               *
*  Version # 1.0              Date: 02-14-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the median value for the named   *
*  field in the current data table.  If the second         *
*  parameter is specified, the function will work on the   *
*  specified field in the specified data table.  Function  *
*  returns the median of the field.  The median is the     *
*  middle number of a set of numbers containing an odd     *
*  number of elements or the average of the two middle     *
*  elements in a set with an even number of elements.      *
*  Function will create a temporary index before it        *
*  determines the median if necessary.                     *
*  Function also allows you to calculate the mode when a   *
*  filter is applied to the data table.                    *
************************************************************

pcount = parameters()

rvalue = 0                    &&  starting value

cur_comp = set('compat') = 'ON' &&  dBase IV compatibility
SET COMPAT off
cur_buff = select()

d_field = alltrim(upper(d_field))

IF pcount = 1
  alias = alias()

***  if the current buffer does not contain a data table

  IF len(alias) = 0
    = poperror('No data table specified for the '+;
               'function MEDIAN.  Function will '+;
               'return a divide overflow.')
    rvalue = 1/0

  ELSE

***  if field that we are trying to calculate the median on
***  is not numeric

    IF type('&alias->&d_field') # 'N'
      = poperror('No numeric field in the ' + alias +;
                 ' data table called ' + d_field +;
                 '.  Function MEDIAN will return a '+;
                 'divide overflow.')
      RVALUE = 1/0
    ENDIF

  ENDIF

ELSE                          &&  if two parameters passed

  dbf_file = upper(dbf_file)

  IF .not. used(dbf_file)     &&  if data file not open
    = poperror('Data table specified in the '+;
               'function MEDIAN is not open.  '+;
               'Function will return a divide overflow.')
    rvalue = 1/0

  ELSE

    SELECT(dbf_file)

    IF type('&dbf_file->&d_field') # 'N'
      = poperror('No numeric field in the '+dbf_file+;
                 ' data table called ' + d_field +;
                 '.  Function MEDIAN will return a '+;
                 'divide overflow.')
      rvalue = 1/0
    ENDIF

  ENDIF

ENDIF

IF rvalue = 0                 &&  if we have gotten this far
  cur_order = setorder()      &&  cur. active index number

***  check to see if the required index is open

  idx_no = isindex(d_field)

  IF idx_no # 0               &&  if there is an open index
    SET ORDER TO idx_no
  ELSE                        &&  no match

***  no index available to use, go and create it

    = saveord()               &&  save the current index set
    INDEX ON &d_field to jbqrzt
    SET INDEX TO jbqrzt
  ENDIF

***  find out how many elements are in series

  IF len(filter()) = 0        &&  if no filter set
    num_elems = reccount()
  ELSE                        &&  if a filter is set
    num_elems = 0
    GO TOP

***  go through the file counting the number of records
***  to be included.

    DO WHILE .not. eof()
      num_elems = num_elems + 1  
      SKIP
    ENDDO

  ENDIF

  mcenter = num_elems/2       &&  the center record
  GO TOP

  IF mod(num_elems,2) = 0     &&  even number of points
    SKIP mcenter -1           &&  go to middle records
    rvalue = &d_field         &&  first record
    SKIP
    rvalue = (rvalue + &d_field) /2
  ELSE
    SKIP mcenter - 1
    rvalue = &d_field
  ENDIF

  IF 'JBQRZT' $ order() 
    SET INDEX TO
    ERASE jbqrzt.qzz
    = resetord()              &&  restore index order
  ENDIF

  = setorder(cur_order)       &&  set active index

ENDIF

SELECT(cur_buff)

IF cur_comp                   &&  dBase IV compatibility
  SET COMPAT on
ENDIF

RETURN(rvalue)