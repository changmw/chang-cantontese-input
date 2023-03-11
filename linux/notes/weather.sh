#!/bin/bash
#
# http://linuxshellaccount.blogspot.com/2008/09/bash-script-to-get-weather-forecasts.html
#
# weather.sh - Now you can be wrong 50 percent of the time, too :)
#
# 2008 - Mike Golvach - eggi@comcast.net
#
# Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License
#

if [ $# -lt 1 ]
then
        echo "Usage: $0 Your Zip Code"
        echo "Ex: $0 60015"
        exit 1
fi

args="$@"
wget=/usr/bin/wget

if [ $# -gt 1 ]
then
        echo "Usage: $0 Your Zip Code"
        echo "Ex: $0 60015"
        exit 1
fi
echo

$wget -nv -O - "http://weather.weatherbug.com/Common/SearchResults.html?is_search=true&nav_section=1&loc_country=WORLD&zcode=z6286&loc=$args" 2>&1|grep -i "No matches found for your request" >/dev/null 2>&1

anygood=$?

if [ $anygood -eq 0 ]
then
        args=`echo $args|sed 's/%20/\+/g'`
        echo "No results found for $args"
        exit 2
fi

echo -n "Your Forecast:"

$wget -nv -O - "http://weather.weatherbug.com/Common/SearchResults.html?is_search=true&nav_section=1&loc_country=WORLD&zcode=z6286&loc=$args" 2>&1|grep -w For|grep h3|grep $args|sed -e :a -e 's/<[^>]*>/ /g;/</N;//ba' -e 's/$/\n/'

$wget -nv -O - "http://weather.weatherbug.com/Common/SearchResults.html?is_search=true&nav_section=1&loc_country=WORLD&zcode=z6286&loc=$args" 2>&1|sed -e :a -e 's/<[^>]*>/ /g;/</N;//ba' -e 's/$/\n/'|sed -e '1,/Your Forecast/d' -e '/7-Day Forecast/,$d'|sed -e '/^[ \t]*$/d' -e '/^$/N;/\n$/D' -e 's/[ \t]*more/... more\n/'|sed 's/°/Degrees/g'

exit 0
