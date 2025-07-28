#!/bin/sh
#
# Starts udhcpd
#
#!/bin/sh

#-----lqu modify 20120806
COMMON_CONF=/etc/fh_common.conf
UDHCPD_CONF=`grep "APP_CONF_PATH_UDHCPD=" $COMMON_CONF | cut -d = -f 2 `
UDHCPD_BIN=`grep "APP_PATH_UDHCPD=" $COMMON_CONF | cut -d = -f 2 `

pid_c=`ps|grep udhcpd|grep -v grep |grep flash|awk '{print $1}'|wc -l`

dns_relay=`getcfgx $UDHCPD_CONF/udhcpd_lan.conf dns_relay_enable`

	if [ "$dns_relay" = "1" -a "${pid_c}" = "1" ]
	then
		exit 0
	fi


#--------
#add dns_xml for tr069 management by mjqiao, 2012-10-26
DNS_XML=`getcfgx /var/WEB-GUI/hgcxml.conf IGD_LAND_1_LANHCM_DNSServers`

# Make sure the required progam exists
[ -f $UDHCPD_BIN ] || exit 0

# Grab DNS servers from /etc/resolv.conf
if [ ! -f /var/udhcpd_enable ]
then
	exit 0
fi

NAMESERVERS=""
#if [ -n "${NAMESERVERS}" ]; then
if [ -f /etc/resolv.conf ]; then
  RESOLV_NAMESERVERS="`cat /etc/resolv.conf | grep nameserver |grep -v : | sed -e 's/nameserver \(.*\)/\1/g' 2>/dev/null`"
  for i in $RESOLV_NAMESERVERS; do
    NAMESERVERS="${NAMESERVERS} ${i}"
 #there will be one more space before the parameters example: " a b"
  done
  #delet space at start and end  ---lqu modify
  NAMESERVERS=`echo "${NAMESERVERS}" | sed -e 's/\(^ *\)//' -e 's/\( *$\)//'`  
fi

# Update udhcpd config files to use these servers
# 更新Udhcpd的配置不向hgcxml同步，直接在/etc/resolv.conf和udhcpd_lan.conf 之间做同步
if [ -n "${NAMESERVERS}" ]; then
#	server=`inter_web get ${DNS_XML}`
	server=`cat /flash/cfg/app_conf/udhcpd/udhcpd_lan.conf  |grep 'option	dns'|cut -d '	' -f 3`
	if [ "${server}" != "${NAMESERVERS}&" ]
	then
     sed -e "s/^option[ \t]*dns.*/option	dns	$NAMESERVERS/" -i /flash/cfg/app_conf/udhcpd/udhcpd_lan.conf
     #inter_web set ${DNS_XML} "${NAMESERVERS}" > /dev/zero &
	fi
fi

#fi

# Start DHCP servers if there is no Linux bridge
#if [ -z "`/sbin/ifconfig | grep "^br0"`" ]; then
  echo "Starting udhcpd on LAN"
  if [  -f /var/udhcpd_lan.leases -a ! -f $UDHCPD_CONF/udhcpd_lan.leases ]; then
  	ln -s /var/udhcpd_lan.leases $UDHCPD_CONF/udhcpd_lan.leases
  fi
  
  killall udhcpd
  $UDHCPD_BIN $UDHCPD_CONF/udhcpd_lan.conf > /dev/zero &

#  echo "Starting udhcpd on WiFi"
#  if [ ! -f /etc/sysconfig/udhcpd_wifi.leases ]; then
#    /bin/touch /etc/sysconfig/udhcpd_wifi.leases
#    /bin/chmod 777 /etc/sysconfig/udhcpd_wifi.leases
#  fi
#  /sbin/udhcpd /etc/sysconfig/udhcpd_wifi.conf &
#fi
