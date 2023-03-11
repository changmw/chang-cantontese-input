FUNCTION civ_time
PARAMETERS pass_time
PRIVATE pass_time, c_hrs, c_mins, c_secs, c_merid, rvalue

************************************************************
*  civ_time(<expC>)                                        *
*  Version # 1.0  FP          Date: 11-29-90               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1990                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts military time back to civilian  *
*  AM/PM format.  The function deals with military time    *
*  expressed with or without colons dividing the hours,    *
*  minutes, and seconds.
************************************************************

IF type('pass_time') # 'C' .or. isalpha(pass_time)
  = poperror('The parameter passed to the '+;
             'function CIV_TIME is not a proper '+;
             'character time string.  Function '+;
             'will return "00:00".')
  RETURN('00:00')
ENDIF

***  check to see if the time string already has an am/pm
***  marker on it.  If it does, return the passed string.

c_hrs = lower(pass_time)

IF 'a' $ c_hrs .or. 'p' $ c_hrs
  RETURN(pass_time)
ENDIF

***  make sure there are two digits for hours

IF at(':',pass_time) = 2
  pass_time = '0' + pass_time
ENDIF

***  strip out the colons if they are there

DO WHILE .t.

  IF ':' $ pass_time
    pass_time = stuff(pass_time,at(':',pass_time),1,'')
  ELSE
    EXIT
  ENDIF

ENDDO

***  break apart the time string

c_hrs = val(substr(pass_time,1,2))
c_mins = substr(pass_time,3,2)
c_secs = substr(pass_time,5)
c_merid = 'a'

IF c_hrs >= 12                &&  noon or later
  c_merid = 'p'
  c_hrs = c_hrs - 12
ENDIF

***  check for time after midnight  (2401 hrs)

IF c_hrs = 12 .and. (val(c_mins) > 0 .or. ;
                     val(c_secs) > 0)
  c_hrs = 0 
  c_merid = 'a'
ENDIF

IF c_hrs = 0                  &&  just after midnight
  c_hrs = 12
ENDIF

rvalue = ltrim(str(c_hrs))

IF len(rvalue) = 1            &&  only one hour
  rvalue  = ' ' + rvalue
ENDIF

rvalue = rvalue + ':' + c_mins + iif(empty(c_secs),'',;
                  ':' + c_secs) + c_merid

RETURN(rvalue)