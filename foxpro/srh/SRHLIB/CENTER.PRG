FUNCTION center
PARAMETERS message, width, offset
PRIVATE message, width, offset, sp_count, rvalue

************************************************************
*  center(<expC>[,<expN1>[,<expN2>]])                      *
*  Version # 1.0  FB          Date: 11-01-89               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1988, 1989                                *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function returns a character string 80 (or N2)    *
*  characters long with pad spaces at the beginning and    *
*  end of the string so that the message is centered.  If  *
*  a width parameter is passed, the string will be         *
*  centered in that width.  If none is passed the default  *
*  value of 80 is used.   If an offset is specified, the   *
*  offset value is added to (or subtracted from) the pad   *
*  spaces on the left side of the string.                  *
************************************************************

DO CASE                   &&  check to see what was passed

  CASE parameters() = 1   &&  only the string was passed
    width = 80
    offset = 0

  CASE parameters() = 2     &&  string plus width passed
    offset = 0

ENDCASE

sp_count = int((width - len(trim(message)))/2)

DO CASE

  CASE sp_count + offset < 0   &&  if offset too much
    sp_count = 0

  CASE sp_count < offset       &&  offset will work
    sp_count = width - len(trim(message))

ENDCASE

rvalue = space(sp_count + offset) + trim(message) +;
         space(sp_count - offset)

***  just in case,  fill in leftover blanks

rvalue = rvalue + space(width-len(rvalue))

RETURN(rvalue)