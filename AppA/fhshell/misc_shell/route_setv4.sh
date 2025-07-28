#!/bin/sh

#添加规则
#Usage: route_set.sh add [interface] [ipadress] [netmask] [gateway] [waninfo]
#		route_set.sh add ppp0 168.95.1.1 255.255.255.0 10.96.1.254 1_INTERNET_R_VID_100
#删除规则
#Usage: route_set.sh delete [interface] [ipadress] [netmask] [gateway] [waninfo]
#		route_set.sh delete ppp0 168.95.1.1 255.255.255.0 10.96.1.254 1_INTERNET_R_VID_100

intf=$2
ipaddress=$3
netmask=$4
gateway=$5
configfile=/flash/cfg/misc_conf/static_route_v4.conf
tempfile=/var/tmpfile.tmp
echo "$0 $1 $2 $3 $4 $5" 

if [ "$1" = "add" ]; then
	#host route
	if [ "$netmask" = "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		ip route add $ipaddress dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route add $ipaddress dev $intf"
			exit -1
		fi
		echo "ip route add $ipaddress dev $intf"
	fi
	if [ "$netmask" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		ip route add $ipaddress via $gateway dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route add $ipaddress via $gateway dev $intf"
			exit -1
		fi
		echo "ip route add $ipaddress via $gateway dev $intf"
	fi

	#network route
	if [ "$netmask" != "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		net=`ip_calc get_net $ipaddress $netmask`
		ip route add $net dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route add $net dev $intf"
			exit -1
		fi
		echo "ip route add $net dev $intf"
	fi
	if [ "$netmask" != "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		net=`ip_calc get_net $ipaddress $netmask`
		ip route add $net via $gateway dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route add $net via $gateway dev $intf"
			exit -1
		fi
		echo "ip route add $net via $gateway dev $intf"
	fi

	#default route
	if [ "$netmask" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" = "NULL" ]; then
		ip route add default via $gateway dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route add default via $gateway dev $intf"
			exit -1
		fi
		echo "ip route add default via $gateway dev $intf"
	fi
	
	ip route flush cache
	echo "ip route flush cache"
	
	echo -e "$2 $3 $4 $5 $6" >> $configfile
elif [ "$1" = "delete" ]; then
	#host route
	if [ "$netmask" = "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		ip route delete $ipaddress dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route delete $ipaddress dev $intf"
			exit -1
		fi
		echo "ip route delete $ipaddress dev $intf"
	fi
	if [ "$netmask" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		ip route delete $ipaddress via $gateway dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route delete $ipaddress via $gateway dev $intf"
			exit -1
		fi
		echo "ip route delete $ipaddress via $gateway dev $intf"
	fi

	#network route
	if [ "$netmask" != "NULL" -a "$gateway" = "NULL" -a "$ipaddress" != "NULL" ]; then
		net=`ip_calc get_net $ipaddress $netmask`
		ip route delete $net dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route delete $net dev $intf"
			exit -1
		fi
		echo "ip route delete $net dev $intf"
	fi
	if [ "$netmask" != "NULL" -a "$gateway" != "NULL" -a "$ipaddress" != "NULL" ]; then
		net=`ip_calc get_net $ipaddress $netmask`
		ip route delete $net via $gateway dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route delete $net via $gateway dev $intf"
			exit -1
		fi
		echo "ip route delete $net via $gateway dev $intf"
	fi

	#default route
	if [ "$netmask" = "NULL" -a "$gateway" != "NULL" -a "$ipaddress" = "NULL" ]; then
		ip route delete default via $gateway dev $intf
		if [ $? -ne 0 ]; then
			echo "failed: ip route delete default via $gateway dev $intf"
			exit -1
		fi
		echo "ip route delete default via $gateway dev $intf"
	fi
	
	ip route flush cache
	echo "ip route flush cache"
	
	cat $configfile | grep -v "$2 $3 $4 $5 $6" > $tempfile
	mv $tempfile $configfile
else
	echo -e "Usage:\troute_set.sh add [interface] [ipadress] [netmask] [gateway] [waninfo]"
	echo -e "\troute_set.sh delete [interface] [ipadress] [netmask] [gateway] [waninfo]"
	exit -1
fi

exit 0
