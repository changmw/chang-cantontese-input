#!/bin/sh
#
# networking - Can I set up multiple accounts on DD-WRT? - Super User
# https://superuser.com/questions/442292/can-i-set-up-multiple-accounts-on-dd-wrt
#
user=user
password=`openssl passwd -1 -salt xyz your-password-here`

cp /etc/passwd /tmp/passwd.bak

echo "${user}:${password}:1000:1000:User,,,:/tmp/${user}:/bin/sh" >> /etc/passwd
mkdir /tmp/${user}
chmod 1000:1000 /tmp/user
