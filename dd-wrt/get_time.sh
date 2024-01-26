#!/bin/sh
#
# DD-WRT :: View topic - Setting time using HTTP without NTP server nor service
# https://forum.dd-wrt.com/phpBB2/viewtopic.php?t=327369&highlight=ntp
# 
curl -I 'https://www.google.com/'  2>/dev/null | grep -i '^date:' | sed 's/^[Dd]ate: //g' | awk 'BEGIN{months="JanFebMarAprMayJunJulAugSepOctNovDec"}{printf("%s%02d%s%s", $4, index(months,$3)/3+1,$2,$5)}' | sed 's/://' | sed 's/:/./'
