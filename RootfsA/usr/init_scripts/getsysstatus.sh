#!/bin/sh

# call by dm
# getsysstatus.sh
# param1:  [program name], should be 'cm', 'flows', 'db', 'system', none for 'system'
# 
. /usr/init_scripts/env_para.sh
dns_dir=/var/run/dns

if [ -n "$1" ]; then
        CMD=$1
else
        CMD="system"
fi

case $CMD in
cm)
	echo ">>cm result"
	ovs-appctl -t cm get-err_log
	;;
flows)
	echo ">>flows result"
	ovs-ofctl show SDN-bridge
	ovs-ofctl dump-flows SDN-bridge
	ovs-appctl -t /var/ovs/ovs-vswitchd.ctl dpctl/show
	ovs-appctl -t /var/ovs/ovs-vswitchd.ctl dpctl/dump-flows
	ovs-appctl -t /var/ovs/ovs-vswitchd.ctl fdb/show SDN-bridge
	ovs-appctl -t /var/ovs/ovs-vswitchd.ctl mdb/show SDN-bridge	
	;;
sip)
	echo ">>sip result"
	fhtool getvoip_status
	;;
db)
	echo ">>vswitchd result"
	echo ">>>show:"
	ovs-vsctl show
	echo ">>>device:"
	ovs-vsctl list device
	echo ">>>bridge:"
	ovs-vsctl list bridge
	echo ">>>ports:"
	ovs-vsctl list port
	echo ">>>wanconnection:"
	ovs-vsctl list wanconnection
	echo ">>>application:"
	ovs-vsctl list application
	echo ">>>wlan:"
	ovs-vsctl list WLAN_RADIO
	ovs-vsctl list WLAN_SSID
	echo ">>>flows:"
	ovs-vsctl list FlowsConfig
	ovs-vsctl list Flows
	echo ">>>ofshow:"
	ovs-ofctl show SDN-bridge
	echo ">>>nat_config:"
	ovs-vsctl list nat_config
	echo ">>>dnsconfig:"
	ovs-vsctl list dnsconfig
	;;
system)
	echo ">>system result"
#cpu
	echo ">>>cpu:"
	mpstat -P ALL
#memory
	echo ">>>memory:"
	cat /proc/meminfo |grep Mem
#device
	echo ">>>device:"
	ovs-appctl -t cm get-device
#interface in netns
	echo ">>>interface in netns"
	echo ">>>>network namespace default"
	ifconfig -a
	netstat -rn
	#iptables -L
	echo "iptables-nat:"
	iptables -L -n -t nat
	echo "iptables-raw:"
	iptables -L -n -t raw
	echo "iptables-mangle:"
	iptables -L -n -t mangle
	nslist=`/usr/bin/ip netns show`
	for nsitem in $nslist
	do
		echo ">>>>network namespace $nsitem"
		/usr/bin/ip netns exec $nsitem ifconfig -a
		/usr/bin/ip netns exec $nsitem netstat -rn
		echo "iptables-nat in "$nsitem":"
		/usr/bin/ip netns exec $nsitem iptables -L -n -t nat
		echo "iptables-raw in "$nsitem":"
		/usr/bin/ip netns exec $nsitem iptables -L -n -t raw
		echo "iptables-mangle in "$nsitem":"
		/usr/bin/ip netns exec $nsitem iptables -L -n -t mangle
	done
#ps
	echo ">>>ps"
	ps
#dnsmasq
	echo ">>>dnsmasq"
	echo ">>>>default:"
	cat $dns_dir/dnsmasq.conf
	for binding_port_name in `ls $dns_dir/dnsmasq.d`
	do
		echo ">>>>$binding_port_name:"
		cat $dns_dir/dnsmasq.d/$binding_port_name
	done
#df
	echo ">>>df -k:"
	df -k
#rem_log
	echo ">>>rem-log"
	cat /tmp/remd.lock
#bootflag
	echo ">>>bootflag"
	fhtool getrun_prtn
#serial
	echo ">>>serial"
	if [ -f "/usr/local/.steinsgate" ]; then
		echo "serial on"
	else
		echo "serial off"
	fi
	;;
*)
	echo ">>unknown option '$CMD'"
	;;
esac
echo ">>end"
