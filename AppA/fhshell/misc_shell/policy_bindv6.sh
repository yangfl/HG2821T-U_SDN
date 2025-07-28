#!/bin/sh

#添加规则
#Usage: policy_bindv6.sh add [interface] [ipv6] [gateway] [portmap]
#		policy_route.sh add [wan接口名称] [wan接口IP地址]  [网关]  [绑定LAN端口，12位二进制]rai 3-0 ra 3-0 lan 3-0
#Example: policy_bindv6.sh add pon0.123 2000::1 2000:0:9::102  001010001000 (rai1 ra3 eth3 )
#
#删除规则
#Usage: policy_bindv6.sh delete [interface]
#		policy_bindv6.sh delete [wan接口名称][绑定LAN端口，12位二进制]
#Example: policy_bindv6.sh delete pon0.123

RULE_FILE=/var/rule_v6table
RULE_FILE_TMP=/var/rule_v6table.tmp
ROUTE_PATH=/var/internet_route.info
if [ "$1" = "add" ]; then
	echo "$0 $1 $2 $3 $4 $5 " 
	echo "$0 $1 $2 $3 $4 $5 "  >> $RULE_FILE
	interface=$2
	ipv6=$3
	gateway=$4
	portmap=$5
	
	sleep 2
	
	# port   : 12 11 10 9 8 7 6 5 4 3 2 1
	# portmap: 0  0  0  0 0 0 0 0 0 0 0 0
	# n      : 12 11 10 9 8 7 6 5 4 3 2 1 -> mark
	# cut i  : 1 2 3 4 5 6 7 8 9 10 11 12   
	
	for i in 12 11 10 9 8 7 6 5 4 3 2 1
	do
		
		
			#for lan port, i > 8
		if [ $i -gt 8 ]; then
			k=$((12-$i))
			ks=eth$k
		#for 2.4g wlan port, i > 4
		elif [ $i -gt 4 ]; then
			k=$((8-$i))
			ks=ra$k	
		#for 5g wlan port, i <= 4
		else
			k=$((4-$i))
			ks=rai$k
		fi
			n=$(printf "%x" $i)
			
		pref=$((1600+$i))
		
		table=$((400+$i))
		
		#echo "i=$i, n=$n"
		
		bit=`echo $portmap | cut -c $i`
		if [ "$bit" = "1" ]; then
			msk=0x${n}0000000
		
			#add route table
			ip -6 rule add iif br0 fwmark ${msk}/0xf0000000 table $table pref $pref
			
			echo "ip -6 rule add iif br0 fwmark ${msk}/0xf0000000 table $table pref $pref"
			
			#add from  ipaddress table for dns
			ip -6 rule add from $ipv6  table $table pref $pref
			
			#add ebtbles
			ebtables -t broute -A BROUTING  -p 0x86DD -i ${ks} -j mark --mark-or ${msk}
			echo "ebtables -t broute -A BROUTING  -p 0x08DD -i ${ks} -j mark --mark-or ${msk}"
			
			
			#add host route
			#ip -6 route add $ipv6 dev $interface table $table pref $pref
			#echo "ip -6 route add $ipv6 dev $interface table $table pref $pref"
			
			#add network route
			
			ip -6 route add $ipv6 dev $interface table $table pref $pref
			echo "ip -6 route add $ipv6 dev $interface table $table pref $pref"
			
			#add default route
			
			ip -6 route add default via $gateway dev $interface table $table pref $pref
			echo "ip -6 route add default via $gateway dev $interface table $table pref $pref"
		
		fi
	done

	

	#刷新路由表，使新配置的路由生效
	ip -6 route flush cache
	echo "ip -6 route flush cache"
elif [ "$1" = "delete" ]; then
	interface=$2
	ipv6=`cat $RULE_FILE | grep $interface | awk '{print $4}'`
	gateway=`cat $RULE_FILE | grep $interface | awk '{print $5}'`
	portmap=`cat $RULE_FILE | grep $interface | awk '{print $6}'`
	
	if [ "$ipv6" = "" ]; then
		exit 1
	fi
	echo "$0 $1 $2 $ipv6 $gateway $portmap"
	
	cat $RULE_FILE | grep -v $interface > $RULE_FILE_TMP
	mv $RULE_FILE_TMP $RULE_FILE

	name_pre=`echo $interface | cut -c 1-3`
	if [ "$name_pre" = "ppp" ]; then
		name=`cat $ROUTE_PATH | grep $interface | awk -F '_' '{print $1}'`	
	else
		name=$interface
	fi
	
	cat $ROUTE_PATH | grep -v "${name}_flagv6" > $RULE_FILE_TMP
	mv $RULE_FILE_TMP $ROUTE_PATH
	
	for i in 12 11 10 9 8 7 6 5 4 3 2 1
	do
		
		
		#for lan port, i > 8
		if [ $i -gt 8 ]; then
			k=$((12-$i))
			ks=eth$k
		#for 2.4g wlan port, i > 4
		elif [ $i -gt 4 ]; then
			k=$((8-$i))
			ks=ra$k	
		#for 5g wlan port, i <= 4
		else
			k=$((4-$i))
			ks=rai$k
		fi
			n=$(printf "%x" $i)
		pref=$((1600+$i))
		
		table=$((400+$i))
		#echo "i=$i, n=$n"
		
		bit=`echo $portmap | cut -c $i`
		if [ "$bit" = "1" ]; then
			msk=0x${n}0000000
			
			ip -6 route flush table $table 
			
			#del route table
			ip -6 rule del iif br0 fwmark ${msk}/0xf0000000 table $table pref $pref
			
			echo "ip -6 rule del  iif br0 fwmark ${msk}/0xf0000000 table $table pref $pref"
			#del from  ipaddress table for dns
	
			ip -6 rule del from $ipv6  table $table pref $pref
			
			#del ebtbles
			ebtables -t broute -D BROUTING  -p 0x86DD -i ${ks} -j mark --mark-or ${msk}
			echo "ebtables -t broute -D BROUTING  -p 0x08DD -i ${ks} -j mark --mark-or ${msk}"
			
			
			#del host route
			#ip route del $ipaddress dev $intf table 100+${m}
			#echo "ip route del $ipaddress dev $intf table 100+${m}"
			
			#del network route
			
			ip -6 route del $ipv6 dev $interface table $table pref $pref
			echo "ip -6 route del $ipv6 dev $interface table $table pref $pref"
			
			#del default route
			
			ip -6 route del default via $gateway dev $interface table $table pref $pref
			echo "ip -6 route del default via $gateway dev $interface table $table pref $pref"
		fi
	done

else
	echo -e "Usage:\tpolicy_bindv6.sh add [interface] [ipv6] [gateway] [portmap]"
	echo -e "\tpolicy_bindv6.sh delete [interface]"
fi

exit 0
