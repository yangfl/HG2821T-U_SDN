#!/bin/sh

#-----lqu modify 20120820
COMMON_CONF=/etc/fh_common.conf
FHBOX_PATH=`grep "FHBOX_BIN_PATH=" $COMMON_CONF | cut -d = -f 2 `
APP_CONF_PATH=`grep "APP_CONF_PATH_TR069_HGCXML=" $COMMON_CONF | cut -d = -f 2 `
. $APP_CONF_PATH

IPV6MODE=`$FHBOX_PATH/inter_web get $IGD_DI_XCTCOMIPPV_Mode`
if [ "$IPV6MODE" == "1&" ]; then
 RETURNSTR=`$FHBOX_PATH/calltpm set_ipv6_enable 0`
fi  

IP_limit_enable=`$FHBOX_PATH/inter_web get $IGD_S_XCTCOMMWBAND_Mode`
if [ "$IP_limit_enable" == "1&" ]; then
TOTAL_Number=`$FHBOX_PATH/inter_web get $IGD_S_XCTCOMMWBAND_TotalTerminalNumber`
echo $TOTAL_Number > /proc/fh_user/user_max
fi 

 