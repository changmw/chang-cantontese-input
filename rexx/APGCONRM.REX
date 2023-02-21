/*********************************************************************/
/*                                                                   */
/*  Program Structure :                                              */
/*  =================                                                */
/*                                                                   */
/* 1. The facility maintenance form includes 2 panels :              */
/*                                                                   */
/*     Classification  :  IBM Internal Use Only                      */
/*                                                                   */
/*     Owner        :  Jacqueline Chiu, HQ OPS                       */
/*                                                                   */
/*     Author       :  Chang Man Wai, HQ OPS                         */
/*                                                                   */
/*     Description  :  This exec provides conference room bienance   */
/*                     service for APG users                         */
/*                                                                   */
/*     Date         :  November 16, 1988                             */
/*                                                                   */
/*                                                                   */
/*  Program Structure :                                              */
/*  =================                                                */
/*                                                                   */
/*  1. The whole conference room booking form system contains 6      */
/*     panels and several XEDIT macros for help information:         */
/*        Panel 1 : APGCONF0  -- for selection of action             */
/*        *********** Data Collection Panels ****************        */
/*        Panel 2 : APGCONF1  -- for Booking of conference room      */
/*        Panel 3 : APGCONF2  -- for change of booking               */
/*        Panel 4 : APGCONF3  -- for cancellation of booking         */
/*        Panel 5 : APGCONF8  -- for attendee list 1                 */
/*        Panel 6 : APGCONF9  -- for attendee list 2                 */
/*                                                                   */
/* 2. User will first choose the appropriate action from Panel 1.    */
/*                                                                   */
/* 3. User then complete the necessary information in Panel 2/3/4    */
/*                                                                   */
/* 4. If it is a new booking, a booking number will be assigned to   */
/*    the booking transaction. The key is produced from the last 4   */
/*    digits of the conference room number and the starting date and */
/*    time.                                                          */
/*                                                                   */
/* 5. If the user is to make a new booking or want to change the     */
/*    information of an old booking, user will then go through the   */
/*    Panel 5 and 6.                                                 */
/*                                                                   */
/* 6. The request detail will be moulded into a PROFS note and sent  */
/*    to the server (id1). A copy will be filed in a user notelog    */
/*    whose name is specified by the user. That copy of PROFS note   */
/*    will contain the booking number generated for future reference */
/*********************************************************************/
 
address 'COMMAND'
n.1 = 26     /* no. of fields in attendee list screen 1 */
n.2 = 26     /* no. of fields in attendee list screen 2 */
id1 = 'CHANGMW'         /* the booking office's id */
id1node = 'HKGVMAPG'    /* the booking office's node id */
confroom_list = 'APGCONRM LIST A' /* the file that contains conf. room info */
 
/* end of user dependent variables */
 
req_file = 'APGCONRM $$REQ A' /* record holding request details */
call init_data
'EUDEXEC2'
 
/* Conference Room Booking Panel 1 -- Select Action */
 
CONF0:
pos = 'MSG'
msg = ''
do forever
   address 'DISPLAY'
   use apgconf0
   call format_panels
   call map_conf0
   'CURSOR' pos
   'DISPLAY'
   msg = ''
   select
      when rstatus = 'PF1' then
         do
            action = 'a'
            signal CONF1
         end
      when rstatus = 'PF2' then
         do
            action = 'c'
            signal CONF2
         end
      when rstatus = 'PF3' then
         do
            action = 'd'
            signal CONF3
         end
      when rstatus = 'PF12' then
         leave
      otherwise
         msg = 'Please use the correct PF keys!'
   end
end
exit
 
/* Conference room booking Panel 2 -- Book conference room */
 
CONF1:
pos = 'TOPIC_1'
msg = ' '
finish = 0
do forever
   address 'DISPLAY'
   use apgconf1
   'CASE M'
   call format_panels
   call map_conf1
   'CURSOR' pos
   'DISPLAY'
   msg = ' '
   select
      when rstatus = 'PF1' | rstatus = 'PF13' then
         do
            address 'COMMAND'
            'XEDIT ' confroom_list ' (PROFILE APGCONRM'
            address 'DISPLAY'
         end
      when rstatus = 'ENTER' then
         call check_conf1
      when rstatus = 'PF2' | rstatus = 'PF14' then
         do
            call check_conf1
            data_valid = RESULT
            if data_valid then
               signal conf8
         end
      when rstatus = 'PF12' | rstatus = 'PF24' then
         leave
      otherwise
         msg = 'Please use the correct PF key!'
   end
end
exit
 
/* Conference room booking Panel 3 -- change of booking */
 
CONF2:
pos = 'OLD_BOOKNO'
msg = ' '
finish = 0
do forever
   address 'DISPLAY'
   use apgconf2
   'CASE M'
   call format_panels
   call map_conf2
   'CURSOR' pos
   'DISPLAY'
   msg = ' '
   select
      when rstatus = 'PF1' | rstatus = 'PF13' then
         do
            address 'COMMAND'
            'XEDIT ' confroom_list ' (PROFILE APGCONRM'
            address 'DISPLAY'
         end
      when rstatus = 'ENTER' then
         call check_conf2
      when rstatus = 'PF2' | rstatus = 'PF14' then
         do
            call check_conf1
            data_valid = RESULT
            if data_valid then
               signal conf8
         end
      when rstatus = 'PF12' | rstatus = 'PF24' then
         leave
      otherwise
         msg = 'Please use the correct PF key!'
   end
end
exit
 
/* Conference Room Booking Panel 4 -- Cancel Booking */
 
CONF3:
pos = 'OLD_BOOKNO'
msg = ''
finish = 0
do forever
   address 'DISPLAY'
   use apgconf3
   call format_panels
   call map_conf3
   'CURSOR' pos
   'DISPLAY'
   msg = ''
   select
      when rstatus = 'ENTER' then
         call check_conf3
      when rstatus = 'PF2' | rstatus = 'PF14' then
         do
            call check_conf3
            data_valid = RESULT
            if data_valid then
               do
                  call send_note
                  call send_file
                  leave
               end
         end
      when rstatus = 'PF12' | rstatus = 'PF24' then
         leave
      otherwise
         msg = 'Please use the correct PF keys!'
   end
end
exit
 
/* Conference room booking Panel 5 -- attendee list 1 */
 
CONF8:
pos = 'CONF.1.1'
msg = ' '
send = 0
next = 0
do forever
   address DISPLAY
   use apgconf8
   'CASE M'
   call format_panels
   call map_conf8
   'CURSOR' pos
   'DISPLAY'
   msg = ' '
   select
      when rstatus = 'ENTER' then
         nop
      when rstatus = 'PF7' | rstatus = 'PF19' then
         do
            call send_note
            call send_file
            leave
         end
      when rstatus = 'PF10' | rstatus = 'PF22' then
         signal conf9
      when rstatus = 'PF12' | rstatus = 'PF24' then
         leave
      otherwise
         msg = 'Please use the right PF key!'
   end
end
exit
 
/* Conference room booking Panel 6 -- attendee list 2 */
 
CONF9:
previous = 0
send = 0
msg = ' '
pos = 'CONF.2.1'
do forever
   address 'DISPLAY'
   use apgconf9
   'CASE M'
   call format_panels
   call map_conf9
   'CURSOR' pos
   'DISPLAY'
   msg = ' '
   select
      when rstatus = 'ENTER' then
         nop
      when rstatus = 'PF7' | rstatus = 'PF19' then
      do
         call send_note
         call send_file
         leave
      end
   when rstatus = 'PF11' | rstatus = 'PF23' then
      signal conf8
   when rstatus = 'PF12' | rstatus = 'PF24' then
      leave
   otherwise
      msg = 'Please use the right PF keys!'
end
exit
 
/* Map unload list and load list to DMS */
 
MAP_CONF0:
'MAP DATA 1 MSG'
return
 
MAP_CONF1:
'MAP DATA',
' 1 TOPIC_1 2 CONF_ROOM',
' 3 FROM_HOUR  4 FROM_MIN  5 FROM_DAY  6 FROM_MONTH  7 FROM_YEAR',
' 8 TO_HOUR    9 TO_MIN   10 TO_DAY   11 TO_MONTH   12 TO_YEAR',
'13 COORNAME  14 COOR_ID  15 COOR_LOC 16 COOR_EXT   17 MSG'
return
 
MAP_CONF2:
'MAP DATA',
' 1 OLD_BOOKNO 2 TOPIC_1   3 CONF_ROOM',
' 4 FROM_HOUR  5 FROM_MIN  6 FROM_DAY  7 FROM_MONTH  8 FROM_YEAR',
' 9 TO_HOUR   10 TO_MIN   11 TO_DAY   12 TO_MONTH   13 TO_YEAR',
'14 COORNAME  15 COOR_ID  16 COOR_LOC 17 COOR_EXT   18 MSG'
return
 
MAP_CONF3:
'MAP DATA',
' 1 OLD_BOOKNO 2 MSG'
return
 
MAP_CONF8:
'MAP DATA',
' 1 CONF.1.1  2 CONF.1.2  3 CONF.1.3  4 CONF.1.4  5 CONF.1.5  6 CONF.1.6',
' 7 CONF.1.7   8 CONF.1.8   9 CONF.1.9  10 CONF.1.10 11 CONF.1.11',
'12 CONF.1.12 13 CONF.1.13 14 CONF.1.14 15 CONF.1.15 16 CONF.1.16',
'17 CONF.1.17 18 CONF.1.18 19 CONF.1.19 20 CONF.1.20 21 CONF.1.21',
'22 CONF.1.22 23 CONF.1.23 24 CONF.1.24 25 CONF.1.25 26 CONF.1.26',
'27 MSG'
return
 
MAP_CONF9:
'MAP DATA',
' 1 CONF.2.1  2 CONF.2.2  3 CONF.2.3  4 CONF.2.4  5 CONF.2.5  6 CONF.2.6',
' 7 CONF.2.7   8 CONF.2.8   9 CONF.2.9  10 CONF.2.10 11 CONF.2.11',
'12 CONF.2.12 13 CONF.2.13 14 CONF.2.14 15 CONF.2.15 16 CONF.2.16',
'17 CONF.2.17 18 CONF.2.18 19 CONF.2.19 20 CONF.2.20 21 CONF.2.21',
'22 CONF.2.22 23 CONF.2.23 24 CONF.2.24 25 CONF.2.25 26 CONF.2.26',
'27 MSG'
return
 
/* Beautify the data fields : literal fields are left-justified */
/* numeric fields are right-justified */
 
FORMAT_PANELS:
   address 'COMMAND'
   old_bookno = translate(left(old_bookno, 14), '_',' ')
   topic_1 = translate(left(topic_1, 35),'_',' ')
   conf_room = translate(left(conf_room, 4),'_',' ')
   coorname = translate(left(coorname, 31),'_',' ')
   coor_id = translate(left(coor_id, 8),'_',' ')
   coor_loc = translate(left(coor_loc, 4),'_',' ')
   coor_ext = translate(left(coor_ext, 4),'_',' ')
   from_hour = translate(right(from_hour, 2),'0',' ')
   from_min= translate(right(from_min, 2),'0',' ')
   from_day= translate(right(from_day, 2), '0', ' ')
   from_month=translate(right(from_month, 2), '0', ' ')
   from_year=translate(right(from_year, 4), '0', ' ')
   to_hour=translate(right(to_hour, 2), '0', ' ')
   to_min=translate(right(to_min, 2), '0', ' ')
   to_day=translate(right(to_day, 2), '0', ' ')
   to_month=translate(right(to_month, 2), '0', ' ')
   to_year=translate(right(to_year, 4), '0', ' ')
   do i = 1 to 2
      do j = 1 to n.i
         conf.i.j = strip(translate(conf.i.j,' ','_'))
         conf.i.j = translate(left(conf.i.j, 36),'_',' ')
      end
   end
return
 
/* Blank the data fields for initial display */
 
INIT_DATA:
   address 'COMMAND'
   old_bookno = ''
   topic_1 = ''
   conf_room = ''
   coorname = ''
   coor_id = ''
   coor_loc = ''
   coor_ext = ''
   from_hour='hh';from_min='mm'
   from_day='dd';from_month='mm';from_year='yyyy'
   to_hour='hh';to_min='mm'
   to_day='dd';to_month='mm';to_year='yyyy'
   do i = 1 to 2
      do j = 1 to n.i
         conf.i.j = ''
      end
   end
return
 
/* This program checks the data collected from Panel 2 -- */
/* book conference room. Return 0 if there is error; return 1 if OK */
 
CHECK_CONF1:
   address 'COMMAND'
   if conf_room = '' then
      do
         msg = 'Confernece room not specified'
         pos = 'CONF_ROOM'
         return 0
      end
   else
      do  /* check if conference room number is valid */
        'EXECIO * DISKR 'confroom_list' (FINIS FIND /'conf_room'/ ZONE 9 12 SKIP'
        if rc^=0 then
           do
              msg = 'Invalid conference room number'
              pos = 'CONF_ROOM'
              return 0
           end
      end
   call check_time from_hour from_min
   time_valid = RESULT
   if ^time_valid then
      do
         msg = 'Invalid starting time'
         pos = 'FROM_HOUR'
         return 0
      end
   call check_date from_day from_month from_year
   date_valid = RESULT
   if ^date_valid then
      do
         msg = 'Invalid starting date'
         pos = 'FROM_DAY'
         return 0
      end
   call check_time to_hour to_min
   time_valid = RESULT
   if ^time_valid then
      do
         msg = 'Invalid ending time'
         pos = 'TO_HOUR'
         return 0
      end
   call check_date to_day to_month to_year
   date_valid = RESULT
   if ^date_valid then
      do
         msg = 'Invalid ending date'
         pos = 'TO_DAY'
         return 0
      end
   /* compare the starting and ending date and time */
   from_date = from_year from_month from_day from_hour from_min
   to_date = to_year to_month to_day to_hour to_min
   if to_date < from_date then
      do
         msg = 'Ending date & time is earlier than starting date & time'
         pos = 'TO_HOUR'
         return 0
      end
   if to_date = from_date then
      do
         msg = 'Ending date & time same as starting date & time'
         pos = 'TO_HOUR'
         return  0
      end
   coorname = strip(translate(coorname, ' ', '_'))
   if coorname = ' ' then
      do
          msg = 'Requester name must be entered'
          pos = 'COORNAME'
          return  0
      end
   coor_id=strip(translate(coor_id, ' ', '_'))
   if coor_id = ' ' then
      do
          msg = 'Contact point userid must be entered'
          pos = 'COOR_ID'
          return 0
      end
   coor_loc = strip(translate(coor_loc, ' ', '_'))
   if coor_loc = ' ' then
      do
         msg = 'Contact point location must be entered'
         pos = 'COOR_LOC'
         return 0
      end
   if length(coor_loc) < 4 then
      do
         msg = 'Invalid coordinator location'
         pos = 'COOR_LOC'
         return 0
      end
   coor_ext = strip(translate(coor_ext, ' ','_'))
   if coor_ext = ' ' then
      do
         msg = 'Contact point phone number must be present'
         pos = 'COOR_EXT'
         return 0
      end
   if length(coor_ext) < 4 then
      do
         msg = 'Invalid coordiation extension'
         pos = 'COOR_EXT'
         return 0
      end
   if datatype(coor_ext)^='NUM' then
      do
          msg = 'Telephone extension must be numbers only'
          pos = 'COOR_EXT'
          return 0
      end
    return 1
exit
 
/* This procedure checks whether the data collected in Panel 2 -- */
/* Change of Booking, is correct */
 
CHECK_CONF2:
/* Check the data fields entered in Panel 4 -- Change booking informtion */
/* return 1 if OK! return 0 otherwise */
   call check_conf3
   data_valid1 = RESULT
   if data_valid1 then
      do
         call check_conf1
         data_valid2 = RESULT
      end
   else
      data_valid2 = 0
   return (data_valid1 * data_valid2)
exit
 
/* this function checks whether the data collected from Panel 3 - */
/* cancellation of booking */
/* return 1 if OK; return 0 otherwise */
 
CHECK_CONF3:
   old_bookno = strip(translate(old_bookno,' ','_'))
   if old_bookno = '' then
      do
         pos = 'OLD_BOOKNO'
         msg = 'Please enter the original booking number!'
         return 0
      end
   if length(old_bookno) < 16 then
      do
         msg = 'Invalid booking number'
         pos = 'OLD_BOOKNO'
         return 0
      end
   if datatype(old_bookno) ^= 'NUM' then
      do
         msg = 'Only numbers are allowed in booking number'
         pos = 'OLD_BOOKNO'
         return 0
      end
   return 1
exit
 
/* This procedure checks whether a given time is correct or not */
/* return 0 if there is error; 1 otherwise */
 
CHECK_TIME:
   arg in_hour in_min
   address 'COMMAND'
   if datatype(in_hour)^='NUM' | datatype(in_min)^='NUM' then
      return 0
   else
      if (in_hour < 0) | (in_hour > 24) | (in_hour > 60) | (in_hour < 0) then
         return 0
      else
         return 1
return
 
/* This procedure checks whether a given date is correct or not */
/* return 0 if there is error; 1 otherwise */
 
CHECK_DATE:
   arg in_day in_month in_year
   address 'COMMAND'
   if datatype(in_day)^='NUM'|datatype(in_month)^='NUM'|datatype(in_year)^='NUM' then
      return 0
   cur_day = subword(date(),1, 1)
   cur_month = subword(date(), 2, 1)
   cur_month =(pos(cur_month, 'JanFebMarAprMayJunJulAugSepOctNovDec')-1)/3+1
   cur_year = subword(date(), 3, 1)
   call get_end_of_month in_month in_year
   max_day_limit = RESULT
   select
      when (in_day < 1) | (in_day > max_day_limit) then
         return 0
      when (in_month < 1) | (in_month > 12) then
         return 0
      when in_year = cur_year then
         select
            when in_month = cur_month then
               if in_day < cur_day then
                  return 0
               else
                  return 1
            when in_month > cur_month then
               return 1
            when in_month < cur_month then
               return  0
         end
      when in_year > cur_year then
         return 1
      when in_year < cur_year then
         return 0
   end
   return 1
exit
 
/* This function returns the the last day of a given month */
/* return 0 if the month given is invalid */
 
GET_END_OF_MONTH:
   arg i_month i_year
   address 'COMMAND'
   if (i_month//4=0) & (i_month = 2) then
      return 29
   else if (i_month = 1) | (i_month = 3) | (i_month = 5) | (i_month = 7) | (i_month = 8) | (i_month = 10) | (i_month = 12) then
      return 31
   else if (i_month = 4) | (i_month = 6) | (i_month = 9) | (i_month = 11) then
      return 30
   else
      return 0
exit
 
/* this function packs all information of the booking request */
/* into a record which will be sent to the conference room booking */
/* office. The record structure is given below: */
/* 1..16 : booking number           17 : action code       */
/* 18..23 : old booking number      24..58 : meeting name  */
/* 59..66 : starting date           67..70 : starting time */
/* 71..86 : ending date             87..90 : ending time   */
/* 91..115 : meeting coordinator's name    */
/* 116..127 : meeting coordinator's userid */
/* 128..131 : meeting coordinator's workstation number */
/* 132..135 : meeting coordinator's extension */
/* 135..    : array [] of array of [1..31] of attendee  */
 
SEND_FILE:
   address 'COMMAND'
   req_rec = action||old_bookno
   if action = 'a' | action = 'c' then
      do
         req_rec = req_rec||right(new_bookno,16)||left(topic_1,35)||conf_room
         req_rec = req_rec||from_year||from_month||from_day||from_hour||from_min
         req_rec = req_rec||to_year||to_month||to_day||to_hour||to_min
         req_rec = req_rec||left(coorname,25)||left(coor_id,8)||coor_loc||coor_ext
         str5 = ''
         do j = 1 to 2
            do k = 1 to n.j
               if conf.j.k ^= ' ' then
                  str5 = str5||left(conf.j.k, 31)
            end
         end
         req_rec = req_rec||str5||date()||time()
      end
   'SET CMSTYPE HT'
   'ERASE ' req_file
   'EXECIO 1 DISKW' req_file '(FINIS STRING' req_rec
   address 'CMS'
   'SENDFILE ' req_file ' TO ' id1 'AT' id1node '(NOTYPE'
   'ERASE 'req_file
   'SET CMSTYPE RT'
return
 
/* Make the request into a note form for filling in user note log */
/* a booking number will be made from conference room number+starting date */
/* +starting time, and assigned to the booking request */
 
SEND_NOTE:
   address 'COMMAND'
   call format_panels
   if action = 'a' | action = 'c' then
      new_bookno = conf_room||from_year||from_month||from_day||from_hour||from_min
   call note_log
   'SET CMSTYPE HT'
   MAKEBUF
   QUEUE id1node||'('||id1||')'              /* TO person : booking office */
   select
      when action = 'a' then
         QUEUE 'Conference Booking Form -- BOOKING'  /* Subject */
      when action = 'c' then
         QUEUE 'Conference Booking Form -- CHANGE'
      when action = 'd' then
         QUEUE 'Conference Booking Form -- CANCEL'
   end
   QUEUE ' '
   if action = 'd' then
      QUEUE 'Booking numbered 'old_bookno' will be deleted.'
   else
      do
         QUEUE 'Booking Number :' new_bookno
         QUEUE ' '
         if action = 'c' then
            do
               QUEUE 'The following data fields are changed:'
               QUEUE ' '
            end
         QUEUE 'Meeting name : ' translate(left(topic_1, 35),' ','_')
         QUEUE ' '
         QUEUE 'From: '||from_hour||':'||from_min||' of '||from_day||'/'||from_month||'/'||from_year
         QUEUE '  To: '||to_hour||':'||to_min||' of '||to_day||'/'||to_month||'/'||to_year
         QUEUE ' '
         QUEUE 'Conference Room : CONF'||translate(left(conf_room, 4),' ','_')
         QUEUE ' '
         QUEUE 'Contact point :'
         QUEUE ' '
         QUEUE '      Name: ' translate(left(coorname, 31),' ','_')
         QUEUE '    Userid: ' translate(left(coor_id,8),' ','_')
         QUEUE '  Location: ' translate(left(coor_loc,4),' ','_')
         QUEUE ' Extension: ' translate(left(coor_ext,4),' ','_')
         QUEUE ' '
         QUEUE 'List of attendees:'
         do j = 1 to n.1
            conf.1.j = translate(left(conf.1.j,36),' ','_')
            conf.2.j = translate(left(conf.2.j,36),' ','_')
            attendee_line = conf.1.j '       ' conf.2.j
            if attendee_line ^= ' ' then
               QUEUE attendee_line
         end
      end
   QUEUE '.lf ' notelog_name                 /* notelog name */
   QUEUE '.ak'                               /* acknowledgement */
   QUEUE                                /* signify end of note */
   PROFS TERMNL TTY
   PROFS NOTE
   PROFS TERMNL
   address COMMAND CP 'SLEEP 1 SEC'
   address 'COMMAND'
   DROPBUF
   'SET CMSTYPE RT'
   log1 = center(notelog_name, 8)
   'CLRSCRN'
   say ' '
   say '******************************************************'
   say '*                                                    *'
   say '*        The conference room booking form is sent    *'
   say '*           to 'id1' for processing                *'
   say '*                      and                           *'
   say '*   a copy is filed in your 'log1' OFSLOGfl A0     *'
   say '*                                                    *'
   say '* Booking number is 'new_bookno'. Use the number *'
   say '*   for future references                            *'
   say '*                                                    *'
   say '******************************************************'
   say ' '
   say '                               Press ENTER to continue'
   pull dummy
return
 
/* Put a copy of the booking request in a user-specified note-log */
/* for future references */
 
NOTE_LOG:
   address 'COMMAND'
   'CLRSCRN'
   notelog_name = ' '
   say ' '
   say '  **********************************************************'
   say '  *                                                        *'
   say '  *   Which PROFS note log you would like to save into?    *'
   say '  *  If you hit ENTER, it is saved to CONFROOM OFSLOGFl A0 *'
   say '  *                                                        *'
   say '  **********************************************************'
   pull notelog_name
   if notelog_name = ' ' then
      notelog_name = 'CONFROOM'
return
