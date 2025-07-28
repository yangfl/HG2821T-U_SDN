#!/bin/sh

#-----lqu modify 20120731
COMMON_CONF=/etc/fh_common.conf
MISC_SHELL_PATH_SETCFG=`grep "MISC_SHELL_PATH_SETCFG=" $COMMON_CONF | cut -d = -f 2 `
MISC_SHELL_PATH_GETCFG=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_CONF=`grep "APP_CONF_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FW_LOCATE_SHELL=`grep "APP_SHELL_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
FILE_HGCXML_CONF=`grep "APP_CONF_PATH_TR069_HGCXML=" $COMMON_CONF | cut -d = -f 2 `
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `
INTER_WEB=$FHBOX_PATH/inter_web
UPNPD_CMD=`grep "APP_SHELL_PATH_UPNP_SHELL=" $COMMON_CONF | cut -d = -f 2 `
#--------

if [ ! -f "$FW_LOCATE_CONF/fw.conf" ] 
	    then 
		echo -e "Error:there is no configuration file  $FW_LOCATE_CONF/fw.conf \n"	
		exit 0
fi

echo "fw flush first..."
$FW_LOCATE_SHELL/fw.sh flush

FW_VAR=/var/firewall
defaultconf()
{
	rm -rf /var/firewall
	mkdir -p /var/firewall
	touch /var/firewall/fw.conf

	echo INET_IFACE=NULL >> /var/firewall/fw.conf
	echo INET_IP=NULL >> /var/firewall/fw.conf
	echo WAN_LINE_NUM=NULL >> /var/firewall/fw.conf
	echo WAN_LINE_TYPE=NULL >> /var/firewall/fw.conf
}
defaultconf

while :
do 

	if [ -f "/var/vpm_finished" ]
	then
		echo "vpm_finished OK........"
		break
	fi
	sleep 5
done
FW_VERSION=`grep "FW_VERSION="  $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
$MISC_SHELL_PATH_SETCFG /var/softversion   firewall  firewall.$FW_VERSION

for i in 1 2 3 4 5 6 7 8
do
	ip_enable_xml=`grep "IGD_WAND_1_WANCD_${i}_WANIPC_1_Enable" $FILE_HGCXML_CONF | cut -d = -f 2`
	ppp_enable_xml=`grep "IGD_WAND_1_WANCD_${i}_WANPPPC_1_Enable" $FILE_HGCXML_CONF | cut -d = -f 2`
	ppp_enable=`$INTER_WEB get $ppp_enable_xml`
	ip_enable=`$INTER_WEB get $ip_enable_xml`
	#eval vid_xml="\${IGD_WAND_1_WANCD_${i}_XCTCOMWANGLC_VLANIDMark}"
	vid_xml=`grep "IGD_WAND_1_WANCD_${i}_XCTCOMWANGLC_VLANIDMark" $FILE_HGCXML_CONF | cut -d = -f 2`
	echo "ip_enable_xml="$ip_enable_xml "ppp_enable_xml="$ppp_enable_xml
	CONNECT_LINE_VLANID=`$INTER_WEB get $vid_xml`
	echo "$i: pppen=$ppp_enable ipen=$ip_enable vid=$CONNECT_LINE_VLANID"

	if [ "$CONNECT_LINE_VLANID" = "NULL&" ]                                                        
	then
	continue
	fi
	CONNECT_LINE_NUM=$i
	if [ "x$ip_enable" = "x1&" ]
	then
		#eval LINE_SERVICE_LIST="\${IGD_WAND_1_WANCD_${i}_WANIPC_1_X_CT_COM_ServiceList}"
		LINE_SERVICE_LIST=`grep "IGD_WAND_1_WANCD_${i}_WANIPC_1_X_CT_COM_ServiceList" $FILE_HGCXML_CONF | cut -d = -f 2`
		CONNECT_LINE_TYPE="IP"
		CONNECT_LINE_NUM2=1
	fi
	
	if [ "x$ppp_enable" = "x1&" ]
	then
	for j in 1 2
	do
		#eval ppp_ConnectionType="\${IGD_WAND_1_WANCD_${i}_WANPPPC_${j}_ConnectionType}"
		ppp_ConnectionType=`grep "IGD_WAND_1_WANCD_${i}_WANPPPC_${j}_ConnectionType" $FILE_HGCXML_CONF | cut -d = -f 2`
		CONNECT_BRIDGE_ROUTE=`$INTER_WEB get $ppp_ConnectionType`
		CONNECT_LINE_NUM2=$j
		if [ "$CONNECT_BRIDGE_ROUTE" = "PPPoE_Bridged&" ]
		then
			echo "Sorry,this wan-pppoe link is bridge,not route, you should continue......"
			continue
		fi
		if [ "$CONNECT_BRIDGE_ROUTE" = "IP_Routed&" ]
		then
			#eval LINE_SERVICE_LIST="\${IGD_WAND_1_WANCD_${i}_WANPPPC_${j}_X_CT_COM_ServiceList}"
			LINE_SERVICE_LIST=`grep "IGD_WAND_1_WANCD_${i}_WANPPPC_${j}_X_CT_COM_ServiceList" $FILE_HGCXML_CONF | cut -d = -f 2`
			CONNECT_LINE_TYPE="PPPOE"
			break
		fi
	done
	fi
		
	z=`$INTER_WEB get $LINE_SERVICE_LIST`
	if echo "$z" | grep -q "INTERNET"
  	then
		FLAG="OK"
  		break;
	fi
	if [ "$z" = "ALL&" ] 
	then
	FLAG="OK"
		break;
	fi
done

if [ "$FLAG" != "OK" ]
then
	echo "sorry i cannot find any internet_route link!!"
	echo "so , i exit!!"
	exit 1
fi

#used for get the wan-interface,from /var/wanintf.conf
#but i must first determinated if exsit the file /var/wancc_finished!!
while :
do
	if [ -f  "/var/wancc_finished" ] && [ -f /var/wanintf.conf ]
	then 
		echo "OK,i find the file /var/wancc_finished and /var/wanintf.conf"
		while :
		do
			UPLINK=`grep "internetroute=" /var/wanintf.conf | cut -d = -f 2 `
			if [ "$UPLINK" != "-1" ]
			then
				echo "wancc has initialized!!"
				break
			fi
			echo "waiting for the wancc internetroute initializing..."
			sleep 20
		done
		echo "uplink:$UPLINK"
		break
	else
		echo "sorry i cannot find the /var/wanintf!! or  i cannot find the /var/wancc_finished!!"
		echo "please waiting..."
		sleep 20
	fi 
done

echo "CONNECT: $z LINE :$CONNECT_LINE_NUM TYPE:$CONNECT_LINE_TYPE "
if [ "$CONNECT_LINE_TYPE" = "PPPOE" ]
then
	if [ "$z" = "ALL&" ]  || [ "$z" = "TR069,INTERNET&" ] || [ "$z" = "INTERNET,TR069&" ] || [ "$z" = "TR069,VOIP,INTERNET&" ]
	then
		PPPOE_FILE="tr069_$UPLINK_*.info"
	elif [ "$z" = "VOIP,INTERNET&" ] || [ "$z" = "INTERNET,VOIP&" ] 
	then
		PPPOE_FILE="voip_$UPLINK_*.info"
	elif [ "$z" = "INTERNET&" ]
	then 
		PPPOE_FILE="internet_$UPLINK_*.info"
	elif echo "$z" | grep -q "TR069"
	then
		PPPOE_FILE="tr069_$UPLINK_*.info"
	elif echo "$z" | grep -q "VOIP"

	then
		PPPOE_FILE="voip_$UPLINK_*.info"
	else
		echo "err"
		exit 1
	fi
	echo "PPPOE_FILE=$PPPOE_FILE"
else
	CONNECT_LINE_TYPE_seq=`grep "IGD_WAND_1_WANCD_${CONNECT_LINE_NUM}_WANIPC_1_AddressingType=" $FILE_HGCXML_CONF | cut -d = -f 2`
	CONNECT_LINE_TYPE=`$INTER_WEB get $CONNECT_LINE_TYPE_seq | cut -d '&' -f 1`
	if [ "$CONNECT_LINE_TYPE" != "DHCP" ]
	then 
		CONNECT_LINE_TYPE="STATIC"
	fi
fi


UP_IFACE=$UPLINK
echo "UP_IFACE=$UP_IFACE"
$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   WAN_LINE_NUM  $CONNECT_LINE_NUM
$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   WAN_LINE_TYPE  $CONNECT_LINE_TYPE

#DHCP:
# 网口没有ip，循环
# 网口有ip
#	不相等：存储的有无ip， 重启，保存配置
#	相等，，
#		是第一次(boot)，重启，保存配置
#		不是第一次，但修改了防火墙等级(working_boot),重启，保存配置
#		不是第一次(work)，不重启，循环
#              即为work的时候重启


FW_STATUS="BOOT"
FW_LEVEL=`grep "FW_LEVEL=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
SLEEP_TIME=`grep "SLEEP_TIME=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
echo "sleep time =$SLEEP_TIME"
fw_run()
{
		echo "fw will start run...."
		FW_STATUS="WORK"
		$FW_LOCATE_SHELL/fw.sh 
		echo "level"
		$FW_LOCATE_SHELL/fw_level.sh 
		echo "dos"
	   $FW_LOCATE_SHELL/safe_dos.sh 
		echo "vs"
		$FW_LOCATE_SHELL/portmap.sh $CONNECT_LINE_NUM $CONNECT_LINE_NUM2 $CONNECT_LINE_TYPE
		echo "dmz"
		$FW_LOCATE_SHELL/safe_dmz.sh
		echo "url"
		$FW_LOCATE_SHELL/safe_url.sh
		echo "mac filter"
		$FW_LOCATE_SHELL/routemac.sh
		echo "port filter"
		$FW_LOCATE_SHELL/safe_port_filter.sh
		${UPNPD_CMD} &
}
fw_ip_new()
{
		echo "vs"
		$FW_LOCATE_SHELL/portmap.sh $CONNECT_LINE_NUM $CONNECT_LINE_NUM2 $CONNECT_LINE_TYPE
}

#STATUS_MSS=`grep "STATUS_MSS=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `
#MSS_VALUE=`grep "MSS_VALUE=" $FW_LOCATE_CONF/fw.conf | cut -d = -f 2 `

fw_mss_add()
{
	iptables -A chain_mss -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
}

# system not support pppoe proxy ,this is only a tmp rule

if [ -f "/var/pppoeproxyen"  ]
	then 
		echo "It is pppoe proxy "
	iptables -A FORWARD -i ppp+ -j ACCEPT
	iptables -I INPUT -s 192.168.18.0/24 -j ACCEPT
fi

#while :
#do 
	FLAG="ERROR"
	UPLINK_FW=`grep "INET_IFACE="  $FW_VAR/fw.conf | cut -d = -f 2 ` 
	UPLINK_FW_IP=`grep "INET_IP="  $FW_VAR/fw.conf | cut -d = -f 2 `

	if [ "$CONNECT_LINE_TYPE" = "STATIC" ]
	then
		STAIC_UP_IP=`ifconfig $UP_IFACE | egrep "inet addr:" | \
		sed -e 's/^.*inet addr:\([0-9.][0-9.]*\) .*/\1/'`
		$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   INET_IFACE  $UP_IFACE
		$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   INET_IP  $STAIC_UP_IP
		fw_run
		fw_mss_add
		echo "This is a Staic link ,Go"
		#break
	elif [ "$CONNECT_LINE_TYPE" = "DHCP" ]
	then
		DHCP_UP_IP=`ifconfig $UP_IFACE | egrep "inet addr:" | \
			sed -e 's/^.*inet addr:\([0-9.][0-9.]*\) .*/\1/'`
		#echo "DHCP_UP_IP=$DHCP_UP_IP  UPLINK_FW_IP=$UPLINK_FW_IP"		
		
		FLAG="OK"
		echo "The firwall start to  work first"
	 	$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   INET_IFACE  $UP_IFACE
		$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   INET_IP  $DHCP_UP_IP
		fw_run
		fw_mss_add
	else
		fp=`find /var/run/ -name  "$PPPOE_FILE" `
		for file in $fp
		do	
			PPPOE_IFACE=`grep "tty_device="  $file | cut -d = -f 2 `
			
			if [ "$PPPOE_IFACE" =  "$UP_IFACE" ] 
			then
				echo "Search the pppoe file $file"
				PPPOE_UPLINK=`grep "interface_name="  $file | cut -d = -f 2 `
				PPPOE_UP_IP=`grep "local_IP_address="  $file | cut -d = -f 2 `
				FLAG="OK"
				break
			fi
		done
		if [ "$FLAG" = "OK" ]
		then
			$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   INET_IFACE  $PPPOE_UPLINK
		 	$MISC_SHELL_PATH_SETCFG $FW_VAR/fw.conf   INET_IP  $PPPOE_UP_IP 
			fw_run
			fw_mss_add
		else
			echo "No change or no link ,searching it ......"
		fi
	fi
 
#	sleep $SLEEP_TIME
#done
