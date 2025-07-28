#! /bin/sh

COMMON_CONF=/etc/fh_common.conf
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_SHELL=`grep "APP_SHELL_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `

if [ ! -f "$FW_LOCATE_CONF/fw.conf" ] 
then 
	echo -e "Error:there is no configuration file  $FW_LOCATE_CONF/fw.conf \n"	
	exit 1
fi

[ -e $FW_LOCATE_SHELL/fw_common.sh ] && . $FW_LOCATE_SHELL/fw_common.sh

FW_VAR=/var/firewall  

. $FW_LOCATE_CONF/fw.conf
. $FW_VAR/fw.conf

$IPTABLES -t nat -F safe_dmz
$IPTABLES -F safe_dmz

if [ -z "$INET_IFACE" ] || [ "$INET_IFACE" = "NULL" ]
then
	exit 0
fi

echo "DMZ_HOST_IP=$DMZ_HOST_IP"
if [ -z "$DMZ_HOST_IP" ] || [ "$DMZ_HOST_IP" = "NULL" ] 
then
	clear_fastpath
	exit 1
fi

$IPTABLES -t nat -A safe_dmz -i $INET_IFACE -p udp --dport 8099 -j ACCEPT
$IPTABLES -t nat -A safe_dmz -i $INET_IFACE -p tcp --dport 8099 -j ACCEPT
$IPTABLES -t nat -A safe_dmz -i $INET_IFACE -j DNAT --to-destination $DMZ_HOST_IP
$IPTABLES -A safe_dmz -i $INET_IFACE -d $DMZ_HOST_IP -j ACCEPT

clear_fastpath