#!/bin/sh

# call by cm
# del_pppoe.sh <param1> <param2>
# param1: binding portname
# param2: Node_name

. /usr/etc/env_para.sh

PORTNAME=$1
NODE=$2

#if [ $PORTNAME = "SDN-out-default" ];then
	/rom/fhshell/pppoe/pppoe stop pon0.4093
	ip netns exec obox vconfig rem pon0.4093
#else
#	echo "Unknown arguments!!"
#fi

