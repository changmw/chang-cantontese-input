FUNCTION mode
PARAMETERS d_field, dbf_file
PRIVATE d_field, dbf_file,  pcount, cur_buff, cur_comp 
PRIVATE alias, pcount, cur_order, num_elems, idx_no, marker
PRIVATE mark, mark1, mark2, m_count, m1_count, m2_count
PRIVATE rvalue

************************************************************
*  mode(<expC1>[,<expC2>])                                 *
*  Version # 1.0  FP          Date: 02-14-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns the mode of a numeric field in   *
*  a data table.  Mode is defined as that number that      *
*  occurs most frequently in the series.  If there is no   *
*  number that occurs more than once, the function returns *
*  a 0.  If the series has more than one solution (if the  *
*  set is bimodal) the function pops a message to this     *
*  fact and returns a 0 also.  Otherwise, the function     *
*  returns the number that occurs most often in the        *
*  series. MODE assumes that the data table is indexed on  *
*  target field.  If it is not, the function will create a *
*  temporary index for its calculations.                   *
*  Function also allows you to calculate the mode when a   *
*  filter is applied to the data table.                    *
************************************************************

pcount = parameters()

rvalue = 0                    &&  starting value
mark = 0
mark1 = 0
mark2 = 0 
m_count = 0
m1_count = 0
m2_count = 0

cur_comp = set('compat') = 'ON' &&  dBase IV compatibility
SET COMPAT off
cur_buff = select()
d_field = alltrim(upper(d_field))

IF pcount = 1

  alias = alias()

  IF len(alias) = 0           &&  open buffer
    = poperror('No data table specified for the '+;
               'function MODE.  Function will '+;
               'return a divide overflow.')
    rvalue = 1/0

  ELSE

    IF type('&alias->&d_field') # 'N'  && no field by that name
      = poperror('No numeric field in the ' + alias +;
                 ' data table called ' + d_field +;
                 '.  Function MODE will return a '+;
                 'divide overflow.')
      rvalue = 1/0
    ENDIF

  ENDIF

ELSE                          &&  if two parameters passed

  dbf_file = upper(dbf_file)

  IF .not. used(dbf_file)     &&  if data file not open

    = poperror('Data table specified in the '+;
               'function MODE is not open.  '+;
               'Function will return a divide overflow.')
    rvalue = 1/0

  ELSE

    SELECT(dbf_file)

    IF type('&dbf_file->&d_field') # 'N'
      = poperror('No numeric field in the '+dbf_file+;
                 ' data table called ' + d_field +;
                 '.  Function MODE will return a '+;
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

  mark = 0                    &&  start working on the MODE
  GO TOP

  FOR i = 1 to num_elems      &&  go through the file

    marker = &d_field         &&  current element

    IF mark # marker          &&  not the same as the last?
      mark = marker           &&  reset mark
      m_count = 1             &&  reset counter
    ELSE
      m_count = m_count + 1   &&  add one to counter

      IF m_count >= m1_count  &&  new large number
        m1_count = m_count
        mark1 = mark          &&  write to marker
      ENDIF

      IF m1_count > m2_count  &&  if number is the largest
        m2_count = m1_count   &&  write it to the last mark
        mark2 = mark1
      ENDIF

    ENDIF

    SKIP

  ENDFOR

  IF 'JBQRZT' $ order() 
    SET INDEX TO
    ERASE jbqrzt.qzz
    = resetord()              &&  restore index order
  ENDIF

  = setorder(cur_order)       &&  set active index

ENDIF

DO CASE

  CASE m1_count <= 1           &&  we have no mode
    = popmess('Field named in MODE has no value '+;
              'that occurs more than once.  '+;
              'The function will return a zero.')
    rvalue = 0

***  series has two different numbers with the same count

  CASE m1_count = m2_count .and.  mark1 # mark2
    mark1 = ltrim(str(mark1))
    mark2 = ltrim(str(mark2))
    m2_count = ltrim(str(m2_count))
    = popmess('Field named in MODE is '+;
              'bimodal.  The numbers '+ mark2 +;
              ' and '+  mark1 + ' both occur ' +;
               m2_count + ' times.  The function '+;
              'will return zero.')
    rvalue = 0

  OTHERWISE 
    rvalue = mark2

ENDCASE

SELECT(cur_buff)

IF cur_comp                   &&  dBase IV compatibility
  SET COMPAT on
ENDIF

RETURN(rvalue)