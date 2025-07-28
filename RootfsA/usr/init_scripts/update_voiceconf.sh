#!/bin/sh

# write/update udhcpc waninfo to /flash/config/voice_factory.conf

[ "$#" != "5" ] && echo "Error: param error" && exit 1

#killall hgcsip
interface_name="$1"
local_IP_address="$2"
remote_IP_address="$3"
dnsinfo="$4"
netmask="$5"

#compare with org config data
use_sipsh=0
org_interface_name=`getcfgx /var/voip/sip_ip_info interfaceName`
org_local_IP_address=`getcfgx /var/voip/sip_ip_info tempLocalIp`
org_remote_IP_address=`getcfgx /var/voip/sip_ip_info tempRemoteIp`
org_netmask=`getcfgx /var/voip/sip_ip_info netMask`
org_dns1=`getcfgx /var/voip/sip_ip_info DNS1`
org_dns2=`getcfgx /var/voip/sip_ip_info DNS2`

setcfgx /var/voip/sip_ip_info interfaceName $interface_name
setcfgx /var/voip/sip_ip_info tempLocalIp $local_IP_address
setcfgx /var/voip/sip_ip_info tempRemoteIp $remote_IP_address
setcfgx /var/voip/sip_ip_info netMask $netmask

j=1
for i in $dnsinfo; do
	setcfgx /var/voip/sip_ip_info DNS$j ${i}
	if [ $j -eq 1 ]
	then
		DNS1=$i
	fi
	if [ $j -eq 2 ]
	then
		DNS2=$i
	fi
	j=$((j+1))
done

 if [ "$org_interface_name" != "$interface_name" -o "$org_local_IP_address" != "$local_IP_address" \
 -o "$org_remote_IP_address" != "$remote_IP_address" -o "$org_netmask" != "$netmask" \
 -o "$org_dns1" != "$DNS1" -o "$org_dns2" != "$DNS2" ];then
	use_sipsh=1
	echo "change use_sipsh to 1!"
 fi

if [ -f /var/cm_sip_flag ] && [ $use_sipsh == "1" ];then
	/usr/init_scripts/sip.sh 1
	echo "use sip.sh 1!"
fi

exit 0
