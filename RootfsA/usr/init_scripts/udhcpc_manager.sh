#!/bin/sh

# udhcpc script edited by Tim Riker <Tim@Rikers.org>

[ -z "$1" ] && echo "Error: should be called from udhcpc" && exit 1

RESOLV_CONF="/var/resolv.conf"


#add by xiaboy
if [ "$netns" != "" ] ;then
	RESOLV_CONF="/etc/netns/"$netns"/resolv.conf"
	mkdir -p "/var/etc/netns/"$netns
fi
#end add by xiaboy

#GATEWAY_FILE="/etc/"$interface"_gateway.conf"
DNS_FILE="/var/run/"$interface"/dns"
DNS_NS_FILE="/var/run/NS/"$netns"/dns"
GATEWAY_FILE="/var/run/"$interface"/gateway"
STATUS_FILE="/var/run/"$interface"/status"
IP_FILE="/var/run/"$interface"/ip"
NETMASK_FILE="/var/run/"$interface"/netmask"
DISCOVER_FILE="/var/run/"$interface"/discover"

mkdir -p "/var/run/"$interface
if [ "$netns" != "" ]; then
	mkdir -p "/var/run/NS/"$netns
fi

[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"


case "$1" in
	deconfig)
		#/sbin/ifconfig $interface down
		ifconfig $interface 0.0.0.0
		
		echo "down" > $STATUS_FILE		
		#rm $GATEWAY_FILE
		if [ -f $DNS_FILE ]; then
		rm $DNS_FILE
		fi
		if [ -f $GATEWAY_FILE ]; then 
		rm $GATEWAY_FILE
		fi
		if [ -f $IP_FILE ]; then		
		rm $IP_FILE
		fi
		if [ -f $NETMASK_FILE ]; then		
		rm $NETMASK_FILE
		fi
		echo "udhcpc deconfig" >> /mnt/script.log
		#should we send down message here ?
		;;

	senddiscover)
		SENDTIME=`date |awk 'NR==1{print $4}'`
		echo $SENDTIME > $DISCOVER_FILE
		;;

	renew|bound)
		ifconfig $interface $ip $BROADCAST $NETMASK
		echo "udhcpc renew or bound" >> /mnt/script.log
		echo $ip > $IP_FILE
		echo $subnet > $NETMASK_FILE

		if [ -n "$router" ] ; then
			echo "deleting routers"
			while route del default gw 0.0.0.0 dev $interface ; do
				:
			done

			echo "adding default routers"
			for i in $router ; do
				echo "route add default gw $i dev $interface"
				route add default gw $i dev $interface
				echo "$i" > $GATEWAY_FILE
			done
		fi

		echo -n > $RESOLV_CONF
		[ -n "$domain" ] && echo search $domain >> $RESOLV_CONF
		
		#add by xiaboy
		if [ "$netns" != "" ]; then
			for i in $dns ; do
				echo adding dns $i
				echo nameserver $i >> $RESOLV_CONF
			done
		fi
		#end add by xiaboy
		if [ -f $DNS_FILE ]; then
			rm $DNS_FILE
		fi
		for i in $dns ; do	
			echo $i >> $DNS_FILE
		done
		#add by xiaboy
		if [ "$netns" != "" ]; then
			if [ -f $DNS_NS_FILE ]; then
				rm $DNS_NS_FILE
			fi
			for i in $dns; do
				echo $i >> $DNS_NS_FILE
			done
		fi
		
		echo "up" > $STATUS_FILE
		
		############################################restart dhcp when dhcp is dead############################################


		/usr/bin/notify [${interface}#${interface}#${ip}#${router}#${wandns1}#0#${subnet}#] &
		FILENAME="/var/udhcpc_neterror"
		if [ -e $ FILENAME ]; then
			rm $FILENAME 
		fi
		kill -9 `ps | grep arping | grep "${interface} " | grep -v grep | awk '{print $1}'`
		/usr/bin/arping ${interface} ${router} 240 dhcp "[${interface}#${interface}#${ip}#${router}#$0#0#${subnet}#]" &

		###################################################################################################################

		;;
esac

NTPSERVER=`cat /var/ntpservers.conf`
ip netns exec MNG ntpdate -0 -z +08:00 "$NTPSERVER" 0> /dev/zero 1>&0 2>&0 &

/usr/init_scripts/update_voiceconf.sh $interface $ip $router "$dns" $subnet &

exit 0
