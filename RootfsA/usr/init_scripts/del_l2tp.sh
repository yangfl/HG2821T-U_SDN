#!/bin/sh

# call by cm
# del_l2tp.sh <param1> <param2>
# param1: binding portname
# param2: tcapi Node_name

. /usr/init_scripts/env_para.sh

#PORTNAME=$1
#NODE=$2

#$IP_CMD netns exec $MNG_NS $OVS_VSCTL del-port SDN-bridge $PORTNAME
#$IP_CMD netns del $namespace

namespace=$PORTNAME
var=`$IP_CMD netns show|grep $namespace`
if [ "$var" != "" ]; then
	#tcapi unset $NODE
	ip netns exec $namespace xl2tpd-control -c /var/xl2tpd/$namespace/l2tp-control disconnect $namespace & 
	sleep 1
	pid_num=`ps -ef | grep create_l2tp.sh | grep $namespace | grep -v grep | awk '{print $1}'`
	kill -9 $pid_num
	kill -9 `cat /var/xl2tpd/$namespace/xl2tpd.pid`
	rm -rf /var/xl2tpd/$namespace/xl2tp.conf
	rm -rf /var/xl2tpd/$namespace/pppoptions.xl2tpd
	rm -rf /var/xl2tpd/$namespace/l2tp-control
	$IP_CMD netns exec $namespace $IP_CMD link set $PORTNAME netns MNG
	$OVS_VSCTL --if-exists del-port SDN-bridge $PORTNAME
	
	$IP_CMD netns del $namespace
fi

