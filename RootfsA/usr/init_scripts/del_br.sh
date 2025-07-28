#!/bin/sh

. /usr/init_scripts/env_para.sh

ifconfig br0 down
brctl delbr br0
mkdir -p /var/run/netns
if [ -f "/usr/local/.steinsgate" ]; then
	fhtool openserial &
	echo "openserial"
fi