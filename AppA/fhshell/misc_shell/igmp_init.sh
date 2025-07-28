#!/bin/sh

#-----lqu modify 20120820
COMMON_CONF=/etc/fh_common.conf
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `
APP_CONF_PATH=`grep "APP_CONF_PATH_TR069_HGCXML=" $COMMON_CONF | cut -d = -f 2 `
. $APP_CONF_PATH
echo " 2 " > /proc/sys/net/ipv4/conf/all/force_igmp_version
while :
do
   if [ -c /dev/fbr_ctrl -a -f /var/manager_finished ]; then
      IGMPSNOOPING=`$FHBOX_PATH/inter_web get $IGD_S_XCTCOMIPTV_SnoopingEnable`
      if [ "$IGMPSNOOPING" == "1&" ]; then
         RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_S_XCTCOMIPTV_SnoopingEnable  1`
      else
         RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_S_XCTCOMIPTV_SnoopingEnable  0`
      fi  
      MLDSNOOPING=`$FHBOX_PATH/inter_web get $IGD_S_XCTCOMIPTV_X_FIB_COM_MldSnoopingEnable`
      if [ "$MLDSNOOPING" == "1&" ]; then
         RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_S_XCTCOMIPTV_X_FIB_COM_MldSnoopingEnable  1`
      else
         RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_S_XCTCOMIPTV_X_FIB_COM_MldSnoopingEnable  0`
      fi
	IPFORWARDENALE=`$FHBOX_PATH/inter_web get $IGD_DI_X_CT_COM_IPForwardModeEnabled`
	if [ "$IPFORWARDENALE" == "1&" ]; then 
	RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_DI_X_CT_COM_IPForwardModeEnabled  1`
	else 
	RETURNSTR=`$FHBOX_PATH/inter_web set  $IGD_DI_X_CT_COM_IPForwardModeEnabled  0`
	fi
   exit
   fi
   sleep 1
done

 