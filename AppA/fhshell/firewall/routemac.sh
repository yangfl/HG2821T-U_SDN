#!/bin/sh

COMMON_CONF=/etc/fh_common.conf
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
MISC_SHELL_PATH_GETCFG=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_SHELL=`grep "APP_SHELL_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `

if [ ! -f "$FW_LOCATE_CONF/fw.conf" ]
then
   echo -e "Error there is no configuration file $FW_LOCATE_CONF/fw.conf \n"
   exit 1
fi

[ -e $FW_LOCATE_SHELL/fw_common.sh ] && . $FW_LOCATE_SHELL/fw_common.sh

FW_VAR=/var/firewall  

. $FW_LOCATE_CONF/fw.conf
. $FW_VAR/fw.conf

#STATUS_MAC_FILTER=`grep "STATUS_MAC_FILTER=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2`
echo $STATUS_MAC_FILTER
#INET_IFACE=`grep "INET_IFACE=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `

$IPTABLES -t filter -F MAC_FILTER

if [ ! -f $FW_LOCATE_CONF/white_routemac.conf ] ||[ ! -f $FW_LOCATE_CONF/black_routemac.conf ] ; then
	echo -e "Error :there is no mac mac cfg file "
	exit
fi

if [ "$STATUS_MAC_FILTER" = "0"  ]
then
	clear_fastpath
	exit 0
fi

CTRL_MAC_FILTER=`grep "CTRL_MAC_FILTER=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2`
if [ "$CTRL_MAC_FILTER" = "black" ]
then
	COUNT=1
	while [ $COUNT -le 16 ]
	do
		MACADDR=`$MISC_SHELL_PATH_GETCFG $FW_LOCATE_CONF/black_routemac.conf mac$COUNT`
		if [ "$MACADDR" != "disable" ]; then
			$IPTABLES -A MAC_FILTER -m mac --mac-source $MACADDR -j DROP
		fi
		COUNT=$(($COUNT+1))
	done
else
	COUNT=1
	local flag=0
	while [ $COUNT -le 16 ]
	do
		MACADDR=`$MISC_SHELL_PATH_GETCFG $FW_LOCATE_CONF/white_routemac.conf mac$COUNT`
		if [ "$MACADDR" != "disable" ]; then
			$IPTABLES -A MAC_FILTER -m mac --mac-source $MACADDR -j ACCEPT
			flag=1
		fi
		COUNT=$(($COUNT+1))
	done

	if [ $flag = "1" ];then
		$IPTABLES -A MAC_FILTER -i br0  -j DROP
	fi
fi

clear_fastpath
