#!/bin/sh
#
# Saved Startup Script is /tmp/.rc_startup
#
myid=$0
pidfile=/var/run/rc_startup.pid

logger -s -t changmw "[$$]: starting $myid"

# linux - How to make sure only one instance of a bash script runs? - Unix & Linux Stack Exchange
# https://unix.stackexchange.com/questions/48505/how-to-make-sure-only-one-instance-of-a-bash-script-runs

if [ -f $pidfile ] ; then
  if [ "$(cat $pidfile)" != "$$" ] ; then
    logger -s -t changmw "[$$]: $myid already started by $(cat $pidfile)! Exiting 1."
    exit 1
  fi
else
  echo $$ > $pidfile
  sleep 1
  if [ "$(cat $pidfile)" != "$$" ] ; then
    logger -s -t changmw "[$$]: $myid error creating pidfile ($(cat $pidfile))! Exiting 2."
    exit 2
  fi
fi

# Do stuff
# ...

if [ -z "$(lsusb | grep 0781:5583)" ] ; then
  logger -s -t changmw "[$$]: Reseating USB Controller 0000:00:0c.0 ..."
  echo "0000:00:0c.0" > /sys/bus/pci/drivers/xhci_hcd/unbind
  echo "0000:00:0c.0" > /sys/bus/pci/drivers/xhci_hcd/bind
fi

logger -s -t changmw "[$$]: exiting $myid"

# Remove lock file
rm -f $pidfile
exit 0
