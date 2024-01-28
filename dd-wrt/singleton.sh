#!/bin/sh
#
# linux - How to make sure only one instance of a bash script runs? - Unix & Linux Stack Exchange
# https://unix.stackexchange.com/questions/48505/how-to-make-sure-only-one-instance-of-a-bash-script-runs
#
# command-line to test this script:
#
# for i in `seq 1 3`; do (sh singleton.sh &) ; done
#
# shell - how to check variable existence and compare with the string in busybox? - Unix & Linux Stack Exchange
# https://unix.stackexchange.com/questions/297086/how-to-check-variable-existence-and-compare-with-the-string-in-busybox
#
# Another approach not mentioned here that does not use flock is
# to rely on the fact that creating a link is atomic.
#
# The basic idea is that when two instances of the script run,
# they try to create a link at the same path (i.e., /var/tmp/singleton.lock)
# that points to something, but only one of them will succeed and
# the other one will get the error code for the error:
#
# ln: failed to create hard link '/var/tmp/singleton.lock': File exists
#
set -e

err_handler () {
  [ $? -eq 0 ] && exit
  # Code for non-zero exit status here
  echo "trap"
  rm /var/tmp/singleton.$$.lock
  rm -f /var/tmp/singleton.lock
}

trap err_handler EXIT

touch /var/tmp/singleton.$$.lock

echo "Starting $0 ($$)..."

if ( ! ln -s /var/tmp/singleton.$$.lock /var/tmp/singleton.lock 2>/dev/null ) ; then
  echo 'Failed Lock Acquistion Attempt By: ' $$
  rm -f /var/tmp/singleton.$$.lock
  exit 1
fi

echo 'Lock Acquired By: ' $$

# your stuff
echo "Doing my stuff...."
for i in `seq 10 -1 1` ; do echo -ne "\r$i " ; sleep 1 ; done

echo 'Lock Released By: ' $$

rm /var/tmp/singleton.$$.lock
rm -f /var/tmp/singleton.lock
