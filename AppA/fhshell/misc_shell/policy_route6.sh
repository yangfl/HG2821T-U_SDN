#!/bin/sh

#添加规则
#Usage: policy_route.sh  [interface] [old_gateway] [gateway] [service] 
#		policy_route.sh  [wan接口名称] [old 网关] [新网关] [连接类型] [dns1] [dns2] [绑定LAN端口，8位二进制]
#Example: policy_route.sh add pon0.123 10.96.15.77 255.255.0.0 10.96.1.254 10.19.8.10 10.19.8.15 00001100
#
#删除规则
#Usage: policy_route.sh delete [interface]
#		policy_route.sh delete [wan接口名称][绑定LAN端口，8位二进制]
#Example: policy_route.sh delete pon0.123
RULE_FILE=/var/rule_table6
ROUTE_PATH=/var/internet_route.info
COMMON_CONF=/etc/fh_common.conf
FHBOX_BIN=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `
GETCFG=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2 `
SETCFG=`grep "MISC_SHELL_PATH_SETCFG=" $COMMON_CONF | cut -d = -f 2 `
echo "$0 $1 $2 $3 $4 $5" >> $RULE_FILE
interface=$1
old_gateway=$2
gateway=$3
service=$4
ifname=$5
if [ "x$ifname" = "x" ]; then

	name_pr=`echo $interface | cut -c 1-3`
	if [ "$name_pr" = "ppp" ]; then
		ifname=`cat /var/run/wan_ppp.conf |grep $interface|cut -d = -f 1`
	else
		ifname=$interface
	fi
fi
old_pid=`cat /var/pid_6c_ru|grep policy_route.sh_$interface|cut -d = -f 2`
if [ "x${old_pid}" != "x" ]
then
	kill -9 ${old_pid}
	cat /var/pid_6c_ru | grep -v policy_route.sh_$interface > /var/pid_6c_ru.bak
	mv /var/pid_6c_ru.bak /var/pid_6c_ru
fi
echo policy_route.sh_$interface=$$>>/var/pid_6c_ru
tearDown_Route6()
{
	echo "tearDown_Route6 table $table"
	table_ip=`ip -6 rule|grep $table |cut -d ' ' -f 2|head -1`
	echo "table_ip 000$table_ip"
	ip -6 route flush table $table 
	echo "table_ip1111 $table_ip"
	ip -6 rule del from $table_ip table $table pref $pref
	echo "ip -6 rule del from $table_ip table $table pref $pref"
	echo "table_ip 2222$table_ip"
	ip -6 rule del table $table pref $pref
	echo "table_ip3333 $table_ip"
}
do_Route6()
{
	echo "do_Route6 table $table">>/var/aa
	ip -6 rule add from $ipv6 table $table pref $pref
	ip -6 route add default via $gateway dev $interface table $table pref $pref
	ip -6 route add $ipv6 dev $interface table $table pref $pref
}
do_Route6_init()
{
	service_voip=`echo $service|grep VOIP`
	service_tr069=`echo $service|grep TR069`
	service_internet=`echo $service|grep INTERNET`
	echo "$service_voip $service_tr069 $service_internet"
	if [ "x$service_internet" != "x" ]
	then
		ip -6 ro add default via $gateway dev $interface
		echo "aaaaaa$gateway vs $interface"
	fi
	if [ "x$service_tr069" != "x" ]
	then
		table=501
		pref=16383
		do_Route6
	fi
	if [ "x$service_voip" != "x" ] && [ "x$service_tr069" = "x" ]
	then
		table=502
		pref=16384
		do_Route6
	fi
	/rom/fhshell/misc_shell/ipforwardv6.sh add $ifname $gateway
	if [ -f $ROUTE_PATH ]
then
	IF_INTERNET=`cat $ROUTE_PATH |grep ${ifname}`
	if [ ! -z "$IF_INTERNET" ]
	then
		portmap=""
		for i in 1 2 3 4 5 6 7 8 9 10 11 12
		do
			interface_conf=`$GETCFG $ROUTE_PATH LAN$i`
			if [ ${interface_conf} = ${ifname} ]
			then
				portmap="1"${portmap}
			else
				portmap="0"${portmap}
			fi
		done
		PR_enable=`$GETCFG $ROUTE_PATH ${ifname}_flagv6`
		if [ "x$PR_enable" != "x1" ]
		then
			$SETCFG $ROUTE_PATH ${ifname}_flagv6 1
			/rom/fhshell/misc_shell/policy_bindv6.sh add ${interface} ${ipv6} ${gateway} ${portmap}
			echo " /rom/fhshell/misc_shell/policy_bindv6.sh add ${interface} ${ipv6} ${gateway} ${portmap} " 
		fi
	fi
fi


}
tearDown_Route6_init()
{
	service_voip=`echo $service|grep VOIP`
	service_tr069=`echo $service|grep TR069`
	service_internet=`echo $service|grep INTERNET`
echo "$service_voip $service_tr069 $service_internet"
	if [ "x$service_internet" != "x" ]
	then
		ip -6 ro del default via $old_gateway dev $interface
		#echo "3333333333333 $service_tr069 $service_internet"
	fi
	#echo "11111 $service_tr069 $service_internet"
	if [ "x$service_tr069" != "x" ]
	then
		table=501
		pref=16383
		tearDown_Route6
	fi
	#echo "2222222222 $service_tr069 $service_internet"
	if [ "x$service_voip" != "x" ] && [ "x$service_tr069" = "x" ]
	then
		table=502
		pref=16384
		tearDown_Route6
	fi 

	/rom/fhshell/misc_shell/ipforwardv6.sh del $ifname 

	/rom/fhshell/misc_shell/policy_bindv6.sh delete ${interface} 
	
}
if [ $old_gateway != "NULL" ]
then
	tearDown_Route6_init
# the connect is new,
fi

if [ $gateway == "NULL" ]
then
exit 0
# the connect is del , do nothing
fi

intf=`ifconfig |grep $interface |cut -d " " -f 1`
while [ $intf ]
do
ipv6=`ifconfig $1 |grep 'Scope:Global' | cut -d ' ' -f 13|cut -d / -f 1|head -1`
	if [ "x$ipv6" != "x" ]
	then
	echo "while interface $interface ipv6 $ipv6">>/var/aa
	#add by xushili for ipv6 notify
	notify [IPV6#$ifname#$interface#$ipv6#] 18302&
		do_Route6_init
		break
	fi
intf=`ifconfig |grep $1 |cut -d " " -f 1`
sleep 5
done
cat /var/pid_6c_ru | grep -v policy_route.sh_$interface=$$ > /var/pid_6c_ru.bak
mv /var/pid_6c_ru.bak /var/pid_6c_ru
