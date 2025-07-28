#!/bin/sh

#添加规则
#Usage: route_set.sh add [interface] [ipadress] [netmask] [gateway]
#		route_set.sh add ppp0 168.95.1.1 255.255.255.0 10.96.1.254
#删除规则
#Usage: route_set.sh delete [interface] [ipadress] [netmask] [gateway]
#		route_set.sh delete ppp0 168.95.1.1 255.255.255.0 10.96.1.254

intf=$2
ipaddress=$3
netmask=$4
gateway=$5
echo "$0 $1 $2 $3 $4 $5" 

if [ "$1" = "add" ]; then
	#add network route
	net=`ip_calc get_net $ipaddress $netmask`
	ip route add $net via $gateway dev $intf
	echo "ip route add $net via $gateway dev $intf"
	
	ip route flush cache
	echo "ip route flush cache"
elif [ "$1" = "delete" ]; then
	#add network route
	net=`ip_calc get_net $ipaddress $netmask`
	ip route delete $net via $gateway dev $intf
	echo "ip route delete $net via $gateway dev $intf"
	
	ip route flush cache
	echo "ip route flush cache"
else
	echo -e "Usage:\troute_set.sh add [interface] [ipadress] [netmask] [gateway]"
	echo -e "\troute_set.sh delete [interface] [ipadress] [netmask] [gateway]"
fi

exit 0
