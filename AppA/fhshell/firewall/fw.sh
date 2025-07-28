#!/bin/sh
#

COMMON_CONF=/etc/fh_common.conf
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FW_VAR=/var/firewall 

if [ ! -f "$FW_LOCATE_CONF/fw.conf" ] || [ ! -f "$FW_VAR/fw.conf" ] 
then 
	echo -e "Error:there is no configuration file fw.conf \n"	
	exit 0
fi

. $FW_LOCATE_CONF/fw.conf	
. $FW_VAR/fw.conf

if [ -z "$INET_IFACE" ]
then
	exit 0
fi

fw_mss_del()
{
	$IPTABLES -D chain_mss -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
}
fw_mss_add()
{
	$IPTABLES -A chain_mss -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
}

clearnat()
{
	$IPTABLES -t nat -F safe_port_map
	$IPTABLES -t nat -F safe_dmz
	echo "Flush nat tbl over"
}
flushLvlTbl()
{
	$IPTABLES -F INPUT_BOUND
	$IPTABLES -F bad_packets
	$IPTABLES -F icmp_packets
	$IPTABLES -F INPUT_OTHERS
	$IPTABLES -F FORWARD_OTHERS
}

flush()
{
	echo "deleting Filter Tables ..."
	# Reset Default Policies
	$IPTABLES -P INPUT ACCEPT
	$IPTABLES -P FORWARD ACCEPT
	$IPTABLES -P OUTPUT ACCEPT

	fw_mss_del
	$IPTABLES -F MAC_FILTER
	$IPTABLES -F safe_url_filter
	$IPTABLES -F safe_port_filter
	
	$IPTABLES -F safe_port_map
	$IPTABLES -F safe_dmz
	
	$IPTABLES -F safe_dos

	$IPTABLES -F INPUT_BOUND

	flushLvlTbl

}
	

if [ "$1" = "flush" ]
then
	killall upnpd
	clearnat
	flush
	rm -rf /var/firewall
	echo "delete filter tbl ......"
	exit 0
elif [ "$1" = "" ]
then
	clearnat
elif [ "$1" = "setmss" ]
then
	fw_mss_add
	exit 0
elif [ "$1" = "clrmss" ]
then
	fw_mss_del
	exit 0
else
	echo "err command $1"
	exit 0
fi
echo -e "\tFiberhome cngi firewall  "



