#!/bin/sh

. /usr/etc/env_para.sh

cmd=`echo ${cmd#*\'}`
cmd=`echo ${cmd%\'*}`

if [ "$cmd" != "" ] && [ "$namespace" != "" ]; then
	if [ "$namespace" = "SDN-out-default" ];then
		$IP_CMD netns exec obox iptables $cmd
	else
		cmd=`echo $cmd|sed "s/ppp0/ppp10/g"`
		$IP_CMD netns exec $namespace iptables $cmd
	fi
else
	echo "Argument CMD is NULL or NAMESPACE is NULL!"
fi
