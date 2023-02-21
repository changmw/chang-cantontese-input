/* IBM Internal Testing Only */
/* Author : Chang Man Wai    */
/* This program will prompt for control unit name first             */
/* Then it will send messages to the users who are connected to     */
/* that control unit. Good for warning users before re-IML control  */
/* units. You can alter the message by modifying the variable below */
/* Valid for SNA addresses only */
 
/* Enter the content of the note to be sent here */
 
subject1 = ''
note1=''
note2=''
note3=''
 
/* Enter the content of message to be sent here */
 
message1 = 'Due to cable errors'
message2 = 'control units are to be reset.'
message3 = 'Please LOGOFF now.'
message4 = 'Sorry for any inconvinience'
 
say 'FORCE -- Define the messages and note content by XEDITing'
say '         FORCE EXEC A'
hp='1DE8'x
ehp='1D60'x
do forever
  clrscrn
  say 'Controller:' cu
  say 'Command:'hp'C'ehp'ontroller 'hp'L'ehp'ist users '
  say '        'hp'N'ehp'ote users 'hp'W'ehp'arn users 'hp'Q'ehp'uit'
  pull option
  if ^(option = 'L' | option = 'W' | option = 'N' | option = 'C') then
    leave
 
  if option = 'C' then
    do
      say 'Enter new controller name:'
      pull cu
      iterate
    end
 
  'execio * cp (string CP Q N'
  'sentries'
 
  x=1
  do rc
    pull total
    do while total <> ''
      parse value total with single ',' total
      vmname.x=strip(single,b)
      x=x+1
    end
  end
 
  aaa=0   /* count the number of users affected */
  do y=1 to (x-1)
    parse value vmname.y with nname '-' logdsc
    if substr(logdsc,4,3)=cu then
      do
        aaa=aaa + 1
        select
          when option = 'W' then
            do
              'cp smsg' bluerscs 'msg' hkgvmapg nname message1
              'cp smsg' bluerscs 'msg' hkgvmapg nname message2
              'cp smsg' bluerscs 'msg' hkgvmapg nname message3
              'cp smsg' bluerscs 'msg' hkgvmapg nname message4
            end
          when option = 'L' then
            say vmname.y
          when option = 'N' then
            do
              address 'COMMAND'
              'SET CMSTYPE HT'
              MAKEBUF
              QUEUE nname
              QUEUE subject1
              QUEUE ' '
              QUEUE note1
              QUEUE note2
              QUEUE note3
              QUEUE ''   /* Signal end of note */
              PROFS TERMNL TTY
              PROFS NOTE
              PROFS TERMNL
              DROPBUF
              'SET CMSTYPE RT'
            end
        end
     end
   end
 dummy=' '
 say
 say aaa 'user(s) in session. Press ENTER to continue..'
 pull dummy
end
exit
