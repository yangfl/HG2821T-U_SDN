#!/bin/sh

. /usr/etc/env_para.sh

if [ "$binding_port_name" = "SDN-out-default" ];then
	NETNS="$IP_CMD netns exec obox"	
else
	NETNS="$IP_CMD netns exec $binding_port_name"
fi

$NETNS iptables -t nat -F PREROUTING



