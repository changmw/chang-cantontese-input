#!/bin/sh
#
# digital signature - How to acquire DNSSEC root trust anchor from IANA? - Information Security Stack Exchange
# https://security.stackexchange.com/questions/111454/how-to-acquire-dnssec-root-trust-anchor-from-iana
# curl -s https://www.internic.net/domain/root.zone | grep "^\.\s\+[0-9]\+\s\+IN\s\+DNSKEY" > root.keys
# unbound-anchor -a /jffs/etc/unbound/root.key
# deprecated:
# dig +sigchase +trusted-key=./root.keys @8.8.8.8 eesti.ee
