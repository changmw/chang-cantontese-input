FUNCTION ntoengl
PARAMETERS value
PRIVATE value

************************************************************
*  ntoengl(<expN>)                                         *
*  Version # 1.0  FP          Date: 02-01-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function takes a numeric integer string <expN>    *
*  and converts it to an English character string denoting *
*  the same value.  Function works on any number from one  *
*  to 1999.  NTOENGL does not do decimals and returns a    *
*  null string when passed a zero.                         *
************************************************************

IF type('value') # 'N'
  = poperror('Parameter passed to the function '+;
             'NTOENGL is not a numeric string.  '+;
             'Function will return a null string.')
  RETURN('')
ENDIF

IF value < 0 .or. value >= 2000
  = poperror('Value passed to the function NTOENGL '+;
             'is out of its range.  Function will '+;
             'return a null string.')
  RETURN('')
ENDIF

value = int(value)            &&  get rid of decimals

IF value = 0                  &&  passed a zero
  RETURN('')                  &&  return a null char str.
ENDIF

***  finally, let's convert the number!

IF value <= 99                &&  if value is less than 100
  RETURN(c_dec(value))

ELSE                          &&  if over one hundred

  RETURN(c_teen(int(value/100)) + 'Hundred '+;
         iif(value-int(value/100)*100 = 0,'',;
         'and ' + c_dec(value-int(value/100)*100)))
ENDIF

********

FUNCTION c_dec
PARAMETERS d_value
PRIVATE d_value, svalue, tvalue

svalue = ''

DO CASE

  CASE d_value < 20
    RETURN(c_teen(d_value))

  CASE d_value < 30
    svalue = 'Twenty'
    d_value = d_value - 20

  CASE d_value < 40
    svalue = 'Thirty'
    d_value = d_value - 30

  CASE d_value < 50
    svalue = 'Forty'
    d_value = d_value - 40

  CASE d_value < 60
    svalue = 'Fifty'
    d_value = d_value - 50

  CASE d_value < 70
    svalue = 'Sixty'
    d_value = d_value - 60

  CASE d_value < 80
    svalue = 'Seventy'
    d_value = d_value - 70

  CASE d_value < 90
    svalue = 'Eighty'
    d_value = d_value - 80

  CASE d_value < 100
    svalue = 'Ninety'
    d_value = d_value - 90

ENDCASE

tvalue = c_teen(d_value)

IF len(tvalue) # 0           && there was something there
  svalue = svalue + '-' + tvalue
ENDIF

RETURN(trim(svalue))

********

FUNCTION c_teen
PARAMETERS t_value
PRIVATE t_value

DO CASE

  CASE t_value = 0
    RETURN('')

  CASE t_value = 1
    RETURN('One ')

  CASE t_value = 2
    RETURN('Two ')

  CASE t_value = 3
    RETURN('Three ')

  CASE t_value = 4
    RETURN('Four ')

  CASE t_value = 5
    RETURN('Five ')

  CASE t_value = 6
    RETURN('Six ')

  CASE t_value = 7
    RETURN('Seven ')

  CASE t_value = 8
    RETURN('Eight ')

  CASE t_value = 9
    RETURN('Nine ')

  CASE t_value = 10
    RETURN('Ten ')

  CASE t_value = 11
    RETURN('Eleven ')

  CASE t_value = 12
    RETURN('Twelve ')

  CASE t_value = 13
    RETURN('Thirteen ')

  CASE t_value = 14
    RETURN('Fourteen ')

  CASE t_value = 15
    RETURN('Fifteen ')

  CASE t_value = 16
    RETURN('Sixteen ')

  CASE t_value = 17
    RETURN('Seventeen ')

  CASE t_value = 18
    RETURN('Eighteen ')

  CASE t_value = 19
    RETURN('Nineteen ')

ENDCASE