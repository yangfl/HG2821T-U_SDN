#!/bin/sh

export CFG_PATH=/usr/init_scripts
export BR="SDN-bridge"
export OVS_PATH="/usr/ovs"
export OVSDB_PATH="/usr/local/db"
export OVS_RUNDIR="/var/ovs"
export SCRIPT_PATH="/usr/init_scripts"
export TMP_TOOLS="/usr/tmp"

export DEV_SDN_ETH1=eth0
export DEV_SDN_ETH2=eth1
export DEV_SDN_ETH3=eth2
export DEV_SDN_ETH4=eth3
export IP_CMD=ip
export OVS_VSCTL=$OVS_PATH/bin/ovs-vsctl
export OVS_OFCTL=$OVS_PATH/bin/ovs-ofctl
export OVSDB_TOOL=$OVS_PATH/bin/ovsdb-tool
export OVSDB_SERVER=$OVS_PATH/sbin/ovsdb-server
export OVS_VSWITCHD=$OVS_PATH/sbin/ovs-vswitchd

export PATH=$PATH:/userfs/bin:/usr/sbin:/bin:/usr/bin:/sbin:/usr/ovs/bin:/usr/ovs/sbin

export CFGDB="$OVSDB_PATH/conf.db"
export CFGDBP="$OVSDB_PATH/conf.fact"
export DM_ADDR="sgwauth.edatahome.com"
export CM_ADDR="sodgw.edatahome.com"


export NTPSERVERS="15.192.251.5 15.192.252.5"

export SDN_OVS_FTP_ENABLE=1

#enviroment vars for FH
export MANAGER=manager
#export DHCPSCRIPT=/rom/fhshell/udhcpc/dhcp.script
#export DNSMASQ_CONF=/var/dnsx
