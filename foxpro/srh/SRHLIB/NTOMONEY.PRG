FUNCTION ntomoney
PARAMETERS quant
PRIVATE quant, quant, amt, thou, hund, cnts, rvalue

************************************************************
*  ntomoney(<expN>)                                        *
*  Version # 1.0  FP          Date:  02-01-90              *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Converts numeric quantity to a character string   *
*  containing the written out dollars and cents.           *
************************************************************

rvalue = ''

IF quant > 999999.99
  RETURN('Dollar value too large to print using NTOMONEY') 
ENDIF

***  break the number into its parts

amt = transform(quant,'999999.99')
thou = val(subst(amt,1,3))
hund = val(subst(amt,4,3))
cnts = val(subst(amt,8,2))

***  assemble the character string

IF thou # 0               &&  we have thousands
  thou = ntoengl(thou)
ELSE 
  thou = ''
ENDIF

IF hund # 0               &&  we have hundreds
  hund = ntoengl(hund)
ELSE
  hund = ''
ENDIF

IF cnts # 0               &&  we have cents
  cnts = ntoengl(cnts)
ELSE
  cnts = ''
ENDIF


rvalue = iif(len(thou) = 0,'',thou + 'Thousand ') +;
         iif(len(hund) = 0,'',hund)

rvalue = iif(len(rvalue) = 0,'Zero Dollars and ',rvalue + ;
             ' Dollars and ')

rvalue = iif(rvalue = 'One Dollars and ','One Dollar and ',;
             rvalue)

rvalue = rvalue + iif(len(cnts) = 0,'Zero',cnts) + ' Cents'

RETURN(rvalue)