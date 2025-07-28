#!/bin/sh

# call by cm
# add_dns_end.sh
# param: no
. /usr/init_scripts/env_para.sh
DNSMASQ_CONF_PATH="/var/run/dns"
DNSMASQ_PATH="/usr/bin"

#echo "add_dns_end.sh run and restart dnsmasqx" >> /tmp/mnt/dns.log
killall dnsmasqx
sleep 2
ip netns exec FM $DNSMASQ_PATH/dnsmasqx -C $DNSMASQ_CONF_PATH/dnsmasq.conf &
