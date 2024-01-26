#!/bin/sh
#
# Saved Firewall Script is /tmp/.rc_firewall
#
myid=$0
pidfile=/var/run/rc_firewall.pid

logger -s -t changmw "[$$]: starting $myid"

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

if [ -f /opt/root/man.sh ] ; then
  logger -s -t changmw "[$$]: USB OK!"
else
  logger -s -t changmw "[$$]: USB Error!"
fi

# Remove lock file
rm -f $pidfile

logger -s -t changmw "[$$]: Exiting $myid"
exit 0
