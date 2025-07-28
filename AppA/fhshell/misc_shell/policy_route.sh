#!/bin/sh

#添加规则
#Usage: policy_route.sh add [interface] [ipadress] [netmask] [gateway] [dns1] [dns2] [portmap]
#		policy_route.sh add [wan接口名称] [wan接口IP地址] [子网掩码] [网关] [dns1] [dns2] [绑定LAN端口，12位二进制]rai 3-0 ra 3-0 lan 3-0
#Example: policy_route.sh add pon0.123 10.96.15.77 255.255.0.0 10.96.1.254 10.19.8.10 10.19.8.15 001010001000 (rai1 ra3 eth3 )
#
#删除规则
#Usage: policy_route.sh delete [interface]
#		policy_route.sh delete [wan接口名称][绑定LAN端口，12位二进制]
#Example: policy_route.sh delete pon0.123

RULE_FILE=/var/rule_table
RULE_FILE_TMP=/var/rule_table.tmp
INTERNET_INFO=/var/internet_route.info

	name_pr=`echo $2 | cut -c 1-3`
	if [ "$name_pr" = "ppp" ]; then
		intf=`cat /var/run/wan4_ppp.conf |grep $2|cut -d = -f 1`
	else
		intf=$2
	fi
	
	otherroute=`getcfgx /var/wanintf.conf otherroute`
	special_service_1=`getcfgx /var/wanintf.conf special_service_1route`
	special_service_2=`getcfgx /var/wanintf.conf special_service_2route`
	special_service_3=`getcfgx /var/wanintf.conf special_service_3route`
	special_service_4=`getcfgx /var/wanintf.conf special_service_4route`
	if [ "$intf" = "$otherroute" ] || [ "$intf" = "$special_service_1" ]|| [ "$intf" = "$special_service_2" ]|| [ "$intf" = "$special_service_3" ]|| [ "$intf" = "$special_service_4" ] ; then
		flag=1
	else
	    flag=0
	fi

if [ "$1" = "add" ]; then
	echo "$0 $1 $2 $3 $4 $5 $6 $7 $8" 
	echo "$0 $1 $2 $3 $4 $5 $6 $7 $8"  >> $RULE_FILE
	intf=$2
	ipaddress=$3
	netmask=$4
	gateway=$5
	
	if [ "$#" = "6" ]; then
		portmap=$6
	elif [ "$#" = "7" ]; then
		dns1=$6
		portmap=$7
	else 
		dns1=$6
		dns2=$7
		portmap=$8
	fi
	
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
		m=$((13-$i))
		
		mi=$((100+$i))
		
		#echo "i=$i, n=$n"
		
		bit=`echo $portmap | cut -c $i`
		if [ "$bit" = "1" ]; then
			msk=0x${n}0000000
			#delete rule: drop packets in FORWARD
			iptables -D FORWARD -m mark --mark ${msk}/0xf0000000 -j DROP
			echo "iptables -D FORWARD -m mark --mark ${msk}/0xf0000000 -j DROP"
			
			
			#add route table
			ip rule add iif br0 fwmark ${msk}/0xf0000000 table ${mi} pri ${m}
			
			echo "ip rule add iif br0 fwmark ${msk}/0xf0000000 table ${mi} pri ${m}"
			#add from  ipaddress table for dns
	
			ip rule add from $ipaddress table ${mi}  pri ${m}
			
			#add ebtbles
			ebtables -t broute -A BROUTING  -p 0x0800 -i ${ks} -j mark --mark-or ${msk}
			echo "ebtables -t broute -A BROUTING  -p 0x0800 -i ${ks} -j mark --mark-set ${msk}"
			
			
			#add host route
			#ip route add $ipaddress dev $intf table 100+${m}
			#echo "ip route add $ipaddress dev $intf table 100+${m}"
			
			#add network route
			net=`ip_calc get_net $ipaddress $netmask`
			ip route add $net dev $intf table ${mi}
			echo "ip route add $net dev $intf table ${mi}"
			
			#add default route
			ip route add default via $gateway dev $intf table ${mi}
			echo "ip route add default via $gateway dev $intf table ${mi}"
		
		fi
	done

	#DNS go default route
	if [ "$dns1" != "" ]; then
		ret1=`ip_calc compare_net $dns1 $ipaddress $netmask`
		if [ "$ret1" = "1" ]; then
			if [ "$flag" = "0" ] ;then
			ip route del $dns1
			fi
			ip route add $dns1 via $gateway dev $intf
			echo "ip route add $dns1 via $gateway dev $intf"
		fi
	fi
	if [ "$dns2" != "" ]; then
		ret2=`ip_calc compare_net $dns2 $ipaddress $netmask`
		if [ "$ret2" = "1" ]; then
			if [ "$flag" = "0" ] ;then
			ip route del $dns2
			fi
			ip route add $dns2 via $gateway dev $intf
			echo "ip route add $dns2 via $gateway dev $intf"
		fi
	fi

	#刷新路由表，使新配置的路由生效
	ip route flush cache
	echo "ip route flush cache" >> /var/default_dns
	
elif [ "$1" = "delete" ]; then
	intf=$2
	ipaddress=`cat $RULE_FILE | grep $intf | awk '{print $4}'`
	netmask=`cat $RULE_FILE | grep $intf | awk '{print $5}'`
	gateway=`cat $RULE_FILE | grep $intf | awk '{print $6}'`
	
	nf=`cat $RULE_FILE | grep $intf | awk '{print NF}'`
	if [ "$nf" = "7" ]; then
		portmap=`cat $RULE_FILE | grep $intf | awk '{print $7}'`
	elif [ "$nf" = "8" ]; then
		dns1=`cat $RULE_FILE | grep $intf | awk '{print $7}'`
		portmap=`cat $RULE_FILE | grep $intf | awk '{print $8}'`
	else
		dns1=`cat $RULE_FILE | grep $intf | awk '{print $7}'`
		dns2=`cat $RULE_FILE | grep $intf | awk '{print $8}'`
		portmap=`cat $RULE_FILE | grep $intf | awk '{print $9}'`
	fi	

	if [ "$ipaddress" = "" ]; then
		exit 1
	fi
	echo "$0 $1 $2 $ipaddress $netmask $gateway $dns1 $dns2 $portmap"
	
	cat $RULE_FILE | grep -v $intf > $RULE_FILE_TMP
	mv $RULE_FILE_TMP $RULE_FILE

	name_pre=`echo $intf | cut -c 1-3`
	if [ "$name_pre" = "ppp" ]; then
		name=`cat $INTERNET_INFO | grep $intf | awk -F '_' '{print $1}'`	
	else
		name=$intf
	fi
	
	cat $INTERNET_INFO | grep -v "${name}_" > $RULE_FILE_TMP
	mv $RULE_FILE_TMP $INTERNET_INFO
	
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
		m=$((13-$i))
		
		mi=$((100+$i))
		#echo "i=$i, n=$n"
		
		bit=`echo $portmap | cut -c $i`
		if [ "$bit" = "1" ]; then
			msk=0x${n}0000000
			
			if [ "$3" != "wancc" ]; then
				#add rule: drop packets in FORWARD
				iptables -A FORWARD -m mark --mark ${msk}/0xf0000000 -j DROP
				echo "iptables -A FORWARD -m mark --mark ${msk}/0xf0000000 -j DROP"
			fi
			
			#delete route table
			ip rule delete iif br0 fwmark ${msk}/0xf0000000  table ${mi}
			echo "ip rule delete iif br0 fwmark ${msk}/0xf0000000  table ${mi}"
			#delete from ipaddress table
			ip rule delete from $ipaddress table ${mi}	
			#delete ebtbles
			ebtables -t broute -D BROUTING  -p 0x0800 -i ${ks} -j mark --mark-or ${msk}
			echo "ebtables -t broute -D BROUTING  -p 0x0800 -i ${ks} -j mark --mark-set ${msk}"
			
			
			#flush route table
			ip route flush table ${mi}
			echo "ip route flush table ${mi}"
		fi
	done

	#delete dns route rule
	if [ "$dns1" != "" ]; then
		ip route delete $dns1 via $gateway dev $intf
		echo "ip route delete $dns1 via $gateway dev $intf"
	fi
	if [ "$dns2" != "" ]; then
		ip route delete $dns2 via $gateway dev $intf
		echo "ip route delete $dns2 via $gateway dev $intf"
	fi

	#刷新路由表，使新配置的路由生效
	ip route flush cache
	echo "ip route flush cache"

else
	echo -e "Usage:\tpolicy_route.sh add [interface] [ipadress] [netmask] [gateway] [dns1] [dns2] [portmap]"
	echo -e "\tpolicy_route.sh delete [interface]"
fi

exit 0
