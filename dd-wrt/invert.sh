#!/bin/sh
#
# reverse a string using awk
#
x="welcome"

echo $x | awk \
'{ for(i = length; i!=0; i--) \
   x = x substr($0, i, 1); \
 } END \
 { print x }'

len=$(echo ${#x})
while [ $len -ne 0 ]
do
  y=$y`echo $x | cut -c $len`
  let len=len-1
done
echo $y
