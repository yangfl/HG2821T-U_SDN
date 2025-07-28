#!/bin/sh

	mount -o remount,rw /data
	BASE_PRE_DATA_PATH=/data
	BASE_AGENT_CONF_PATH=/flash/cfg/agentconf

	SSID_01=`getcfgx $BASE_PRE_DATA_PATH/factory.conf SSID`
	
	# Get the SSID_2
	SSID_02=$SSID_01"-2"
	# echo SSID_02="$SSID_02"    
	# Set SSID_2 into the conf.
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "SSID_2" "$SSID_02"
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "SSID_2" "$SSID_02"
	BeaconType_2=`getcfgx $BASE_PRE_DATA_PATH/factory.conf BeaconType`
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "BeaconType_2" "$BeaconType_2" 
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "BeaconType_2" "$BeaconType_2" 
	PreSharedKey_2=`getcfgx $BASE_PRE_DATA_PATH/factory.conf PreSharedKey`
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "PreSharedKey_2" "$PreSharedKey_2"    
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "PreSharedKey_2" "$PreSharedKey_2"    
	SSID_03=$SSID_01"-3"
	
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "SSID_3" "$SSID_03"
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "SSID_3" "$SSID_03"
	BeaconType_3=`getcfgx $BASE_PRE_DATA_PATH/factory.conf BeaconType`
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "BeaconType_3" "$BeaconType_3"   
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "BeaconType_3" "$BeaconType_3"   
	PreSharedKey_3=`getcfgx $BASE_PRE_DATA_PATH/factory.conf PreSharedKey`
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "PreSharedKey_3" "$PreSharedKey_3" 
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "PreSharedKey_3" "$PreSharedKey_3" 
	
	
	SSID_04=$SSID_01"-4"
	
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "SSID_4" "$SSID_04"
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "SSID_4" "$SSID_04"
	BeaconType_4=`getcfgx $BASE_PRE_DATA_PATH/factory.conf BeaconType`
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "BeaconType_4" "$BeaconType_4"   
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "BeaconType_4" "$BeaconType_4"   
	PreSharedKey_4=`getcfgx $BASE_PRE_DATA_PATH/factory.conf PreSharedKey`
	setcfgx $BASE_PRE_DATA_PATH"/factory.conf" "PreSharedKey_4" "$PreSharedKey_4" 
	setcfgx $BASE_AGENT_CONF_PATH"/factory.conf" "PreSharedKey_4" "$PreSharedKey_4" 
	
	sync