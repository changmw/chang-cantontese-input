#!/bin/sh

echo "DD-WRT v3.0-r$(nvram get os_version) $(nvram get dist_type) ($(grep Release /tmp/loginprompt | cut -d : -f 2 | tr -d ' '))"
uname -a
