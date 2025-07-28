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

$IPTABLES -F safe_port_filter

if [ "$STATUS_PORT_FILTER" = "no" ]
	then 
	exit 0
fi

if [ -z "$INET_IFACE" ] || [ "$INET_IFACE" = "NULL" ]
then
	exit 0
fi

FILE_WHITE_CONF=$FW_LOCATE_CONF/white_port_filter.conf
FILE_BLACK_CONF=$FW_LOCATE_CONF/black_port_filter.conf
if [ ! -f $FILE_WHITE_CONF ];then 
	echo -e "Error:there is no configuration file  $FILE_WHITE_CONF \n"	
	exit 0
fi
if [ ! -f $FILE_BLACK_CONF ];then 
	echo -e "Error:there is no configuration file  $FILE_BLACK_CONF \n"	
	exit 0
fi

# port enable flag
WHITE_EANBLE="FALSE" 

portfilter()
{
	while read LINE 
	do 
		#echo $LINE
		if [ -z "$LINE" ]
		then
			continue
		fi
		
		FLAG=`echo $LINE | grep '#'`
		if [ ! -z "$FLAG" ]; then
			continue
		fi
		
		if [ "$FILTER_ACTION" = "ACCEPT" ]
		then
			WHITE_EANBLE="TRUE"
		fi
		
		FILTER_NAME=`echo $LINE | cut -d ' ' -f 1 | cut -d '=' -f 2`
		FILTER_PROTOCOL=`echo $LINE | cut -d ' ' -f 2 | cut -d '=' -f 2`
		FILTER_S_IP0=`echo $LINE | cut -d ' ' -f 3 | cut -d '=' -f 2`
		FILTER_S_IP1=`echo $LINE | cut -d ' ' -f 4 | cut -d '=' -f 2`
		FILTER_S_MASK=`echo $LINE | cut -d ' ' -f 5 | cut -d '=' -f 2`
		FILTER_S_PORT=`echo $LINE | cut -d ' ' -f 6 | cut -d '=' -f 2` 
		FILTER_D_IP0=`echo $LINE | cut -d ' ' -f 7 | cut -d '=' -f 2`
		FILTER_D_IP1=`echo $LINE | cut -d ' ' -f 8 | cut -d '=' -f 2`
		FILTER_D_MASK=`echo $LINE | cut -d ' ' -f 9 | cut -d '=' -f 2`
		FILTER_D_PORT=`echo $LINE | cut -d ' ' -f 10 | cut -d '=' -f 2` 
		FILTER_TYPE="IP_TYPE"
		
		if [ -z $FILTER_S_MASK ]
		then
			FILTER_S_MASK=32
		fi
		if [ -z $FILTER_D_MASK ]
		then
			FILTER_D_MASK=32
		fi
	# if protocol is "all",the 'sport' and 'dport' parameter can not be configured	
		if [ -z $FILTER_PROTOCOL ]
		then
			FILTER_PROTOCOL="all"
		else
			FILTER_PROTOCOL=`echo "$FILTER_PROTOCOL" | sed 's/\// /g'`
		fi
	#if protocol not tcp or udp ,sport can not be used
		
		if [ ! -z $FILTER_S_IP0 ] && [ ! -z $FILTER_S_IP1 ]
		then
			if [ ! -z $FILTER_D_IP0  ] && [ -z $FILTER_D_IP1  ]
			then
				FILTER_D_IP1=$FILTER_D_IP0
			fi
			FILTER_TYPE="IP_RANGE_TYPE"
		fi
		
		if [ ! -z $FILTER_D_IP0 ] && [ ! -z $FILTER_D_IP1 ]
		then
			if [ ! -z $FILTER_S_IP0  ] && [ -z $FILTER_S_IP1  ]
			then
				FILTER_S_IP1=$FILTER_S_IP0
			fi
			FILTER_TYPE="IP_RANGE_TYPE"
		fi
		
		for x in ${FILTER_PROTOCOL}
		do 
			echo "  name=$FILTER_NAME pro=$x act=$FILTER_ACTION,io=$FILTER_ASPECT" 
			if [ "$FILTER_TYPE" = "IP_TYPE" ]
			then 
				eval	$IPTABLES -A  safe_port_filter -i $FILTER_ASPECT ${x:+"-p $x"} \
				${FILTER_S_IP0:+" -s $FILTER_S_IP0/$FILTER_S_MASK"} ${FILTER_S_PORT:+"--sport $FILTER_S_PORT"}  \
				${FILTER_D_IP0:+" -d $FILTER_D_IP0/$FILTER_D_MASK"}  ${FILTER_D_PORT:+"--dport $FILTER_D_PORT"} \
				-j $FILTER_ACTION
			echo "  src $FILTER_S_IP0/$FILTER_S_MASK :$FILTER_S_PORT  des $FILTER_D_IP0/$FILTER_D_MASK:$FILTER_D_PORT"
			else
			 	eval	$IPTABLES -A  safe_port_filter -i $FILTER_ASPECT ${x:+"-p $x"} \
			 	-m iprange  ${FILTER_S_IP0:+" --src-range $FILTER_S_IP0-$FILTER_S_IP1" } \
			 	${FILTER_S_PORT:+"--sport $FILTER_S_PORT"}  \
			 	${FILTER_D_IP0:+" --dst-range $FILTER_D_IP0-$FILTER_D_IP1" } \
			 	${FILTER_D_PORT:+"--dport $FILTER_D_PORT"}  \
				-j $FILTER_ACTION
			echo "  src $FILTER_S_IP0-$FILTER_S_IP1 :$FILTER_S_PORT  des $FILTER_D_IP0-$FILTER_D_IP1:$FILTER_D_PORT"
			fi
		done
		
	done < $FILTER_FILE
}

FILTER_ASPECT=$INET_IFACE
FILTER_ACTION=ACCEPT
FILTER_FILE=$FILE_WHITE_CONF
portfilter

FILTER_ASPECT=$LAN_IFACE
FILTER_ACTION=DROP
FILTER_FILE=$FILE_BLACK_CONF
portfilter

if [ "$WHITE_EANBLE" = "TRUE" ]
then
	$IPTABLES -A safe_port_filter -i $INET_IFACE  -j DROP
fi

clear_fastpath
