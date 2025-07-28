#!/bin/sh

COMMON_CONF=/etc/fh_common.conf
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FHBOX_BIN=`grep "FHBOX_BIN" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_SHELL=`grep "APP_SHELL_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `

. /var/WEB-GUI/hgcxml.conf

if [ ! -f "$FW_LOCATE_CONF/fw.conf" ] 
then 
	echo -e "Error:there is no configuration file  $FW_LOCATE_CONF/fw.conf \n"	
	exit 1
fi

[ -e $FW_LOCATE_SHELL/fw_common.sh ] && . $FW_LOCATE_SHELL/fw_common.sh

FW_VAR=/var/firewall  

. $FW_LOCATE_CONF/fw.conf
. $FW_VAR/fw.conf

$IPTABLES -t nat -F safe_port_map
$IPTABLES -F safe_port_map

if [ "$WAN_LINE_TYPE" = "NULL" ] || [ "$WAN_LINE_NUM" = "NULL" ]
then
	exit 0
fi
if [ "$1" != "$WAN_LINE_NUM" ]
then
	echo "$1 NOT internet link,not run portmap "
	exit 0 
fi
if [ -z "$INET_IFACE" ] || [ "$INET_IFACE" = "NULL" ] || [ "$INET_IP" = "NULL" ]
then
	exit 0
fi

if [ $# != 3 ]
then
	echo "please input 2 parameter IGD_WAND_1_WANCD_${1}_WANIPC_%{2}_PM_1_PortMappingEnabled "
exit 0
fi

for i in 1 2 3 4 5 6 7 8
do
	local addRule=0
	local REMOTE=""
	if [ $3 != "PPPOE" ]
	then
		eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANIPC_${2}_PM_${i}_PortMappingEnabled}"
		Enable=`$FHBOX_BIN/inter_web get $Enable_seq`
		if [ $Enable = "1&" ]
		then
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANIPC_${2}_PM_${i}_RemoteHost}"
			RemoteHost=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANIPC_${2}_PM_${i}_ExternalPort}"
			ExternalPort=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANIPC_${2}_PM_${i}_InternalPort}"
			InternalPort=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANIPC_${2}_PM_${i}_PortMappingProtocol}"
			Protocol=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANIPC_${2}_PM_${i}_InternalClient}"
			InternalClient=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			
			addRule=1
		fi
	else
		eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANPPPC_${2}_PM_${i}_PortMappingEnabled}"
		Enable=`$FHBOX_BIN/inter_web get $Enable_seq`
		if [ $Enable = "1&" ]
		then
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANPPPC_${2}_PM_${i}_RemoteHost}"
			RemoteHost=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANPPPC_${2}_PM_${i}_ExternalPort}"
			ExternalPort=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANPPPC_${2}_PM_${i}_InternalPort}"
			InternalPort=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANPPPC_${2}_PM_${i}_PortMappingProtocol}"
			Protocol=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			eval Enable_seq="\${IGD_WAND_1_WANCD_${1}_WANPPPC_${2}_PM_${i}_InternalClient}"
			InternalClient=`$FHBOX_BIN/inter_web get $Enable_seq |cut -d "&" -f 1`
			
			addRule=1
			
		fi
	fi
	#Description="Description${i}"
	
	if [ 1 = $addRule ];then
		if [ "x$RemoteHost" != "x" ] && [ "x$RemoteHost" != "xNULL" ];then
			REMOTE="-s ${RemoteHost}"
		else
			REMOTE=""
		fi
		
		if [ x"BOTH" = x"${Protocol}" ];then
			$IPTABLES -t nat -A safe_port_map  -i $INET_IFACE ${REMOTE} -d $INET_IP -p tcp --dport ${ExternalPort} \
-j DNAT --to-destination ${InternalClient}:${InternalPort}
			$IPTABLES -t filter -A safe_port_map -i $INET_IFACE ${REMOTE} -p tcp  \
-d ${InternalClient} --dport ${InternalPort} -j ACCEPT

			$IPTABLES -t nat -A safe_port_map  -i $INET_IFACE ${REMOTE} -d $INET_IP -p udp --dport ${ExternalPort} \
-j DNAT --to-destination ${InternalClient}:${InternalPort}
			$IPTABLES -t filter -A safe_port_map -i $INET_IFACE ${REMOTE} -p udp  \
-d ${InternalClient} --dport ${InternalPort} -j ACCEPT
		else
			$IPTABLES -t nat -A safe_port_map  -i $INET_IFACE ${REMOTE} -d $INET_IP -p ${Protocol} --dport ${ExternalPort} \
-j DNAT --to-destination ${InternalClient}:${InternalPort}
			$IPTABLES -t filter -A safe_port_map -i $INET_IFACE ${REMOTE} -p ${Protocol}  \
-d ${InternalClient} --dport ${InternalPort} -j ACCEPT
		fi
	fi
done

clear_fastpath
