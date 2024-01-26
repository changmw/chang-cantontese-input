#!/bin/sh
#
# Get a free TLS certificate with acme.sh
# https://blog.shiftasia.com/get-a-free-tls-certificate-with-acme-sh/
#
# Luckily when i go around the internet, i saw acme.sh, this is
# a ACME client that can use to get a free certificate from these CA.
#
# - ZeroSSL.com CA(default)
# - Letsencrypt.org CA
# - BuyPass.com CA
# - SSL.com CA
# - Google.com Public CA
# - Pebble strict Mode
# - Other RFC8555-compliant CA
#
# /opt/bin/wget https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh
# wget -O -  https://get.acme.sh | sh -s email=helloworld@gmail.com
#
# Acme.sh EOL and Let's Encrypt - Chat - NethServer Community
# https://community.nethserver.org/t/acme-sh-eol-and-lets-encrypt/17992/2
#
# acme.sh (any version) only needs socat if you're going to use it in
# standalone mode, which you should never need to do on a Neth server.
#
# opkg install socat
#
# acme.sh --upgrade
#
# http://blog.sysu.tech/%E7%BD%91%E7%BB%9C/%E4%BD%BF%E7%94%A8acme.sh%E9%85%8D%E7%BD%AEhttps%E5%8A%A0%E5%AF%86/
#
# cd  ~/.acme.sh
# ./acme.sh --install -m my@example.com
# ./acme.sh  --issue -d your.host --webroot /your/web/root/
# ./acme.sh --install-cert -d your.host \
#   --key-file       /your/web/ssl/your.host/key.pem  \
#   --fullchain-file /your/web/ssl/your.host/cert.pem \
#   --reloadcmd      "docker restart nginx_proxy"
# ./acme.sh --renew --force -d your.host
# ./acme.sh --list
# ./acme.sh --remove -d your.host
#
# Change default CA to ZeroSSL · acmesh-official/acme.sh Wiki · GitHub
# https://github.com/acmesh-official/acme.sh/wiki/Change-default-CA-to-ZeroSSL
#
# acme.sh --set-default-ca  --server letsencrypt
# acme.sh --set-default-ca  --server zerossl
#
# After setting set-default-ca to LE acme still uses zerossl
# - Issue #4569 · acmesh-official/acme.sh · GitHub
# https://github.com/acmesh-official/acme.sh/issues/4569
#
# acme.sh --register-account --server letsencrypt
#
# How To Change The SSL Certificate Issued On ACME
# https://azdigi.com/blog/en/website-tutorials/how-to-change-the-ssl-certificate-issued-on-acme/
#
# Next, find the value below and replace it with the type of certificate you want to issue.
# DEFAULT_CA=$
# If you need to use Let's Encrypt, enter CA_LETSENCRYPT_V2
# If you need to use ZeroSSL, enter CA_ZEROSSL
#
# After successful installation ("Cert success."), you will receive the certificate files
# at the specific link below, you just need to use the contents of 2 files *.key and
# fullchain.cer to install SSL for the website.
#
# After importing the certificate, you can visit the website or check directly through
# the online page below:
#
# SSL Checker
# https://www.sslshopper.com/ssl-checker.html
#
# Let's Encrypt Alternative - ZeroSSL
# https://zerossl.com/letsencrypt-alternative/
#
# https://github.com/acmesh-official/acme.sh/wiki/How-to-run-on-DD-WRT-with-lighttpd
# \033[1m
echo -e "\n\033[1m** Obtaining Key via acme.sh\033[0m"
sh ./acme.sh --issue --standalone \
          -d changmw.ddns.net -m toylet.toylet@gmail.com \
          --server letsencrypt \
          --home /opt/root/openssl/acme/ssl \
          --ca-path /opt/root/openssl/acme \
          --pre-hook "/sbin/service lighttpd stop" \
          --post-hook "/sbin/service lighttpd start" \
          --test
#
# echo -e "\n\033[1m** Renewing certificate via acme.sh\033[0m"
# to renew this cert: sh acme.sh --renew --domain changmw.ddns.net --home /opt/root/openssl/acme/ssl
#
cd /opt/root/openssl/acme/ssl/changmw.ddns.net_ecc
ls -l
if false ; then
  cp ca.cer /jffs/etc/ssl
  cp fullchain.cer /jffs/etc/ssl
  cp changmw.ddns.net.key /jffs/etc/ssl/changmw.key
fi
exit
#
# OpenSSL commands to check and verify your SSL certificate, key and CSR
# https://www.ibm.com/support/pages/openssl-commands-check-and-verify-your-ssl-certificate-key-and-csr
#
echo -e "\n\033[1m** Checking EC Private Key\033[0m"
openssl ec -check -in changmw.ddns.net.key
sleep 4
echo -e "\n\033[1m** Checking Certificate Signing Request\033[0m"
openssl req -text -noout -verify -in changmw.ddns.net.csr
sleep 4
echo -e "\n\033[1m** Checking Certificatae\033[0m"
openssl x509 -text -noout -in changmw.ddns.net.cer
speed 4
if false; then
  echo -e "\033[1m** Combining Private Key & CSR into PEM\033[0m"
  cat changmw.ddns.net.key changmw.ddns.net.cer > changmw.pem
  #
  # How to Check Certificate with OpenSSL
  # https://linuxhandbook.com/check-certificate-openssl/
  #
  echo -e "\n\033[1m** Checking generated PEM\033[0m"
  openssl ec -check -in changmw.pem
  openssl x509 -enddate -noout -in changmw.pem
  sleep 5
fi
if true; then
  echo -e "\n\033[1m** Copying ca.cer,fullchain.cer,changmw.key to /jffs/etc\033[0m"
  cp ca.cer /jffs/etc/ssl
  cp fullchain.cer /jffs/etc/ssl
  cp changmw.ddns.net.key /jffs/etc/ssl/changmw.key
  sleep 4
fi
echo -e "\n\033[1m** Restarting Lighttpd\033[0m"
service lighttpd stop
service lighttpd start
echo -e "\n\033[1m** Testing Lighttpd Server\033[0m"
# openssl s_client -connect 192.168.1.1:443 -showcerts
openssl s_client -connect 192.168.1.1:443 -brief </dev/null
#
# OpenSSL: Check SSL Certificate Expiration Date and More - ShellHacks
# https://www.shellhacks.com/openssl-check-ssl-certificate-expiration-date/
#
echo | openssl s_client -connect 192.168.1.1:443 2>/dev/null | openssl x509 -noout -issuer -subject -dates
# openssl s_client -connect 127.0.0.1:443 2>/dev/null </dev/null | openssl x509 -text
#
# Displaying a remote SSL certificate details using CLI tools - Server Fault
# https://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools
#
# curl --insecure -vvI https://www.example.com 2>&1 | awk 'BEGIN { cert=0 } /^\* SSL connection/ { cert=1 } /^\*/ { if (cert) print }'
echo -e "\n\035[1m** Done\n\033[0m"
#
# https://cheapsslsecurity.com/p/how-to-convert-cer-to-crt-in-openssl/
# Convert Files from CER to CRT
# openssl x509 -inform PEM -in <filepath>/certificate.cert -out certificate.crt
#
# Cron job:
#
# # sundays @4:05am, renew/install SSL certificates if necessary (restarting httpd & lighttpd in that case)
# 5 4 * * 0 root /jffs/usr/ssl/acme.sh --cron --home /jffs/usr/ssl >>/jffs/usr/ssl/cron.log 2>&1
#
# $SERVER["socket"] == ":443" {
# ssl.engine    = "enable"
# ssl.pemfile   = "/jffs/etc/lighttpd_ssl/hostkey.pem"
# ssl.ca-file   = "/jffs/etc/lighttpd_ssl/fullchain.crt"
# }
#
# ./acme.sh --install-cert -d [ddwrtdomain] --home /jffs/usr/ssl \
#    --cert-file /jffs/etc/lighttpd_ssl/host.crt \
#    --key-file  /jffs/etc/lighttpd_ssl/host.key \
#    --fullchain-file /jffs/etc/lighttpd_ssl/fullchain.crt \
#    --reloadcmd "cat /jffs/etc/lighttpd_ssl/host.crt /jffs/etc/lighttpd_ssl/host.key > /jffs/etc/lighttpd_ssl/hostkey.pem"
#
######################
#
# Get a free TLS certificate (for DNS server) with acme.sh
# https://blog.shiftasia.com/get-a-free-tls-certificate-with-acme-sh/
#
# acme.sh provide several way to get a certificate. For this post
# I will use DNS manual mode because I will not need to create any
# virtual machine and just need to run this script on my Macbook
# and add some records into domain name setting.
#
# ~# acme.sh --issue --dns -d test.dongnguyen.link  \
#  --yes-I-know-dns-manual-mode-enough-go-ahead-please
#
# After running this command, you will need to add some record
# to your dns setting, from the stdout above, i need to add
# a TXT recording with KEY=_acme-challenge.test.dongnguyen.link
# and the value will be "RPkaD43cdfiLRDNELW3ExeA7KEKdNQVeqG8K8JTq8lQ".
#
# I used AWS Route53 to mange DNS
# The DNS setting will take sometime to be effected, you can use
# `DIG` to check when it done:
#
# ~# dig +short -t txt _acme-challenge.test.dongnguyen.link
#  "RPkaD43cdfiLRDNELW3ExeA7KEKdNQVeqG8K8JTq8lQ"
#
# ~# acme.sh --renew -d test.dongnguyen.link \
#    --yes-I-know-dns-manual-mode-enough-go-ahead-please
#
# All the files are located at $HOME/.acme.sh/test.dongnguyen.link:
#
# ~# ls -l $HOME/.acme.sh/test.dongnguyen.link
#
##########################
# Acme.sh - chown: changing ownership not permitted - Help - Let's Encrypt Community Support
# https://community.letsencrypt.org/t/acme-sh-chown-changing-ownership-not-permitted/110597
#
# acme.sh --debug --issue -d office.mydomain.de \
#  --keylength 4096 mw /var/www/letsencrypt \
#  --key-file /etc/letsencrypt/rsa-certs/privkey.pem \
#  --ca-file /etc/letsencrypt/rsa-certs/chain.pem \
#  --cert-file /etc/letsencrypt/rsa-certs/cert.pem \
#  --fullchain-file /etc/letsencrypt/rsa-certs/fullchain.pem
#
