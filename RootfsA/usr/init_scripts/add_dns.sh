#!/bin/sh

# call by cm
# add_dns.sh
# param1:  [ovs internal port name]
# param2:  [domainname to configure for dnsmasq]
# param3:  [dns server ip]
# when sh called with no param, sh reading env vars
# cm should set these vars
# $binding_port_name for ovs internal port
# $domainname_list for domain name list seperated by space
# $dns_ip_list for dns server ip list seperated by space
# $batch_add for batch add configure and do not restart dnsmasqx or clear dnsmasq_<port>.conf
#               $batch_add should be "begin", "adding", "end"
mkdir -p /var/run/dns
DNSMASQ_CONF_PATH="/var/run/dns"
DNSMASQ_PATH="/usr/bin"

if [ -n "$1" ]; then
        PORT=$1
        URL=$2
        DNSIP=$3
        BATCHMOD=
else
        PORT=$binding_port_name
        URL=$domainname_list
        DNSIP=$dns_ip_list
        BATCHMOD=$batch_add
fi
RESTART_DNSMASQX=

if [ ! -d "$DNSMASQ_CONF_PATH/dnsmasq.d" ];then
        mkdir -p $DNSMASQ_CONF_PATH/dnsmasq.d
fi
#echo "add_dns.sh run! PORT:$PORT URL:$URL DNSIP:$DNSIP BATCHMOD:$BATCHMOD" >> /tmp/mnt/dns.log

if [ -z "$BATCHMOD" ]; then
        #echo "NOT in batchmod and create dnsmasq.conf" >> /tmp/mnt/dns.log
#create dnsmasqx configure file
        echo "no-resolv" > $DNSMASQ_CONF_PATH/dnsmasq.conf
        echo "no-negcache" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
        echo "cache-size=0" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
        echo "local-ttl=0" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
        echo "neg-ttl=0" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
#	just test for FH, need to change	
        if [ -f /var/run/NS/1/dns ]; then
                for defaultdns in $(cat /var/run/NS/1/dns)
                do
		        echo "server=$defaultdns" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
                done
        fi
        echo "conf-dir=$DNSMASQ_CONF_PATH/dnsmasq.d" >> $DNSMASQ_CONF_PATH/dnsmasq.conf
        RESTART_DNSMASQX="true"
        #echo "dnsmasq.conf is : " >> /tmp/mnt/dns.log
        #cat /etc/dnsx/dnsmasq.conf >> /tmp/mnt/dns.log
#end create configure file
fi

if [ -z "$DNSIP" ]; then
        if [ -f "/var/run/NS/$PORT/dns" ];then
                DNSIP=`cat /var/run/NS/$PORT/dns`
        fi
fi

# for l2tp, need to change
if [ -n "$DNSIP" ] && [ -n "$PORT" ] && [ -n "$URL" ]; then
        configurefilename="$DNSMASQ_CONF_PATH/dnsmasq.d/dnsmasq_"$PORT".conf"
        #echo "configurefilename is $configurefilename" >> /tmp/mnt/dns.log
        #clean configure file before create configure, in batch mode: clean configurefile when in begin status
        if [ -n "$BATCHMOD" ]; then
                RESTART_DNSMASQX=
        else
                rm $configurefilename
        fi
        #create configure file
        for dns in $DNSIP
        do
                for domainame in $URL
                do
                        echo "server=/$domainame/$dns"
                        echo "server=/$domainame/$dns" >> $configurefilename
                done
        done
        #echo "configurefile is : " >> /tmp/mnt/dns.log
        #cat $configurefilename >> /tmp/mnt/dns.log
fi

if [ -n "$RESTART_DNSMASQX" ]; then
        #echo "RESTART_DNSMASQX is $RESTART_DNSMASQX">> /tmp/mnt/dns.log
        killall dnsmasqx
        ip netns exec FM $DNSMASQ_PATH/dnsmasqx -C $DNSMASQ_CONF_PATH/dnsmasq.conf -d &
fi
