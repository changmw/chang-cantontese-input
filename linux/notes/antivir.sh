#!/bin/bash
fname=$1
src="vdf_fusebundle.zip"
if [ -z $1 ] ; then
	fname=$source
fi
mkdir /home/toylet/new/virus
cd /home/toylet/new/virus
# wget -N "http://dl4.avgate.net/down/vdf/$src"
# wget -N "http://dl4.antivir.de/package/fusebundle/win32/int/$src"
# 32-bit
wget -N "http://go.microsoft.com/fwlink/?linkid=70631"
mv -f "index.html?linkid=70631" mpas-fe.exe
# 64-bit
wget -N "http://go.microsoft.com/fwlink/?linkid=70632"
mv -f "index.html?linkid=70632" mpas-fex64.exe
exit 0
oldsrc="ivdf_fusebundle_nt_en.zip"
# wget -N "http://dl4.avgate.net/down/vdf/$oldsrc"
