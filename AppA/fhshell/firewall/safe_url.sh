#!/bin/sh

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

$IPTABLES -F safe_url_filter

if [ -z "$INET_IFACE" ] || [ "$INET_IFACE" = "NULL" ]
then
	exit 0
fi

if [ ! -f "$FW_LOCATE_CONF/white_url.conf" ] || [ ! -f "$FW_LOCATE_CONF/black_url.conf" ]
then 
	echo -e "Error:there is no url cfg file   \n"	
	exit 1
fi

if [ "$STATUS_URL_FILTER" = "0" ]
then 
	exit 0
fi

#CTRL_URL_FILTER=`grep "CTRL_URL_FILTER=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
if [ "$CTRL_URL_FILTER" = "white" ]
then
	URL_CFG_FILE=$FW_LOCATE_CONF/white_url.conf
	RESULT_ACTION="ACCEPT"
	DEFAULT_ACTION="DROP"
elif [ "$CTRL_URL_FILTER" = "black" ]
then
	URL_CFG_FILE=$FW_LOCATE_CONF/black_url.conf
	RESULT_ACTION="DROP"
	DEFAULT_ACTION="ACCEPT"
else
	exit 1
fi

echo "$CTRL_URL_FILTER:URL_CFG_FILE=$URL_CFG_FILE,RESULT_ACTION=$RESULT_ACTION,DEFAULT_ACTION=$DEFAULT_ACTION"
count=`grep "count=" $URL_CFG_FILE | cut -d = -f 2 `
if [ "$count" = "0" ]
then
	echo "count=0,exit"
	clear_fastpath
	exit 0
fi

rowindex=0
while read LINE
do
	rowindex=$((rowindex+1))
	if [ "$rowindex" = "1" ]
	then
		continue
	fi
	if [ -z "$LINE" ]
	then 
		echo "This is a null line"
		continue 
	fi
	FLAG=`echo $LINE | grep '#'`
	if [ ! -z "$FLAG" ]; then
		continue
	fi
	
	port=`echo $LINE | cut -d ';' -f 1`

	if [ -z "$port" ]
	then
		port=80
	fi
	
	x=`echo $LINE | cut -d ';' -f 2`
	y=`echo $x | cut -d '/' -f 1 `
	
	if [ "$CTRL_URL_FILTER" = "white" ]
	then
		HOST="$y"
	else
		HOST="Host: $y"
	fi
	echo "$rowindex: $port,$y,$HOST"
	$IPTABLES -A safe_url_filter -p tcp --dport $port -m string --string "${HOST}" --algo bm -j $RESULT_ACTION
	
done < $URL_CFG_FILE

if [ "$CTRL_URL_FILTER" = "white" ]
then
	$IPTABLES -A safe_url_filter -p tcp --dport 80 -m string --string "GET" --algo bm -j $DEFAULT_ACTION
fi

clear_fastpath

