#!/bin/sh

#-----lqu modify 20120816
COMMON_CONF=/etc/fh_common.conf
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `

FILE=`grep "MISC_CONF_PATH_LOID=" $COMMON_CONF | cut -d = -f 2 `

if [ "$#" != "2" ]; then
	echo "Usage: $0 loid password"
	exit 0
fi

LOID=`$FHBOX_PATH/getcfgx $FILE loid`
PWD=`$FHBOX_PATH/getcfgx $FILE password`

if [ "$LOID" != "$1" -o "$PWD" != "$2" ]; then
	$FHBOX_PATH/setcfgx $FILE loid "$1"
	$FHBOX_PATH/setcfgx $FILE password "$2"
	led_ctrl set xvr_tx off
	sleep 1
	led_ctrl set xvr_tx on
fi
