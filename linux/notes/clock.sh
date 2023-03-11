#!/bin/bash
# http://www.linux.com/feature/124918
# clock.sh

# the script is executed inside a while without conditions
while :                                                                                  
do
 # time and date are formatted to show HH:MM:SS YYYY-MM-DD
 cmd=`date +"%H:%M:%S %F"`
 
 # cursor's current position is saved through an escape sequence
 echo -n -e "\033[s"

 # Uncomment the next two lines to clean up the whole first line, although it causes a lot of blinking
 #tput cup 0 0    # positions on row 0 col 0 (left top corner)
 #tput el         # cleans from position to end of line

 # to place the clock on the appropriate column, subtract the length of 'HH:MM:SS YYYY-MM-DD', which is 19,
 # from the total number of columns
 C=$((`tput cols` - 19))
 tput cup 0 $C    # positions cursor at row 0 col $C

 # clock will be shown green inverted
 # setaf 2 = green, smso = inverted
 COLOR=`tput setaf 2; tput smso`

 # back to normal screen colors
 NORMAL=`tput sgr0`
 
 # print the time-date output on the above position
 echo -n $COLOR$cmd$NORMAL
 
 # restore the cursor to whatever was its previous position
 echo -n -e "\033[u"
 
 # script is executed every second
 sleep 1
done

