#!/bin/sh
while :
do
	if [ -e /var/pppoe-proxy.sh ];then		
#		iptables -A FORWARD -i ppp+ -j ACCEPT
		break;
	else
		sleep 1
	fi
done
sleep 10
/var/pppoe-proxy.sh

