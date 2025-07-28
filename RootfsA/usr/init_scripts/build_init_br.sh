#!/bin/sh
echo "========build_init start========"
. /usr/init_scripts/env_para.sh 
NSPID=
FACTORY=
BASEMAC=`fhtool getonumac`
##################################################
#0. check it's in the factory mode or not
#FACTORY=0:business mode
#FACTORY=1:factory mode
#FACTORY=2:nothing
#FACTORY=3:return_fa mode
##################################################
if [ -d "/usr/local/fh/mf" ] && [ -e "/usr/local/fh/mf/factory_mode" ];then
	FACTORY=1
	#jhd:first shaopian
elif [ -d "/usr/local/fh/mf" ] && [ ! -e "/usr/local/fh/mf/factory_mode" ] && [ -f "/usr/local/fh/mf/.onepiece" ];then
	FACTORY=3
	#jhd:return factory
elif [ -d "/usr/local/fh/mf" ] && [ ! -e "/usr/local/fh/mf/factory_mode" ] && [ ! -f "/usr/local/fh/mf/.onepiece" ];then
	FACTORY=0
	#jhd:common
else
	FACTORY=2
fi
echo "======================FACTORY=$FACTORY======================"


echo "=======0.start rem && ram========"
/bin/remd


##################################################
#1. create Managerment network namespace and channel
##################################################
echo "========1.create Managerment network namespace and channel========"
/bin/mkdir -m 0777 -p $OVS_RUNDIR

create_interface 46

ifconfig pon0.46 down
ip link set dev pon0.46 name manager
ifconfig manager up

$IP_CMD netns add MNG
$IP_CMD link set $MANAGER netns MNG
#mkdir -p /var/run/manager

$IP_CMD netns exec MNG ifconfig lo up
$IP_CMD netns exec MNG ifconfig $MANAGER up

#manager dhcp and set sh after get ip address to do time_sync
#need to change and configure by cm, note by xiaboy
echo "15.192.251.5 15.192.252.5" > /var/ntpservers.conf
$IP_CMD netns exec MNG /usr/bin/udhcpc -i $MANAGER -s /usr/init_scripts/udhcpc_manager.sh -N MNG &
#$IP_CMD netns exec MNG /rom/fhshell/udhcpc/udhcpc-start $MANAGER &

#$IP_CMD netns exec MNG /userfs/bin/sipclient &
echo "========cp default_flows.conf========"
if [ "$FACTORY" = "0" ];then
	cp $SCRIPT_PATH/default_flows.conf $OVS_RUNDIR/default_flows.conf
else
	cp $SCRIPT_PATH/factory_flows.conf $OVS_RUNDIR/default_flows.conf
fi

##################################################
#2. create internal fixed network namespace
##################################################
echo "========2.create internal fixed network namespace========"
#NM network namespace is used for internal httpd, dhcpserver 
$IP_CMD netns add NM
#FM network namespace is used for internal dnsmasqx, support forward packet to output
$IP_CMD netns add FM
#APP network namespace is used for local apps, !!!TEST only!!!
$IP_CMD netns add APP
$IP_CMD netns add obox
$IP_CMD netns exec obox /usr/init_scripts/obox_pid.sh &
sleep 1
echo `ip netns pids obox |head -1` > /proc/obox_pid

##################################################
#3. do ovsdb init when first activate
##################################################
echo "========3.do ovsdb init when first activate========"
FIRST_RUN=
if [ -f "$OVSDB_PATH/initialized" ]; then
	FIRST_RUN=""
else
	FIRST_RUN="-f"
fi

if [ ! -f $CFGDB ]; then
	if [ -f $CFGDBP ]; then
		$OVSDB_TOOL create $CFGDB $OVS_PATH/share/openvswitch/vswitch.ovsschema
	else
		echo "cannot find factory file, may be partition mount error"
	fi
else
#compact db before ovsdb-server startup
	echo "compact ovsdb..."
	$OVSDB_TOOL compact $CFGDB
	echo "compact ovsdb finished!"
fi
insmod $OVS_PATH/lib/openvswitch.ko

##################################################
# move LAN ports to MNG network namespace
##################################################
echo "========move LAN ports to MNG network namespace========"
$IP_CMD link set $DEV_SDN_ETH1 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH1 up
$IP_CMD link set $DEV_SDN_ETH2 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH2 up
$IP_CMD link set $DEV_SDN_ETH3 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH3 up
$IP_CMD link set $DEV_SDN_ETH4 netns MNG
$IP_CMD netns exec MNG ifconfig $DEV_SDN_ETH4 up


##################################################
#4. start ovs system
##################################################
echo "========4.1 start ovsdb-server========"
#4.1 start ovsdb-server
#do NOT use &, ovsdb-server will go to backgound with --detach option after db opened!!!
$IP_CMD netns exec MNG $OVSDB_SERVER --unixctl=$OVS_RUNDIR/ovsdb-server.ctl --remote=punix:$OVS_RUNDIR/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --detach $CFGDB
#sleep 1
echo "========4.2 start ovs-vswitchd========"
#4.2 start ovs-vswitchd
#do NOT use &, ovs-vswitchd will go to backgound with --detach option after all bridge init!!!
$IP_CMD netns exec MNG $OVS_VSWITCHD --unixctl=$OVS_RUNDIR/ovs-vswitchd.ctl unix:$OVS_RUNDIR/db.sock --pidfile=$OVS_RUNDIR/ovs-vswitchd.pid --detach
#sleep 2

#ovs-vsctl --no-wait init is NOT needed after ovs 2.4
#$IP_CMD netns exec MNG $OVS_VSCTL --no-wait init &
echo "========4.3 init SDN-bridge and fixed ports when needed========"
#4.3 init SDN-bridge and fixed ports when needed
BR_EXIST=`$OVS_VSCTL show|grep Bridge|grep SDN-bridge`
SI_EXIST=`$OVS_VSCTL show|grep Port|grep si`
if [ "$BR_EXIST" != "" ] && [ "$SI_EXIST" != "" ]; then
	echo "do nothing"
else
	echo "$OVS_VSCTL add-br SDN-bridge"
	echo "========create SDN-bridge========"
	#create SDN-bridge
	$OVS_VSCTL add-br SDN-bridge
	$OVS_VSCTL set Bridge SDN-bridge mcast_snooping_enable=true
	$OVS_VSCTL set Bridge SDN-bridge other_config:mcast-snooping-disable-flood-unregistered=true
	$OVS_VSCTL set Bridge SDN-bridge other_config:mcast-snooping-cast-vlan=true
	$OVS_VSCTL set Bridge SDN-bridge other_config:mac-table-static-list=`fhtool getonumac|awk -F: '{print $1$2$3$4$5$6}'`_0_200
	$OVS_VSCTL set Open_vSwitch . other_config:max-idle=20000
	echo "========create lan port========"
	#create lan port
	$OVS_VSCTL --may-exist add-port SDN-bridge $DEV_SDN_ETH1 -- set interface $DEV_SDN_ETH1 ofport_request=1
	$OVS_VSCTL --may-exist add-port SDN-bridge $DEV_SDN_ETH2 -- set interface $DEV_SDN_ETH2 ofport_request=2
	$OVS_VSCTL --may-exist add-port SDN-bridge $DEV_SDN_ETH3 -- set interface $DEV_SDN_ETH3 ofport_request=3
	$OVS_VSCTL --may-exist add-port SDN-bridge $DEV_SDN_ETH4 -- set interface $DEV_SDN_ETH4 ofport_request=4
	#$OVS_VSCTL set Port $DEV_SDN_ETH1 other_config:mcast-snooping-flood-reports=true
	#$OVS_VSCTL set Port $DEV_SDN_ETH2 other_config:mcast-snooping-flood-reports=true
	#$OVS_VSCTL set Port $DEV_SDN_ETH3 other_config:mcast-snooping-flood-reports=true
	#$OVS_VSCTL set Port $DEV_SDN_ETH4 other_config:mcast-snooping-flood-reports=true
	echo "========create fixed internal port========"
	#create fixed internal port
	$OVS_VSCTL --may-exist add-port SDN-bridge foi -- set interface foi type=internal ofport_request=101
	$OVS_VSCTL --may-exist add-port SDN-bridge utest -- set interface utest type=internal ofport_request=150
	$OVS_VSCTL --may-exist add-port SDN-bridge dtest -- set interface dtest type=internal ofport_request=911
	$OVS_VSCTL --may-exist add-port SDN-bridge SDN-out-default -- set interface SDN-out-default type=internal ofport_request=200
	$OVS_VSCTL --may-exist add-port SDN-bridge si -- set interface si type=internal ofport_request=100
	if [ -n "$SDN_OVS_FTP_ENABLE" ]; then
		#appi is for TEST only !!! need to remove before release !!!! by xiaboy
		$OVS_VSCTL --may-exist add-port SDN-bridge appi -- set interface appi type=internal ofport_request=105	
	fi
fi
$OVS_VSCTL set-fail-mode SDN-bridge secure

echo "========move ovs created internal port to correct network namespace========"
#move ovs created internal port to correct network namespace
$IP_CMD netns exec MNG $IP_CMD link set si netns NM
$IP_CMD netns exec MNG $IP_CMD link set foi netns FM
$IP_CMD netns exec MNG $IP_CMD link set SDN-out-default netns obox
if [ -n "$SDN_OVS_FTP_ENABLE" ]; then
	#appi is for TEST only !!! need to remove before release !!!! by xiaboy
	$IP_CMD netns exec MNG $IP_CMD link set appi netns APP
fi

echo "========setting internal port mac and bring them up========"
#setting internal port mac and bring them up
$IP_CMD netns exec obox ifconfig SDN-out-default 192.168.1.1/24 hw ether $BASEMAC up
$IP_CMD netns exec NM ifconfig si 192.168.1.1/24 hw ether $BASEMAC up
$IP_CMD netns exec FM ifconfig foi 192.168.1.254/24 up

$IP_CMD netns exec FM route add default gw 192.168.1.1

if [ "$FACTORY" = "0" ]; then
	echo "========create utest & dtest internal port========="
	# $IP_CMD netns exec MNG ifconfig dtest up
	$IP_CMD netns exec MNG ifconfig utest 192.168.1.1/24 hw ether $BASEMAC up
	$IP_CMD netns exec MNG iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o manager -j MASQUERADE
fi

if [ -n "$SDN_OVS_FTP_ENABLE" ]; then
	#appi is for TEST only !!! need to remove before release !!!! by xiaboy
	$IP_CMD netns exec APP ifconfig appi 192.168.1.253/24 up
fi


#set datapath id
DATAPATH_ID=`fhtool getonumac|awk -F: '{print "0000"$1$2$3$4$5$6}'`
$OVS_VSCTL set bridge SDN-bridge other-config:datapath-id=$DATAPATH_ID

#start WLAN module
echo "========11n WiFi module========"
#11n WiFi module
insmod /lib/fhko/mt7603eap.ko                # may need to change

echo "========11ac WiFi module========"
#11ac WiFi module
#rmmod mt7662e_ap
#insmod /lib/modules/mt7662e_ap.ko

echo "========hw nat========"
#hw nat
NSPID=`pidof ovs-vswitchd`
insmod /lib/hw_nat.ko NS_PID=$NSPID
#Temp adjust from /rom/fhshell/misc_shell/throughput.sh due to qdmamgr_wan
#hw_nat -T 1
#hw_nat -N 1
#hw_nat -U 1 1 1 1
hw_nat -V 1

#add WiFi device to ovs bridge
#$SCRIPT_PATH/wlan11ac.sh
#$SCRIPT_PATH/wlan.sh
#end start WLAN

echo "========import default configure to ovsdb when first activate========"
#import default configure to ovsdb when first activate
if [ "$FIRST_RUN" != "" ]; then
if [ "$FACTORY" = "1" ]; then
	$SCRIPT_PATH/import_factory_flows.sh
	echo "=================factory flows================"
else
	$SCRIPT_PATH/import_default_conf.sh
	echo "=================default conf================"
fi
fi

#jhd:test
#start RSTP & set no-flood
if [ "$FACTORY" = "0" ]; then

	if [ "$BR_EXIST" != "" ] && [ "$SI_EXIST" != "" ]; then
		echo "do nothing"
	else
		echo "$OVS_VSCTL set Port"
		echo "========SDN-bridge other_config:rstp-enable========"
		$OVS_VSCTL set Port $DEV_SDN_ETH1 other_config:rstp-enable=true
		$OVS_VSCTL set Port $DEV_SDN_ETH2 other_config:rstp-enable=true
		$OVS_VSCTL set Port $DEV_SDN_ETH3 other_config:rstp-enable=true
		$OVS_VSCTL set Port $DEV_SDN_ETH4 other_config:rstp-enable=true
		$OVS_VSCTL set Port si other_config:rstp-enable=false
		$OVS_VSCTL set Port foi other_config:rstp-enable=false
		$OVS_VSCTL set Port appi other_config:rstp-enable=false
		$OVS_VSCTL set Port SDN-out-default other_config:rstp-enable=false
		$OVS_VSCTL set Port dtest other_config:rstp-enable=false
		$OVS_VSCTL set Port utest other_config:rstp-enable=false
		$OVS_VSCTL set Bridge SDN-bridge rstp_enable=true
	fi
	$OVS_OFCTL mod-port SDN-bridge si no-flood
	$OVS_OFCTL mod-port SDN-bridge foi no-flood
	$OVS_OFCTL mod-port SDN-bridge utest no-flood
	$OVS_OFCTL mod-port SDN-bridge dtest no-flood
	$OVS_OFCTL mod-port SDN-bridge SDN-bridge no-flood
	$OVS_OFCTL mod-port SDN-bridge appi no-flood
fi
#jhd:test

##################################################
#5. start fixed apps
##################################################
/bin/rem /bin/ram
echo "========start cm========"
#start cm
$OVS_PATH/sbin/cm -c $CM_ADDR --pidfile &

if [ "$FACTORY" = "0" ];then
	echo "========start dm========"
	#start dm
	/bin/rem $IP_CMD netns exec MNG $OVS_PATH/sbin/dm -r $DM_ADDR -d $DATAPATH_ID --pidfile 
fi
#app start should change by ovsdb, udhcpd will start by cm
#start udhcpd
#killall udhcpd
#cp /usr/udhcpd/udhcpd.conf /etc
#$IP_CMD netns exec NM /usr/udhcpd/udhcpd /etc/udhcpd.conf &
#ip netns exec NM /usr/bin/udhcpd /flash/cfg/app_conf/udhcpd/udhcpd_lan.conf &

echo "========start inetd (micro_httpd & bftpd)========"
#start inetd (micro_httpd & bftpd)
$IP_CMD netns exec NM inetd &

#start telnetd (for factory mode)
killall telnetd
if [ "$FACTORY" = "1" ];then
	rm -f /usr/local/fh/mf/.onepiece
	$IP_CMD netns exec obox dropbear -r /rom/cfg/app_conf/dropbear/pri_rsa.key -s &

	create_interface 30
	sleep 2s
	ip link set pon0.30 netns MNG
	ip netns exec MNG ifconfig pon0.30 up
	$OVS_VSCTL --may-exist add-port SDN-bridge pon0.30 -- set interface pon0.30 ofport_request=30

	ifconfig SDN-out-default down
	$IP_CMD netns exec NM ifconfig si 192.168.1.1/24 hw ether $BASEMAC up
fi

#start ssh (for re-factory mode)
if [ "$FACTORY" = "3" ];then
	rm -f /usr/local/fh/mf/.onepiece
	$IP_CMD netns exec obox dropbear -r /rom/cfg/app_conf/dropbear/pri_rsa.key -s &
fi

echo "========start dnsmasqx========"
#start dnsmasqx
if [ "$FACTORY" != "1" ]; then
$SCRIPT_PATH/add_dns.sh
fi

#monitor hgcsip
$SCRIPT_PATH/voip_monitor.sh &

echo "=================build_init end===================="
