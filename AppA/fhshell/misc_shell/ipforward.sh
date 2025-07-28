#!/bin/sh

#添加规则
#Usage: ipforward.sh add [interface] [gateway] 
#		ipforward.sh add pon0.50  10.180.24.1 
#删除规则
#Usage: ipforward.sh del [interface] 
#		ipforward.sh del pon0.50  

echo " $0 $1 $2 $3 " >> /var/forward
intf=$2
gateway=$3

configfile=/flash/cfg/app_conf/wancc/${intf}_forwardlist.conf
cid=`cat /var/WEB-GUI/hgcxml.conf | grep IGD_DI_X_CT_COM_IPForwardModeEnabled | cut -d '=' -f 2`
Enable_flag=`getcfgx /flash/cfg/app_conf/wancc/forwardenable.conf mode `
 
FILENAME=/var/udhcpc/udhcpc_${intf}_eth.info

if [ "$1" = "add" ] 
  then 
	if [ "$Enable_flag" == "1" ]
	then
		#add network route
		echo $configfile
		ppp=`getcfgx $configfile ppp`
		if [ "x$ppp" = "x1" ]
			then
			name=`cat /var/run/wan4_ppp.conf |grep $2|cut -d = -f 2`
		else 
			name=$intf
		fi
		if [ "x$name" != "x" ]
			then
			if [ "x$gateway" = "x" ] || [ "x$gateway" = "xNULL" ]
				then
				if [ "x$ppp" = "x1" ]
					then
					gateway=` getcfgx /var/run/*${name}.info remote_IP_address`
				else
					gateway=`getcfgx $FILENAME router`
				fi
			fi
			if [ "x$gateway" = "x" ] || [ "x$gateway" = "xNULL" ]
			
				then
			echo " gateway is null "
			else
				if [ -f /flash/cfg/app_conf/wancc/${intf}_forwardlist.conf ]
					then
					n=1
					while [ $n -le 64 ]
						do
						ipmin=`getcfgx $configfile ip${n}min`
						ipmax=`getcfgx $configfile ip${n}max`
						echo $ipmin $ipmax
						i=`getcfgx $configfile index`
						msk=$(printf "%x" $((16-$i)))
						mi=$((16-$i))
						if [ "$ipmin" = "NULL" ]
							then
							break;
						else
							n=$(($n+1))
							if echo $ipmin|grep -q :
								then
								continue;
							else
								if [ "x$gateway" != "x" ]
									then
									if [ "$ipmax" = "NULL" ]
										then
											iptables -A PREROUTING -t mangle -d ${ipmin} -j MARK --set-mark 0x${msk}0000000/0xf0000000

									else
							
									iptables -A PREROUTING -t mangle -m iprange --dst-range  ${ipmin}-${ipmax} -j MARK --set-mark 0x${msk}0000000/0xf0000000
									fi
				
									ip route add default via $gateway dev $name table ${mi} pri ${mi}
										
									if [ $? -ne 0 ]; then
										voipflag=`ls /var/wan_info/ | grep ${name}_voip`
										tr069flag=`ls /var/wan_info/ | grep ${name}_tr069`
										if [ "x${voipflag}" != "x" ] && [ "x${tr069flag}" != "x" ] 
											then
											tableid=190
											#add route table
											ip  rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 
											tableid=201
											ip  rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 
										elif [ "x${voipflag}" != "x" ] 
											then
											tableid=190
											#add route table
											ip  rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 
											
										elif [ "x${tr069flag}" != "x" ] 
											then
											tableid=201
											ip  rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 
											
										else 
											echo "ip rule add  table failed "
										fi
									else
										#add route table
									ip rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${mi} pri ${mi}
					
									fi
								else
								echo "no gateway no network segment route"
								fi
							fi
							
						fi
					done
				fi
			fi
		fi
	fi
	ip route flush cache
	echo "ip route flush cache"
elif [ "$1" = "del" ]; then
	#del network route
	
		#del network route
		ppp=`getcfgx $configfile ppp`
		if [ "x$ppp" = "x1" ]
			then
			name=`cat /var/run/wan4_ppp.conf |grep $2|cut -d = -f 2`
		else 
			name=$intf
		fi
		
		if [ -f /flash/cfg/app_conf/wancc/${intf}_forwardlist.conf ]
			then
			n=1
			while [ $n -le 64 ] 
				do
				ipmin=`getcfgx $configfile ip${n}min`
				echo $ipmin
				ipmax=`getcfgx $configfile ip${n}max`
				echo $ipmax 
				i=`getcfgx $configfile index`
				msk=$(printf "%x" $((16-$i)))
				mi=$((16-$i))
				if [ "$ipmin" = "NULL" ]
					then
					break;
				else
					n=$(($n+1))
					if echo $ipmin|grep -q :
						then
						continue;
					else
						if [ "$ipmax" = "NULL" ]
						then
						iptables -D PREROUTING -t mangle -d ${ipmin} -j MARK --set-mark 0x${msk}0000000/0xf0000000
						else
							
							#add default route
							iptables -D PREROUTING -t mangle -m iprange --dst-range  ${ipmin}-${ipmax} -j MARK --set-mark 0x${msk}0000000/0xf0000000
							echo "iptables -D PREROUTING -t mangle -m iprange --dst-range  ${ipmin}-${ipmax} -j MARK --set-mark 0x${msk}0000/0xf0000000"
						fi	
						
						ip route del  table ${mi} 
						
						if [ $? -ne 0 ]; then
							ip rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table 190 
		
							echo "ip rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${mi} "
							ip rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table 201 
		
							echo "ip rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${mi} "
							
						else
						ip rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${mi}
						
						fi
					
					fi
				fi
			done
		fi
	ip route flush cache
	echo "ip route flush cache"
else
	echo -e "Usage:\tipforward.sh.sh add [interface] [gateway]"
	echo -e "\tipforward.sh.sh del [interface] "
 fi

exit 0
