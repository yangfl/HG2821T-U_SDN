#!/bin/sh

COMMON_CONF=/etc/fh_common.conf
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_SHELL=`grep "APP_SHELL_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `

if [ ! -f "$FW_LOCATE_CONF/fw.conf" ] 
	then 
	echo -e "Error:there is no configuration file  $FW_LOCATE_CONF/fw.conf \n"	
	exit 0
fi

[ -e $FW_LOCATE_SHELL/fw_common.sh ] && . $FW_LOCATE_SHELL/fw_common.sh

FW_VAR=/var/firewall  

. $FW_LOCATE_CONF/fw.conf
. $FW_VAR/fw.conf

LAN_IP=`ifconfig $LAN_IFACE | egrep "inet addr:" | \
		sed -e 's/^.*inet addr:\([0-9.][0-9.]*\) .*/\1/'`
LAN_IP_RANGE=`echo $LAN_IP | sed -e 's/\.[0-9]*$/.0\/24/'`

LAN_BCAST=`ifconfig $LAN_IFACE | egrep "Bcast:" | \
		sed -e 's/^.*Bcast:\([0-9.][0-9.]*\) .*/\1/'`

LO_IFACE="lo"

IP6TABLES=ip6tables

echo "	uplink($INET_IFACE) lan($LAN_IFACE,$LAN_IP) "
$IPTABLES -P OUTPUT ACCEPT

flushLvlTbl()
{
	$IPTABLES -F INPUT_BOUND
	$IPTABLES -F bad_packets
	$IPTABLES -F icmp_packets
	$IPTABLES -F INPUT_OTHERS
	$IP6TABLES -F INPUT_OTHERS
	$IPTABLES -F FORWARD_OTHERS
}

do_INPUT_BOUND()
{
	local DeviceTypeStr
	
	DeviceTypeStr=`getcfgx /var/WEB-GUI/webgui.conf DeviceType`
	$IPTABLES -A INPUT_BOUND  -p tcp --dport 21 --tcp-flags SYN,RST,ACK SYN -j LOG --log-prefix "$DeviceTypeStr:Recv a FTP Req " --log-level 4
	
	if [ "$FW_LEVEL" = "low" ];then
		for x in ${TCP_DROP_PORT_LOW}
		do
			$IPTABLES -A INPUT_BOUND -p tcp --dport ${x} -j DROP
		done
		
		for x in ${UDP_DROP_PORT_LOW}
		do
			$IPTABLES -A INPUT_BOUND -p udp --dport ${x} -j DROP
		done
	else
		for x in ${UDP_ALLOW_PORT}
		do
			$IPTABLES -A INPUT_BOUND -p udp --dport ${x} -j ACCEPT
		done

		for x in ${TCP_ALLOW_PORT}
		do
			$IPTABLES -A INPUT_BOUND -p tcp --dport ${x} -j ACCEPT
		done
	fi
}

#  bad_packets chain
do_bad_packets()
{
	$IPTABLES -A bad_packets -m state --state INVALID -j DROP
	$IPTABLES -A bad_packets -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
	$IPTABLES -A bad_packets -p tcp ! --syn -m state --state NEW -j DROP
}

do_icmp_packets()
{
	# ICMP packets should fit in a Layer 2 frame, thus they should
	# never be fragmented.  Fragmented ICMP packets are a typical sign
	# of a denial of service attack.
	# $IPT -A icmp_packets --fragment -p ICMP -j LOG \
	#    --log-prefix "ICMP Fragment: "  ---add by lhj
	#
	# ICMP rules

	#$IPTABLES -A INPUT -p ICMP -i $INET_IFACE -j icmp_packets
	if [ "$FW_LEVEL" = "middle" ]
	then
		$IPTABLES -A icmp_packets --fragment -p ICMP -j DROP
		$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j ACCEPT
		# Time Exceeded
		$IPTABLES -A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT
		# Not matched, so return so it will be logged  ---add by lhj
		$IPTABLES -A icmp_packets -p ICMP -j RETURN
	fi
}

do_INPUT_OTHERS()
{
	$IPTABLES -A INPUT_OTHERS -i $LO_IFACE -j ACCEPT
	
	$IPTABLES -A INPUT_OTHERS -i $LAN_IFACE  -j ACCEPT 
	#add by lhj ,accept the broad bcast from local
	#$IPTABLES -A INPUT_OTHERS -i $LAN_IFACE -d $LAN_BCAST -j ACCEPT
	#
	# Special rule for DHCP requests from LAN, which are not caught properly
	# otherwise.
	#
	#$IPTABLES -A INPUT_OTHERS -p UDP -i $LAN_IFACE --dport 67 --sport 68 -j ACCEPT
	$IPTABLES -A INPUT_OTHERS ! -i $LAN_IFACE  -m  state --state ESTABLISHED,RELATED -j ACCEPT
	$IPTABLES -A INPUT_OTHERS -p udp -d 224.0.0.0/3  -j ACCEPT
	
	#accept igmp
	$IPTABLES -A INPUT_OTHERS -p 2 -j ACCEPT
	
	#for ipv6
	$IP6TABLES -A INPUT_OTHERS ! -i $LAN_IFACE -p tcp --dport 8080 -j REJECT --reject-with tcp-reset
}

do_FORWARD_OTHERS()
{
	$IPTABLES -A FORWARD_OTHERS -i $LAN_IFACE -j ACCEPT
	$IPTABLES -A FORWARD_OTHERS ! -i $LAN_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPTABLES -A FORWARD_OTHERS -p udp -d 224.0.0.0/3 -j ACCEPT
}


flushLvlTbl

if [ "$FW_LEVEL" = "high" ]
then
	$IPTABLES -P OUTPUT ACCEPT
	$IPTABLES -P INPUT DROP
	$IPTABLES -P FORWARD DROP
	
	UDP_ALLOW_PORT=`grep "UDP_ALLOW_PORT_HIGH="  $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
	TCP_ALLOW_PORT=`grep "TCP_ALLOW_PORT_HIGH="  $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
	
	do_INPUT_BOUND
	do_bad_packets
	do_INPUT_OTHERS
	do_FORWARD_OTHERS
elif [ "$FW_LEVEL" = "middle" ]
then
	$IPTABLES -P OUTPUT ACCEPT
	$IPTABLES -P INPUT DROP
	$IPTABLES -P FORWARD DROP
	
	UDP_ALLOW_PORT=`grep "UDP_ALLOW_PORT_MIDDLE="  $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
	TCP_ALLOW_PORT=`grep "TCP_ALLOW_PORT_MIDDLE="  $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
	
	do_INPUT_BOUND
	do_bad_packets
	do_icmp_packets
	do_INPUT_OTHERS
	do_FORWARD_OTHERS
else
	$IPTABLES -P OUTPUT ACCEPT
	$IPTABLES -P INPUT ACCEPT
	$IPTABLES -P FORWARD ACCEPT
	#TCP_DROP_PORT_LOW=`grep "TCP_DROP_PORT_LOW="  $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
	do_INPUT_BOUND
fi

clear_fastpath

echo "ok ,firewall setting $FW_LEVEL successfully!"
