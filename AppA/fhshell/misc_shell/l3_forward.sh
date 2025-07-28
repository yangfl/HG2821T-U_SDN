#!/bin/sh
L3_FORWARD_CONF=/flash/cfg/misc_conf/l3_route.conf
PPP_TMP=/var/pppfile.tmp
ROUTE_SHELL=/rom/fhshell/misc_shell/route_set.sh

sleep 2
. $L3_FORWARD_CONF

for index in 1 2 3 4 5 6 7 8 
do
		intf=Interface${index}
		eval intf=\$${intf}
		if [ "$intf" == "NULL" ]; then
			cid=`cat /rom/cfg/agentconf/hgcxml.conf | grep IGD_L3F_F_${index}_Interface | cut -d '=' -f 2`
			intfparam=InterfaceParam${index}
			eval intfparam=\$${intfparam}
			inter_web set $cid $intfparam
			echo "inter_web set $cid $intfparam"
			. $L3_FORWARD_CONF
		fi
		if [ "$intf" == "" ]; then
			continue
		fi
		
		ls /var/run/*${intf}_ppp*.info > ${PPP_TMP} 2> /dev/null
		if [ -s ${PPP_TMP} ]; then
			devname=`cat ${PPP_TMP} | cut -d '_' -f 3 | cut -d '.' -f 1`
		else
			devname=$intf
		fi
		
		dstnetmask=DestSubnetMask${index}
		eval dstnetmask=\$${dstnetmask}
		if [ "$dstnetmask" == "" ]; then
			continue
		fi
		
		dstip=DestIPAddress${index}
		eval dstip=\$${dstip}
		if [ "$dstip" == "" ]; then
			continue
		fi
		
		param=InterfaceParam${index}
		eval param=\$${param}
		if [ "$param" == "" ]; then
			continue
		fi
		
		i=`echo $param | cut -d '.' -f 5`
		if [ -s ${PPP_TMP} ]; then
			param_gw=${param}.RemoteIPAddress
		else
			param_gw=${param}.DefaultGateway
		fi
		id=`cat /rom/cfg/agentconf/hgcxml.param | grep ${param_gw} | cut -d '=' -f 1`
		gateway=`inter_web get $id | cut -d '&' -f 1`
		if [ "$gateway" == "NULL" ]; then
			continue
		fi
		
		$ROUTE_SHELL delete $devname $dstip $dstnetmask $gateway
		$ROUTE_SHELL add $devname $dstip $dstnetmask $gateway
done

exit 0
