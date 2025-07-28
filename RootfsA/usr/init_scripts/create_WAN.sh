#!/bin/sh

# call by cm
# create_WAN.sh <param1> <param2>
# param1: binding portname
# param2: pppoe username
# param3: pppoe password
# param4: pppoe VLANID

. /usr/init_scripts/env_para.sh

BASEMAC=`fhtool getonumac`
if [ -n "$2" ]; then
	PORTNAME=$1
    USERNAME=$2
    PASSWORD=$3
	VLANID=$4
else
	PORTNAME=$PORTNAME
    USERNAME=$USERNAME
    PASSWORD=$PASSWORD
	VLANID=$VLANID
fi


if [ $PORTNAME = "SDN-out-default" ];then
	#fh_set_flow 0 0 0 INTERNET 1 1
	#sleep 1
	VLANID=0
	create_interface $VLANID
##########for fh test vlan pppoe#############
	#if [ $VLANID -gt 0 ];then
		#$IP_CMD link set pon0.$VLANID netns obox
		#$IP_CMD netns exec obox ifconfig pon0.$VLANID up
		#$IP_CMD netns exec obox /rom/fhshell/pppoe/pppoe start pon0.$VLANID $USERNAME internet nodefaultroute 1492 $PASSWORD
	#else
	    $IP_CMD link set pon0.4093 netns obox                               
		$IP_CMD netns exec obox ifconfig pon0.4093 up 
		$IP_CMD netns exec obox /rom/fhshell/pppoe/pppoe start pon0.4093 $USERNAME internet nodefaultroute 1492 $PASSWORD
	#fi
	sleep 1
	IP=`cat /var/run/ppp0/gw`
	route add default gw $IP
else
	namespace=$PORTNAME
	value=`$IP_CMD netns show|grep $namespace`
	l2tpconf=/var/xl2tpd/$namespace/xl2tp.conf
        if [ "$value" = "" ];then
            	$IP_CMD netns add $namespace
        fi
	
	$IP_CMD netns exec obox xl2tpd -c $l2tpconf -p /var/xl2tpd/$namespace/xl2tpd.pid -C /var/xl2tpd/$namespace/l2tp-control -D &
	sleep 1
	
	#ip netns exec $namespace xl2tpd-control -c /var/xl2tpd/$namespace/l2tp-control connect $namespace 
	
	flag=`ps -ef | grep create_l2tp.sh | grep $namespace | grep -v grep`                             
	if [ -z "$flag" ]                                                                                
	then                                                                                             
		/usr/init_scripts/create_l2tp.sh $namespace &
	fi 
	
	value=`$IP_CMD netns exec MNG $IP_CMD link list | grep $PORTNAME`	
    	if [ "$value" != "" ];then
		$IP_CMD netns exec MNG $IP_CMD link set $PORTNAME netns $namespace
		$IP_CMD netns exec $namespace ifconfig $PORTNAME 192.168.1.1/24 hw ether $BASEMAC up
	fi
fi
