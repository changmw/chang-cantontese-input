#!/bin/bash
# https://bugs.launchpad.net/ubuntu/+source/camgrab/+bug/344336
# isntall libv4l-0
# install libjasper-dev
# default: saved to shot.jpg
cd /home/toylet/public_html
LD_PRELOAD=/usr/lib/libv4l/v4l1compat.so camgrab
chmod 644 shot.jpg
#
# http://ubuntuforums.org/showthread.php?t=212624
#
# Image stamp it if `convert` is installed.
if [ -e /usr/bin/convert ]; then
convert -font helvetica -fill black -draw "text 10, 280 '`date`'" "$tempfile" "$tempfile"
fi 
