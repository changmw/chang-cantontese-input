#!/bin.sh
#
# DD-WRT :: View topic - SOLVED - How to force reboot via CLI
# https://forum.dd-wrt.com/phpBB2/viewtopic.php?t=331051
#
# Linux Magic System Request Key Hacks - The Linux Kernel documentation
# https://www.kernel.org/doc/html/v4.18/admin-guide/sysrq.html
#
echo s > /proc/sysrq-trigger
echo s > /proc/sysrq-trigger
echo s > /proc/sysrq-trigger
#
# echo u > /proc/sysrq-trigger
echo b > /proc/sysrq-trigger
