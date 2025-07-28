#!/bin/sh

# call by cm
# add_dns_begin.sh
# param: no
. /usr/init_scripts/env_para.sh 

#clear dnsmasq.d configure files
#echo "add_dns_begin.sh run!!!" >> /tmp/mnt/dns.log
DNSMASQ_CONF_PATH="/var/run/dns"

rm -rf $DNSMASQ_CONF_PATH/dnsmasq.d

if [ ! -d "$DNSMASQ_CONF_PATH/dnsmasq.d" ];then
        mkdir -p $DNSMASQ_CONF_PATH/dnsmasq.d
fi

#create dnsmasqx configure file
echo "no-resolv" > $DNSMASQ_CONF_PATH/dnsmasq.conf
echo "no-negcache" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
echo "cache-size=0" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
echo "local-ttl=0" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
echo "neg-ttl=0" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
if [ -f /var/run/NS/1/dns ]; then

# just test for FH, need to change
        for defaultdns in $(cat /var/run/NS/1/dns)
        do
		echo "server=$defaultdns" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
        done
fi
echo "conf-dir=$DNSMASQ_CONF_PATH/dnsmasq.d" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
#end create configure file
#echo "add_dns_begin.sh run finish with dnsmasq.conf like: " >> /tmp/mnt/dns.log
#cat /etc/dnsx/dnsmasq.conf >> /tmp/mnt/dns.log
