#!/bin/sh
#-----lqu modify 20120731
COMMON_CONF=/etc/fh_common.conf
#FW_LOCATE_CONF=/etc/app_conf/firewall
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `

if [ "$1" != "del" ] && [ "$1" != "add" ]
then
	sed "No not del or add action"
	exit 0
fi


if [ -z "$2" ]
then
	sed "No Mac Parameter"
	exit 0 
fi 


if [ ! -f /var/bridge_port ]
then 
	sed "No Mac filter conf file"
	exit 0
fi

BRIDGE_IFACE=`grep "bridgeport="  /var/bridge_port | cut -d = -f 2 `
if [ -z $BRIDGE_IFACE ]
then
	sed "No bridge Port"
	exit 0
fi

if [ "$1" = "add" ]
	then
		for x in ${BRIDGE_IFACE}
		do
			$FHBOX_PATH/ebtables -I FORWARD  -i ${x} -s  $2 -j DROP
		done
		
	else
		for x in ${BRIDGE_IFACE}
		do
			$FHBOX_PATH/ebtables -D FORWARD  -i ${x} -s $2 -j DROP
		done
fi
		




