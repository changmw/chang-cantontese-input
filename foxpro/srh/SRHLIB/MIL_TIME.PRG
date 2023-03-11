FUNCTION mil_time
PARAMETERS pass_time
PRIVATE pass_time, rvalue, hr_loc, hr_time

************************************************************
*  mil_time(<expC>)                                        *
*  Version # 1.0  FP          Date: 12-06-89               *
*  Programmed by: Malcolm C. Rubel                         *
*                                                          *
*  Copyright (c) 1989                                      *
*  Performance Dynamics Associates                         *
*  All Rights Reserved                                     *
*                                                          *
*  Note: Function converts any time to military time and   *
*  removes leading and trailing blanks.  If time is in     *
*  12-hour format and time in AM, function removes 'a'     *
*  from the end of string.  If time is in PM, function     *
*  removes the 'p' and adds 12 hours to the time string.   *
*  If there is no 'a' or 'p' designator, the function      *
*  assumes that the time string is already in 24-hour      *
*  format and returns passed string minus leading and      *
*  trailing blanks.                                        *
************************************************************

***  check to make sure that string is a character string

IF type('pass_time') # 'C' .or. isalpha(pass_time)
  = poperror('The parameter passed to the '+;
             'function MIL_TIME is not a '+;
             'character time string.  Function '+;
             ' will return "00:00".')
  RETURN('00:00')
ELSE
  pass_time = lower(pass_time)   && convert A to a & P to p
ENDIF

pass_time = alltrim(pass_time)   &&  trim off all blanks

DO CASE

***  time passed in 12-hour time mode and is AM

  CASE at('a',pass_time) # 0  
    rvalue = substr(pass_time,1,at('a',pass_time)-1)

***  add leading zero if necessary

    IF val(rvalue) < 10 .and. at('0',rvalue) # 1
      rvalue = '0' + rvalue   &&  add leading zero
    ENDIF

***  check for 12:35 AM  which should be 00:35 mil_time

    IF rvalue = '12'        
      rvalue = "00" + substr(rvalue,3)
    ENDIF

***  time passed in 12-hour time mode and is PM

  CASE at('p',pass_time) # 0
    rvalue = substr(pass_time,1,at('p',pass_time)-1)
    hr_loc = at(':',pass_time)

    IF hr_loc # 0             &&  if a valid time string
      hr_time = val(substr(pass_time,1,hr_loc-1))

***  check to make sure that no-one is messing with 
***  our minds!  Also takes care of "12:35p" which is
***  not 24:35 in military time.

      IF hr_time < 12        
        hr_time = hr_time + 12
      ENDIF

      hr_time = ltrim(str(hr_time))
      rvalue = hr_time + substr(rvalue,hr_loc)
    ELSE
      = poperror('Time string passed to the '+;
                 'function MIL_TIME was not in '+;
                 'the proper format.  Function '+;
                 'will return "00:00".')
      rvalue = '00:00'
    ENDIF

  OTHERWISE                   &&  if already a 24-hr time
    rvalue = pass_time

***  add leading zero if necessary  (1:45 = 01:45

    IF val(rvalue) < 10 .and. at('0',rvalue) # 1
      rvalue = '0' + rvalue
    ENDIF

ENDCASE

RETURN(trim(rvalue))
