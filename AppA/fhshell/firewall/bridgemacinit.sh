#!/bin/sh

#-----lqu modify 20120731
COMMON_CONF=/etc/fh_common.conf
#FW_LOCATE_CONF=/etc/app_conf/firewall
MISC_SHELL_PATH_GETCFG=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `
#-------

if [ ! -f /var/bridge_port ]
then 
	echo "No Mac filter conf file"
	exit 0
fi

BRIDGE_IFACE=`grep "bridgeport="  /var/bridge_port | cut -d = -f 2 `
if [ -z ${BRIDGE_IFACE} ]
then
	echo "No bridge Port"
	exit 0
fi
echo "Bride Iface:$BRIDGE_IFACE"
if [ -f $FW_LOCATE_CONF/bridgemac.conf ]; then
	COUNT=1
	while [ $COUNT -le 16 ]
	do
		MACADDR=`$MISC_SHELL_PATH_GETCFG $FW_LOCATE_CONF/bridgemac.conf mac$COUNT`
		if [ "$MACADDR" != "disable" ]; then
			for x in ${BRIDGE_IFACE}
		   do
				RETURNSTR=`$FHBOX_PATH/ebtables -A FORWARD  -i ${x} -s $MACADDR -j DROP`
			done
		fi
		COUNT=$(($COUNT+1))
	done
else
	echo " $FW_LOCATE_CONF/bridgemac.conf does not exist!"
fi



