#!/bin/sh

# call by cm
# wlan.sh <param1>
# param1:  [1: wlan up, 0: wlan down, other: init wlan only]

ip netns exec MNG ip link set ra0 netns 1
if [ "$1" = "1" ]; then
	/rom/fhshell/wlan/wlan_start &
elif [ "$1" = "0" ]; then
	ifconfig ra0 down
else
	echo "do nothing"
fi
	
