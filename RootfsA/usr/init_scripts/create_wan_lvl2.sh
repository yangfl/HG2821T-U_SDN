#!/bin/sh

. /usr/etc/env_para.sh

PORTNAME=$1
VLAN=$2
OFPORT=$3

if [ $PORTNAME != "" -a $VLAN != "" -a $OFPORT != "" ];then
	#fh_set_flow 0 $VLAN 0 INTERNET 1 1
	create_interface $VLAN
	if [ "$VLAN" = "85" ];then
		# echo "$VLAN" >> /mnt/test1
		ifconfig pon0.85 down
		ip link set dev pon0.85 name $PORTNAME
		/usr/ovs/bin/ovs-vsctl --if-exists del-port SDN-bridge pon0.85
        #PORTNAME=iptv.85
    elif [ "$VLAN" = "51" ];then
    	# echo "$VLAN" >> /mnt/test2
		ifconfig pon0.51 down
		ip link set dev pon0.51 name $PORTNAME
		/usr/ovs/bin/ovs-vsctl --if-exists del-port SDN-bridge pon0.51
        #PORTNAME=iptv.51
    elif [ "$VLAN" = "0" ];then
    	# echo "$VLAN" >> /mnt/test3
    	ifconfig pon0.4093 down
    	ip link set dev pon0.4093 name $PORTNAME
    else
    	echo "$VLAN"
        #PORTNAME=pon0.$VLAN
    fi
	/usr/bin/ip link set $PORTNAME netns MNG
	/usr/bin/ip netns exec MNG ifconfig $PORTNAME up
	/usr/ovs/bin/ovs-vsctl --may-exist add-port SDN-bridge $PORTNAME -- set interface $PORTNAME ofport_request=$OFPORT
	$OVS_VSCTL set Port $PORTNAME other_config:rstp-enable=false
	$OVS_OFCTL mod-port SDN-bridge $PORTNAME no-flood
	if [ "$VLAN" = "85" ];then
		/usr/ovs/bin/ovs-vsctl set Port $PORTNAME other_config:mcast-snooping-force-reports=true
	fi
	/usr/ovs/bin/ovs-vsctl set Port $PORTNAME other_config:mcast-snooping-disable-flood-query=true
	/usr/bin/ip netns exec MNG ifconfig $PORTNAME up
else
	echo "miss arguments!"
fi