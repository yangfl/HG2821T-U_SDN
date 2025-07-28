#!/bin/sh

# call by cm
# del_dns.sh
# param1:  [ovs internal port name]
# when sh called with no param, do nothing

DNSMASQ_CONF_PATH="/var/run/dns"

if [ -n "$1" ]; then
        PORT=$1
else
        echo "Need param!"
        echo "Usage: del_dns.sh <port_name>"
fi

if [ ! -d "$DNSMASQ_CONF_PATH/dnsmasq.d" ];then
        mkdir -p $DNSMASQ_CONF_PATH/dnsmasq.d
fi

configurefilename="$DNSMASQ_CONF_PATH/dnsmasq.d/dnsmasq_"$PORT".conf"
if [ -f $configurefilename ]; then
        rm $configurefilename
        killall dnsmasqx
        ip netns exec FM /usr/bin/dnsmasqx -C $DNSMASQ_CONF_PATH/dnsmasq.conf -d &
else
        echo "Cannot find configure file ($configurefilename) to remove"
fi
