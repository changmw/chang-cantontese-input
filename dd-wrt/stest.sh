# cat stest.sh
#!/bin/sh
#
# Speedtest CLI: Internet speed test for the command line
# https://www.speedtest.net/apps/cli
# version: Linux, armel
# wget --no-check-certificate \
# https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-armel.tgz
#
# ./speedtest --ca-certificate=/opt/root/openssl/acme/ssl/changmw.ddns.net_ecc/fullchain.cer
# /opt/root/speedtest/speedtest --ca-certificate=/jffs/etc/ssl/fullchain.cer
#
# bash - How to echo shell commands as they are executed - Stack Overflow
# https://stackoverflow.com/questions/2853803/how-to-echo-shell-commands-as-they-are-executed
# Function to display commands
exe() { echo "# $@" ; "$@" ; }

if [ ! -f ~/.config/ookla/speedtest-cli.json ] ; then
  echo 'Creating speedtest-cli.json from my.ookla.json'
  mkdir -p ~/.config/ookla
  cp -f /opt/root/speedtest/my.ookla.json ~/.config/ookla/speedtest-cli.json
fi
exe /opt/root/speedtest/speedtest --ca-certificate=/etc/ssl/ca-bundle.crt
exe speedtest_cli 1 1 1 1
exit 0
#
# Speedtest CLI doesn't work : r/openSUSE
# https://www.reddit.com/r/openSUSE/comments/rlfqou/speedtest_cli_doesnt_work/
#
# CA certificates extracted from Mozilla: wget https://curl.haxx.se/ca/cacert.pem
#
# mk-ca-bundle.pl
# https://opensource.apple.com/source/curl/curl-95/curl/lib/mk-ca-bundle.pl.auto.html
#
# This Perl script creates a fresh ca-bundle.crt file for use with libcurl.
# It downloads certdata.txt from Mozilla's source tree (see URL below),
# then parses certdata.txt and extracts CA Root Certificates into PEM format.
# These are then processed with the OpenSSL commandline tool to produce the
# final ca-bundle.crt file.
#
# Conversion done with mk-ca-bundle.pl version 1.29.
# https://raw.githubusercontent.com/bagder/ca-bundle/master/ca-bundle.crt
#
