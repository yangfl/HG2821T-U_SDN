#!/bin/sh

COMMON_CONF=/etc/fh_common.conf
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_SHELL=`grep "APP_SHELL_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `

#FW_LOCATE=/flash/cfg/app_conf/firewall/
if [ ! -f "$FW_LOCATE_CONF/fw.conf" ] 
	    then 
		echo -e "Error:there is no configuration file  $FW_LOCATE_CONF/fw.conf \n"	
		exit 0
fi

[ -e $FW_LOCATE_SHELL/fw_common.sh ] && . $FW_LOCATE_SHELL/fw_common.sh

FW_VAR=/var/firewall  

. $FW_LOCATE_CONF/fw.conf	
. $FW_VAR/fw.conf

$IPTABLES -F safe_dos

if [ -z "$INET_IFACE" ] || [ "$INET_IFACE" = "NULL" ]
then
	exit 0
fi

if [ "$STATUS_DOS_HACK"  = "yes" ];then
	$IPTABLES -A safe_dos ! -i ${INET_IFACE} -j RETURN
	$IPTABLES -A safe_dos -p tcp --syn -m limit --limit 100/s --limit-burst 200 -j RETURN
	$IPTABLES -A safe_dos -p tcp --syn -j DROP
	$IPTABLES -A safe_dos -p icmp -m state --state NEW -m limit --limit 50/s --limit-burst 100 -j RETURN
	$IPTABLES -A safe_dos -p icmp -m state --state NEW -j DROP
	$IPTABLES -A safe_dos -p tcp -m state --state NEW -m limit --limit 100/s --limit-burst 200 -j RETURN
	$IPTABLES -A safe_dos -p tcp -m state --state NEW -j DROP
	$IPTABLES -A safe_dos -p udp -m state --state NEW -m limit --limit 100/s --limit-burst 200 -j RETURN
	$IPTABLES -A safe_dos -p udp -m state --state NEW -j DROP
fi

clear_fastpath


