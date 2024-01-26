#
# DD-WRT :: View topic - Unbound DNS over TLS Adblock up-to-date root.hints
# https://forum.dd-wrt.com/phpBB2/viewtopic.php?t=320362&sid=8f74203692da063796392a961494cde5
#
function dl()  {
  echo -e "Downloading $2 to $1..."
  curl -L --compressed $2 >> $1
}

function pp2() {
  echo "Processing $2 into $3..."
  #
  # Unbound memory optimization : dns
  # https://www.reddit.com/r/dns/comments/w0g83i/unbound_memory_optimization/
  #
  # Unbound: Memory consumption very high, gets killed | The FreeBSD Forums
  # https://forums.freebsd.org/threads/unbound-memory-consumption-very-high-gets-killed.78578/
  #
  # unbound-checkconf memory usage is higher than naively expected · Issue #128 · NLnetLabs/unbound · GitHub
  # https://github.com/NLnetLabs/unbound/issues/128
  #
  if [ $1 == 127 ] ; then
    echo '.. Method: local-data'
    cat $2 | awk '{print "local-data: \""$2".\" A 127.0.0.1"}' >> $3
  else
    echo '.. Method: local-zone'
    cat $2 | grep 0.0.0.0 | awk '{print "local-zone: \""$2".\" refuse"}' >> $3
  fi
}

function pp1() {
  echo "Processing $2 into $3 ..."
  if [ $1 == 127 ] ; then
    echo '.. Method: local-data'
    cat $2 | awk '{print "local-data: \""$1".\" A 127.0.0.1"}' >> $3
  else
    echo '.. Method: local-zone'
    cat $2 | awk '{print "local-zone: \""$1".\" refuse"}' >> $3
  fi
}

target=/jffs/etc/unbound/newall.conf

if [ -f $target ] ; then
  echo -e "$0[$$]: \033[1m$target\033[0m already exists!\007"
  exit 1
fi

tf=/tmp/tmp
tf2=/tmp/tmp2

echo -e "Creating \033[1m$tf\033[0m ..."
cat /dev/null > $tf

if true ; then
  echo -e '\033[1mPhase 1\033[0m'

  # dl $tf 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts'
  # dl $tf 'https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt'
  # dl $tf 'https://github.com/chadmayfield/my-pihole-blocklists/raw/master/lists/pi_blocklist_porn_all.list'
  dl $tf 'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt'
else
  echo e '\033[1mPhase 1b\033[0m'
  # the following list will consume all memory
  dl $tf 'https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt'
fi

#
# https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound;showintro=0
#
# https://someonewhocares.org/hosts/
# https://pgl.yoyo.org/adservers/
#
# disable Window$ Update
#
# dl $tf 'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/update.txt'
# dl $tf 'https://raw.githubusercontent.com/schrebra/Windows.10.DNS.Block.List/main/hosts.txt'
#
# following list included microsoft
#
# dl $tf 'https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/extra.txt'

echo "Overwriting $target..."
cat /dev/null > $target

echo "0.0.0.0  changmw2.debug.haha" >> $tf
pp2 0 $tf $target

cat /dev/null > $tf
cat /dev/null > $tf2

if true ; then
  echo -e '\033[1mPhase 2 - one-column\033[0m'

  dl $tf 'https://gitlab.com/quidsup/notrack-blocklists/-/raw/master/malware.list'
  dl $tf 'https://raw.githubusercontent.com/mkaand/youtube-ads-blocker-ddwrt/master/domainlist.txt'

  dl $tf 'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.huawei.txt'
  dl $tf 'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.tiktok.txt'
  dl $tf 'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.winoffice.txt'

  # Affects Scrabble Go and possibly all iOS games
  # dl $tf 'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/native.apple.txt'

  dl $tf 'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/doh.txt'

  # huge list
  # dl $tf 'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/tif.txt'

  dl $tf 'https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt'
  dl $tf 'https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt'

  # Affect Scrabble Go
  # dl $tf2 'https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt'
  # grep Tracker /tmp/tmp2 | cut -d ' #' -f 1 >> $tf
  #
  # dl $tf2 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com'
  # cat $tf2 | cut -d "," -f 1 >> $tf

  # Affects Scrabble Go
  # dl $tf 'https://raw.githubusercontent.com/anudeepND/youtubeadsblacklist/master/domainlist.txt'
  # dl $tf 'https://dbl.oisd.nl/basic/'

  echo "changmw1.debug.haha" >> $tf
fi

pp1 0 $tf $target
cat /dev/null > $tf

if true ; then
  echo -e '\033[1mPhease 3\033[0m'
  #
  # GitHub - Ewpratten/youtube_ad_blocklist: This is an open project to maintain
  # a list of domain names that serve YouTube ads
  # https://github.com/Ewpratten/youtube_ad_blocklist
  #
  # following affects Scrabble Go
  # dl $tf 'http://gh-pages.ewpratten.com/youtube_ad_blocklist/unbound.txt'
fi

cat $tf >> $target

echo "Sorting and removing duplicates into $tf..."
sort $target | uniq > $tf

echo "Removing invalid records in $tf ..."
grep -v -E '".#"|"#."' $tf | grep -v '"#==' | grep -v '"."' | grep -v '"0.0.0.0"' > $target

echo -e "Output file: \033[1m$target\033[0m"

echo -e "Removing temp file \033[1m$tf\033[0m"
rm $tf $tf2

echo -e '\033[1mDone\033[0m\007'
exit 0
