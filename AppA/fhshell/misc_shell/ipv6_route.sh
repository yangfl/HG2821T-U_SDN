#!/bin/sh

#Usage: ipv6_route.sh add [intf] [vlanid]
#		ipv6_route.sh del [intf] [vlanid]
#Example: policy_route.sh add ppp0 123 
#Example: policy_route.sh del pon0.456

RULE_FILE=/var/ipv6_route

intf=$2
vid=$3

if [ "$1" = "add" ]; then
	echo "$0 $1 $2 $3" 
	echo "$0 $1 $2 $3" >> $RULE_FILE

	insmod /lib/hisilicon/ko/hi_kroute.ko rtact_begin=64
	echo "insmod /lib/hisilicon/ko/hi_kroute.ko rtact_begin=64"
	insmod /lib/hisilicon/ko/hi_kroute_example.ko
	echo "insmod /lib/hisilicon/ko/hi_kroute_example.ko"

	hi_cli /home/cli/kroute/setdevice -v ifname br0 flags 0x001 vlan 4094
	echo "hi_cli /home/cli/kroute/setdevice -v ifname br0 flags 0x001 vlan 4094"
	hi_cli /home/cli/kroute/setdevice -v ifname $intf flags 0x001 vlan $vid
	echo "hi_cli /home/cli/kroute/setdevice -v ifname $intf flags 0x001 vlan $vid"

	#hi_cli /home/cli/adapter/flow/add_service -v mask 0x10801 label 5 ipver 6 igr 0x1f svlan 4094 transact 10
	#echo "hi_cli /home/cli/adapter/flow/add_service -v mask 0x10801 label 5 ipver 6 igr 0x1f svlan 4094 transact 10"
	#hi_cli /home/cli/adapter/flow/add_service -v mask 0x10801 label 5 ipver 6 igr 0x20 svlan $vid transact 10
	#echo "hi_cli /home/cli/adapter/flow/add_service -v mask 0x10801 label 5 ipver 6 igr 0x20 svlan $vid transact 10"
elif [ "$1" = "del" ]; then
	echo "$0 $1 $2" 
	echo "$0 $1 $2" >> $RULE_FILE

	#hi_cli /home/cli/adapter/flow/del_service -v mask 0x10801 label 5 ipver 6 igr 0x1f svlan 4094 transact 10
	#echo "hi_cli /home/cli/adapter/flow/del_service -v mask 0x10801 label 5 ipver 6 igr 0x1f svlan 4094 transact 10"
	#hi_cli /home/cli/adapter/flow/del_service -v mask 0x10801 label 5 ipver 6 igr 0x20 svlan $vid transact 10
	#echo "hi_cli /home/cli/adapter/flow/del_service -v mask 0x10801 label 5 ipver 6 igr 0x20 svlan $vid transact 10"
	
	#hi_cli /home/cli/kroute/setdevice -v ifname br0 flags 0x001 vlan 4094
	#echo "hi_cli /home/cli/kroute/setdevice -v ifname br0 flags 0x001 vlan 4094"
	#hi_cli /home/cli/kroute/setdevice -v ifname $intf flags 0x001 vlan $vid
	#echo "hi_cli /home/cli/kroute/setdevice -v ifname $intf flags 0x001 vlan $vid"
	
	rmmod /lib/hisilicon/ko/hi_kroute_example.ko
	echo "rmmod /lib/hisilicon/ko/hi_kroute_example.ko"
	rmmod /lib/hisilicon/ko/hi_kroute.ko
	echo "rmmod /lib/hisilicon/ko/hi_kroute.ko"
else
	echo -e "Usage:\tipv6_route.sh add [intf] [vlanid]"
	echo -e "\tipv6_route.sh del [intf]"
fi

exit 0
