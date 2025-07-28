#!/bin/sh

PORTNAME=$1

if [ $PORTNAME != "" ];then
	/usr/ovs/bin/ovs-vsctl --if-exists del-port SDN-bridge $PORTNAME
	/usr/bin/ip netns exec MNG /usr/bin/ip link set $PORTNAME netns 1
	ifconfig $PORTNAME down
    vconfig rem $PORTNAME
else
	echo "Miss argument!"
fi