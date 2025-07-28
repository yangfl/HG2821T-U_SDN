#!/bin/sh
namespace=$1
while true        
do            
	flag_l2tp=`ps -ef | grep pppd | grep $namespace`
	if [ -z "$flag_l2tp" ]
	then
		ip netns exec $namespace xl2tpd-control -c /var/xl2tpd/$namespace/l2tp-control connect $namespace
	fi
	sleep 10
done
 
