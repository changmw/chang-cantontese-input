#!/bin/sh
#
# DD-WRT :: View topic - save shell history
# https://forum.dd-wrt.com/phpBB2/viewtopic.php?t=311267
#
function chkcrt() {
  echo | openssl s_client -connect $1:443 2> /dev/null | openssl x509 -noout -issuer -subject -dates
}

function ddver() {
  echo "DD-WRT v3.0-r$(nvram get os_version) $(nvram get dist_type) ($(grep Release /tmp/loginprompt | cut -d : -f 2 | tr -d ' '))"
  uname -a
}

export HISTCONTROL='ignoredups'
export HISTFILE='/opt/home/root/.ash_history'
export HISTSIZE='50'

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

export PAGER=more
# export MANPAGER='less -s -M +Gg'

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
#
alias vi="/opt/bin/vim"
alias dire="du -d 1 -h"
alias wlscan='site_survey 2>&1 | cut -d '[' -f 3 | sed  s/]\ BSSID//g\ | sed s/^\ *//g'
alias scrcap='tmux capture-pane -p -S-'
