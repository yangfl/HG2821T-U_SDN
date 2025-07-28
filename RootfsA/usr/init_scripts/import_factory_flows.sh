#!/bin/sh

#import default configure from rom files to ovsdb

. /usr/init_scripts/env_para.sh


#import default backup flows
RCOUNT=`ovsdb-client dump FlowsConfig | wc -l`
if [ $RCOUNT -le 3 ]; then
	TRANSACT_STR='["Open_vSwitch",{"op":"insert","table":"FlowsConfig","row":{"br_name":"SDN-bridge","flow_num":0}}'
	UUIDCOUNT=0
	FLOWUUIDSTR=
	for ofcmd in $(cat /usr/init_scripts/factory_flows.conf)
	do
		FLOWUUIDSTR="new_flow$UUIDCOUNT"
		TRANSACT_STR=$TRANSACT_STR',{"op":"insert","table":"Flows","row":{"br_name":"SDN-bridge","flow":"'$ofcmd'"},"uuid-name":"'$FLOWUUIDSTR'"},{"op":"mutate","table":"FlowsConfig","where":[["br_name","==","SDN-bridge"]],"mutations":[["flows","insert",["set",[["named-uuid","'$FLOWUUIDSTR'"]]]],["flow_num","+=",1]]}'
		UUIDCOUNT=$(expr $UUIDCOUNT + 1)
	done
	TRANSACT_STR=$TRANSACT_STR']'
	ovsdb-client transact $TRANSACT_STR
fi

#import factory wifi ssid & password
#TODO
RCOUNT=`ovsdb-client dump WLAN_SSID | wc -l`
if [ $RCOUNT -le 3 ]; then
	ssid=`getcfgx /data/factory.conf SSID`
	key=`getcfgx /data/factory.conf PreSharedKey`

	ssid11ac=`getcfgx /data/factory.conf SSID_5G`
	key11ac=`getcfgx /data/factory.conf PreSharedKey_5G`

	if [ -n "$ssid" ]; then
		if [ "$ssid" = "no attribute information" ] || [ "$ssid" = "no node information" ] || [ "$key" = "" ] || [ "$key" = "no node information" ] || [ "$key" = "no attribute information" ]; then
			ssid="ChinaNet-SDN2dot4G"
			key="12345678"
		fi
		TRANSACT_STR='["Open_vSwitch",{"op":"insert","table":"WLAN_RADIO","row":{"radio_enable":1,"radio_band":"2.4G","radio_mode":"802.11b/g/n","channel":0,"bandwidth":0,"power":1}}'
		TRANSACT_STR=$TRANSACT_STR',{"op":"insert","table":"WLAN_SSID","row":{"ssid_name":"'$ssid'","ssid_broadcast":1,"ssid_index":0,"ssid_encryt_type":"WPA-PSK/WPA2-PSK","ssid_password":"'$key'"},"uuid-name":"new_app"}'
		TRANSACT_STR=$TRANSACT_STR',{"op":"mutate","table":"WLAN_RADIO","where":[["radio_band","==","2.4G"]],"mutations":[["wlan_ssids","insert",["set",[["named-uuid","new_app"]]]]]}'
		TRANSACT_STR=$TRANSACT_STR']'
		ovsdb-client transact $TRANSACT_STR
	fi
	
	if [ -n "$ssid11ac" ]; then
		if [ "$ssid11ac" = "no attribute information" ] || [ "$ssid11ac" = "no node information" ] || [ "$key11ac" = "" ] || [ "$key11ac" = "no node information" ] || [ "$key11ac" = "no attribute information" ]; then
			ssid11ac="ChinaNet-SDN5G"
			key11ac="12345678"
		fi
		TRANSACT_STR='["Open_vSwitch",{"op":"insert","table":"WLAN_RADIO","row":{"radio_enable":1,"radio_band":"5G","radio_mode":"802.11a/n","channel":0,"bandwidth":0,"power":1}}'
		TRANSACT_STR=$TRANSACT_STR',{"op":"insert","table":"WLAN_SSID","row":{"ssid_name":"'$ssid11ac'","ssid_broadcast":1,"ssid_index":0,"ssid_encryt_type":"WPA-PSK/WPA2-PSK","ssid_index":8,"ssid_password":"'$key11ac'"},"uuid-name":"new_app"}'
		TRANSACT_STR=$TRANSACT_STR',{"op":"mutate","table":"WLAN_RADIO","where":[["radio_band","==","5G"]],"mutations":[["wlan_ssids","insert",["set",[["named-uuid","new_app"]]]]]}'
		TRANSACT_STR=$TRANSACT_STR']'
		ovsdb-client transact $TRANSACT_STR
	fi
fi

#add table Device into conf.db and import dhcp configures in one transaction
RCOUNT=`ovsdb-client dump Application | wc -l`
if [ $RCOUNT -le 3 ]; then
	ovsdb-client transact '["Open_vSwitch",{"op": "insert","table": "Device","row":{}},{"op":"insert","table":"Application","row":{"app_name":"dhcp_server","configurations":["map",[["interface","si"],["lease_file","/etc/udhcpd.leases"],["opt_subnet","255.255.255.0"],["opt_router","192.168.1.1"],["opt_dns","192.168.1.1"],["opt_wins","192.168.1.1"],["start","192.168.1.2"],["end","192.168.1.100"],["max_leases","252"],["option_lease","86400"]]]},"uuid-name":"new_app"},{"op":"mutate","table":"Device","where":[],"mutations":[["applications","insert",["set",[["named-uuid","new_app"]]]]]}]'
fi
