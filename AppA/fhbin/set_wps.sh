#!/bin/sh
#./set_wps.sh open|close

COMMON_CONF=/etc/fh_common.conf
WLAN_BIN=`grep "APP_PATH_WLAN" $COMMON_CONF | cut -d = -f 2`
FHBIN=/usr/bin
#WLAN_CONF=`grep "APP_CONF_PATH_WLAN" $COMMON_CONF | cut -d = -f 2`

WSCD=/rom/fhbin/wscd
#IWCONTROL=${WLAN_BIN}/iwcontrol
GETCFGX=${FHBIN}/getcfgx
SETCFGX=${FHBIN}/setcfgx
XMLConfFile=/var/WEB-GUI/hgcxml.conf

XML_DIR=/var/wps
#SIMPLECFG_PATH=${WLAN_CONF}/simplecfgservice.xml
#WSCD_CONF=${WLAN_CONF}/wscd.conf
#WSC_OUT=/var/wsc-wlan0.conf
#FIFO_FILE=/var/wscd-wlan0.fifo
APCFG=/var/wlan/apcfg
SSIDdevice=ra0
PASSTWO=""

#以/flash/cfg/wlan_conf/wscd.conf为基础，获取wlan0的配置，生成/var/wsc-wlan0.conf
init_wps_conf() {
	if [ ! -f ${APCFG} ]; then
		echo "${APCFG} is missing"
		exit 1
	fi
	
	#get /var/wps/simplecfgservice.xml
	rm -rf $XML_DIR
	mkdir -p $XML_DIR
	cp -rf $SIMPLECFG_PATH $XML_DIR
	
	#get /var/wsc-wlan0.conf
	cp -rf $WSCD_CONF $WSC_OUT
	
	#mode
	#mode_value=`${GETCFGX} ${APCFG} wps_mode`
	#${SETCFGX} $WSC_OUT mode $mode_value
	
	#upnp
	#upnp_value=`${GETCFGX} ${APCFG} upnp`
	#${SETCFGX} $WSC_OUT upnp $upnp_value
	
	#config_method: Pin+PBC+Ethernet
	#config_method_value=`${GETCFGX} ${APCFG} config_method`
	#${SETCFGX} $WSC_OUT config_method $config_method_value
	
	#wlan0_wsc_disabled
	wps_enable_value=`${GETCFGX} ${APCFG} wps_enable`
	if [ "${wps_enable_value}" = "1" ]; then
		wsc_disabled=0
	else
		wsc_disabled=1
	fi
	${SETCFGX} $WSC_OUT wlan0_wsc_disabled $wsc_disabled
	
	#auth_type
	auth_type=`${GETCFGX} ${APCFG} AUTHMODE_0`
	if [ "${auth_type}" = "wpa2" ]; then
		${SETCFGX} $WSC_OUT auth_type 32
	elif [ "${auth_type}" = "wpa_wpa2_mixed" ]; then
		${SETCFGX} $WSC_OUT auth_type 34
	else
		echo "WPS error: WPS2.x only support WPA2 or WPA/WPA2 mixed auth mode"
		exit 1
	fi	
	
	#encrypt_type
	encmode_type=`${GETCFGX} ${APCFG} ENCRYPTYPE_0`
	if [ "${encmode_type}" = "aes" ]; then
		${SETCFGX} $WSC_OUT encrypt_type 8
	elif [ "${encmode_type}" = "aes+tkip" ]; then
		${SETCFGX} $WSC_OUT encrypt_type 12
	else
		echo "WPS error: WPS2.x only support AES or AES/TKIP mixed encrypt mode"
		exit 1
	fi	
	
	#connection_type
	#connection_type_value=`${GETCFGX} ${APCFG} connection_type`
	#${SETCFGX} $WSC_OUT connection_type $connection_type_value
	
	#manual_config
	#manual_config_value=`${GETCFGX} ${APCFG} manual_config`
	#${SETCFGX} $WSC_OUT manual_config $manual_config_value
	
	#network_key
	wpa_psk=`${GETCFGX} ${APCFG} wpa_passphrase_0`
	${SETCFGX} $WSC_OUT network_key $wpa_psk
	
	#ssid
	essid=`${GETCFGX} ${APCFG} ESSID_0`
	${SETCFGX} $WSC_OUT ssid $essid
	
	#pin_code
	pin_code_value=`${GETCFGX} ${APCFG} pin_code`
	${SETCFGX} $WSC_OUT pin_code $pin_code_value
	
	#rf_band: 1
	#device_name
	#config_by_ext_reg
}

start_wps() {
	/usr/bin/led_ctrl set wps fastblk
#	echo "$WSCD -start -c $WSC_OUT -w wlan0 -fi $FIFO_FILE -daemon"
#	$WSCD -start -c $WSC_OUT -w wlan0 -fi $FIFO_FILE -daemon
#	sleep 1
#	echo "$IWCONTROL wlan0"
#	$IWCONTROL wlan0
#	sleep 1
#	$WSCD -sig_pbc wlan0
	
#	iwpriv ra0 set WscConfMode=7
#	iwpriv ra0 set WscConfStatus=2
#	iwpriv ra0 set WscMode=2
#	iwpriv ra0 set WscGetConf=1	
	iwpriv ${SSIDdevice} set WscConfMode=7
	iwpriv ${SSIDdevice} set WscConfStatus=2
	iwpriv ${SSIDdevice} set WscMode=2
	iwpriv ${SSIDdevice} set WscGetConf=1	
}

stop_wps() {
#	wscd_pid=`ps | grep wscd | grep start | awk '{print $1}'`
	wscd_pid=`ps | grep wscd | grep /usr/bin/ | awk '{print $1}'`
	
	if [ "$wscd_pid" != "" ]; then
		kill -9 $wscd_pid > /dev/null
		route del -net 239.0.0.0/8 dev br0
	fi

#	iwcontrol_pid=`ps | grep iwcontrol | grep wlan0 | awk '{print $1}'`
#	if [ "$iwcontrol_pid" != "" ]; then
#		kill -9 $iwcontrol_pid 2 > /dev/null
#	fi

#	rm -f $FIFO_FILE
#	rm -f $WSC_OUT
#	iwpriv ra0 set WscStop
	
	
	if [ "${PASSTWO}" != "" ]; then
		iwpriv ${SSIDdevice} set WscStop
	else
		iwpriv ra0 set WscStop
		iwpriv ra1 set WscStop
		iwpriv ra2 set WscStop
		iwpriv ra3 set WscStop
		iwpriv rai0 set WscStop
		iwpriv rai1 set WscStop
		iwpriv rai2 set WscStop
		iwpriv rai3 set WscStop
	fi	
}

init_wps_app() {
	. ${XMLConfFile}
	LanIPAddressVal=`inter_web get $IGD_LAND_1_LANHCM_IPI_1_IPInterfaceIPAddress`
#	echo ${LanIPAddressVal}
	LanIPAddressVal=${LanIPAddressVal%&}
#	echo ${LanIPAddressVal}
	route add -net 239.0.0.0/8 dev br0
#	$WSCD -i ra0 -a ${LanIPAddressVal} -w /rom/cfg/wlan_conf -m 1 & 
	${WSCD} -i ${SSIDdevice} -a ${LanIPAddressVal} -w /rom/cfg/wlan_conf -m 1 & 
}

wps_init() {
	if [ x$2 != x ]; then
		SSIDdevice=$2
		PASSTWO=$2
	else
		SSIDdevice=ra0
	fi
	echo "SSIDdevice=${SSIDdevice}"
	if [ "$1" = "open" ]; then
		wps=`ps | grep wscd | wc -l`
		if [ "$wps" = "1" ]; then
#			init_wps_conf
			init_wps_app
			start_wps
		else
			echo "wps is already enabled"
		fi
	elif [ "$1" = "close" ]; then
		stop_wps
		led_ctrl set wps off
	else
		echo "set_wps.sh open | close [ra*]"
		exit 1
	fi
}

wps_init $1 $2
exit 0
