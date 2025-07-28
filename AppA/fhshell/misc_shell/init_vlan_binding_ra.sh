#!/bin/sh

#-----yzhli modify 20161010

COMMON_CONF=/etc/fh_common.conf
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `
APP_CONF_PATH=`grep "APP_CONF_PATH_TR069_HGCXML=" $COMMON_CONF | cut -d = -f 2 `

IGD_LAND_1_WLANC_1_X_CT_COM_Mode=`grep "IGD_LAND_1_WLANC_1_X_CT_COM_Mode=" $APP_CONF_PATH | cut -d = -f 2`
IGD_LAND_1_WLANC_2_X_CT_COM_Mode=`grep "IGD_LAND_1_WLANC_2_X_CT_COM_Mode=" $APP_CONF_PATH | cut -d = -f 2`
IGD_LAND_1_WLANC_3_X_CT_COM_Mode=`grep "IGD_LAND_1_WLANC_3_X_CT_COM_Mode=" $APP_CONF_PATH | cut -d = -f 2`
IGD_LAND_1_WLANC_4_X_CT_COM_Mode=`grep "IGD_LAND_1_WLANC_4_X_CT_COM_Mode=" $APP_CONF_PATH | cut -d = -f 2`

while :
do
	
	if [ -c /dev/fbr_ctrl -a -f /var/manager_finished ]; then      
	
	
		WLAN_PORT_INDEX=`$FHBOX_PATH/inter_web get $IGD_LAND_1_WLANC_1_X_CT_COM_Mode `
	
		if [ "$WLAN_PORT_INDEX" == "1&" ]; then
			RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_LAND_1_WLANC_1_X_CT_COM_Mode  1`
		fi
		WLAN_PORT_INDEX=`$FHBOX_PATH/inter_web get $IGD_LAND_1_WLANC_2_X_CT_COM_Mode `
		
		if [ "$WLAN_PORT_INDEX" == "1&" ]; then
			RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_LAND_1_WLANC_2_X_CT_COM_Mode  1`
		fi  
		WLAN_PORT_INDEX=`$FHBOX_PATH/inter_web get $IGD_LAND_1_WLANC_3_X_CT_COM_Mode `
		
		if [ "$WLAN_PORT_INDEX" == "1&" ]; then
			RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_LAND_1_WLANC_3_X_CT_COM_Mode  1`
		fi  
		WLAN_PORT_INDEX=`$FHBOX_PATH/inter_web get $IGD_LAND_1_WLANC_4_X_CT_COM_Mode `
		
		if [ "$WLAN_PORT_INDEX" == "1&" ]; then
			RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_LAND_1_WLANC_4_X_CT_COM_Mode  1`
		fi 
		
      exit
	fi
	sleep 1
done
