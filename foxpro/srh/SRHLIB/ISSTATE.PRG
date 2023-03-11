FUNCTION isstate
PARAMETERS s_abrev
PRIVATE s_abrev, st_str

************************************************************
*  isstate(<expC>)                                         *
*  Version # 1.0  FP          Date: 06-06-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: ISSTATE returns logical TRUE if the two-          *
*  character string passed is a valid state abbreviation.  *
*  The function returns logical FALSE if it is not.        *
************************************************************

DO CASE

  CASE type('s_abrev') # 'C'  &&  parameter is not character
    = poperror('The value passed to ISSTATE must be a '+;
               'character string.  Function will return '+;
               'logical FALSE.')
    rvalue = .f.

  CASE len(s_abrev) # 2       &&  is string too long
    = poperror('State abbreviation passed to ISSTATE '+;
               'must be two characters long.  Function '+;
               'will return logical FALSE.')
    rvalue = .f.

  CASE at(upper(s_abrev),'|AK|AL|AR|AS|AZ|CA|CO|CT|DC|DE'+;
       '|FL|FM|GA|GU|HI|IA|ID|IL|IN|KA|KS|KY|LA|MA|MD|ME'+;
       '|MH|MI|MN|MO|MP|MS|MT|NC|ND|NE|NH|NJ|NM|NV|NY|OH'+;
       '|OK|OR|PA|PR|PW|RI|SC|SD|TN|TX|UT|VA|VI|VT|WA|WI'+;
       '|WV|WY|') # 0
    rvalue = .t.

  OTHERWISE
    rvalue = .f.

ENDCASE

RETURN(rvalue)