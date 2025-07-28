#!/bin/sh

#添加规则
#Usage: route_set.sh add [interface] [ipadress] [prefixlen] [gateway] [waninfo]
#		route_set.sh add ppp0 168.95.1.1 255.255.255.0 10.96.1.254 1_INTERNET_R_VID_100
#删除规则
#Usage: route_set.sh delete [interface][ipadress] [prefixlen] [gateway][waninfo]
#		route_set.sh delete ppp0 168.95.1.1 255.255.255.0 10.96.1.254 1_INTERNET_R_VID_100

intf=$2
ipaddress=$3
prefixlen=$4
gateway=$5
waninfo=$6
RULE_FILE_TMP=/var/static_rule_table6.tmp
configfile=/flash/cfg/misc_conf/static_route_v6.conf
echo "$0 $1 $2 $3 $4 $5" 

if [ "$1" = "add" ]; then
	echo -e "$2 $3 $4 $5 $6" >> $configfile

	#host route
	if [ "$prefixlen" = "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route add $ipaddress dev $intf
		echo "ip -6 route add $ipaddress dev $intf"
	fi
	if [ "$prefixlen" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route add $ipaddress via $gateway dev $intf
		echo "ip -6 route add $ipaddress via $gateway dev $intf"
	fi

	#network route
	if [ "$prefixlen" != "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route add $ipaddress/$prefixlen dev $intf
		echo "ip -6 route add $net dev $intf"
	fi
	if [ "$prefixlen" != "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route add $ipaddress/$prefixlen via $gateway dev $intf
		echo "ip -6 route add $net via $gateway dev $intf"
	fi

	#default route
	if [ "$prefixlen" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" = "NULL" ]; then
		ip -6 route add default via $gateway dev $intf
		echo "ip -6 route add default via $gateway dev $intf"
	fi
	
	ip -6 route flush cache
	echo "ip -6 route flush cache"
	elif [ "$1" = "delete" ]; then
	cat $configfile | grep -v "$2 $3 $4 $5 $6" > $RULE_FILE_TMP
	mv $RULE_FILE_TMP $configfile
	#host route
	if [ "$prefixlen" = "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route delete $ipaddress dev $intf
		echo "ip -6 route delete $ipaddress dev $intf"
	fi
	if [ "$prefixlen" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route delete $ipaddress via $gateway dev $intf
		echo "ip -6 route delete $ipaddress via $gateway dev $intf"
	fi

	#network route
	if [ "$prefixlen" != "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route delete $ipaddress/$prefixlen dev $intf
		echo "ip -6 route delete $net dev $intf"
	fi
	if [ "$prefixlen" != "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		ip -6 route delete $ipaddress/$prefixlen via $gateway dev $intf
		echo "ip -6 route delete $net via $gateway dev $intf"
	fi

	#default route
	if [ "$prefixlen" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" = "NULL" ]; then
		ip -6 route delete default via $gateway dev $intf
		echo "ip -6 route delete default via $gateway dev $intf"
	fi
	
	ip -6 route flush cache
	echo "ip -6 route flush cache"
else
	echo -e "Usage:\troute_set.sh add [interface] [ipadress] [prefixlen] [gateway] [waninfo]"
	echo -e "\troute_set.sh delete [interface] [ipadress] [prefixlen] [gateway] [waninfo]"
fi

exit 0
