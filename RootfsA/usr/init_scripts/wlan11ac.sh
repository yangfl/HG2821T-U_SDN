#!/bin/sh

# call by cm
# wlan11ac.sh <param1>
# param1:  [1: wlan11ac up, 0: wlan11ac down, other: init wlan11ac only]

ip netns exec MNG ip link set rai0 netns 1
if [ "$1" = "1" ]; then
	/rom/fhshell/wlan/wlan_start & 
elif [ "$1" = "0" ]; then
	ifconfig rai0 down
else
	echo "do nothing"
fi
