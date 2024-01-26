#!/bin/sh
#
dateFromServer=$(curl -I -v --silent https://www.google.com/ 2>&1 | grep Date | sed -e 's/Date: //')
echo $dateFromServer
date +"%d%m%Y%H%M%S" -d $dateFromServer
exit 0
dateFromServer=$(curl -v --silent https://nist.time.gov/ 2>&1 \ | grep '< Date' | sed -e 's/< Date: //'); date +"%d%m%Y%H%M%S" -d "$dateFromServer" but it would be better to use: dateFromServer=$(curl -v --silent https://nist.time.gov/ 2>&1 \ | grep '< Date' | sed -e 's/< Date: //'); date +"%Y-%m-%d %H:%M:%S" -d "$dateFromServer"
