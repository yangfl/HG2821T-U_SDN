#!/bin/sh

#添加规则
#Usage: ipforwardv6.sh add [interface]  [gate6way]
#		ipforwardv6.sh add pon0.50   2000::1
#删除规则
#Usage: ipforwardv6.sh del [interface] 
#		ipforwardv6.sh del pon0.50  

echo " $0 $1 $2 $3 " >> /var/forwardv6
intf=$2
gate6way=$3

configfile=/flash/cfg/app_conf/wancc/${intf}_forwardlist.conf
cid=`cat /var/WEB-GUI/hgcxml.conf | grep IGD_DI_X_CT_COM_IPForwardModeEnabled | cut -d '=' -f 2`
Enable_flag=`getcfgx /flash/cfg/app_conf/wancc/forwardenable.conf mode`

FILENAME=/var/udhcpc/udhcpc_${intf}_eth.info

if [ "$1" = "add" ] 
  then
	if [ "$Enable_flag" == "1" ]
	then
		#add network route
	
		ppp=`getcfgx $configfile ppp`
		if [ "x$ppp" = "x1" ]
			then
			name=`cat /var/run/wan_ppp.conf |grep $2|cut -d = -f 2`
		else 
			name=$intf
		fi
		if [ "x$name" != "x" ]
			then
			if [ "x$gate6way" = "x" ] || [ "x$gate6way" = "xNULL" ]
			  then
				gate6way=` route -A inet6 2>&1| grep 'UG' |grep $name |cut -d ' ' -f 41 `
			fi
			if [ "x$gate6way" = "x" ] || [ "x$gate6way" = "xNULL" ]
				then
			echo " gate6way is null"
			
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
								if [ "x$gate6way" = "x" ] || [ "x$gate6way" = "xNULL" ]
									then
									echo "no gateway no network segment route"
								else
									if [ "$ipmax" = "NULL" ]
										then
								
										ip6tables -A PREROUTING -t mangle -d ${ipmin} -j MARK --set-mark 0x${msk}0000000/0xf0000000
								
									else
									
										ip6tables -A PREROUTING -t mangle -m iprange --dst-range  ${ipmin}-${ipmax} -j MARK --set-mark 0x${msk}0000000/0xf0000000
									fi	
											
									ip -6 route add default via $gate6way dev $name table ${mi} pri ${mi}
										
									if [ $? -ne 0 ]; then
										voipflag=`ls /var/wan_info/ | grep ${name}_voip`
										tr069flag=`ls /var/wan_info/ | grep ${name}_tr069`
										if [ "x${voipflag}" != "x" ] && [ "x${tr069flag}" != "x" ] 
											then
											tableid=502
											#add route table
											ip -6 rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 
												tableid=501
											ip -6 rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 
										elif [ "x${voipflag}" != "x" ] 
											then
											tableid=502
											#add route table
											ip -6 rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 

										elif [ "x${tr069flag}" != "x" ] 
											then
											tableid=501
											ip -6 rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${tableid} 

										else 
											echo "ip rule add  table failed "
										fi
									else
											#add route table
										ip -6 rule add iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${mi} pri ${mi} 
									fi
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

		ppp=`getcfgx $configfile ppp`
		if [ "x$ppp" = "x1" ]
			then
			name=`cat /var/run/wan_ppp.conf |grep $2|cut -d = -f 2`
		else 
			name=$intf
		fi
		if [ -f /flash/cfg/app_conf/wancc/${intf}_forwardlist.conf ]
			then
				n=1
			while [ $n -le 64 ] 
				do
				ipmin=`getcfgx $configfile ip${n}min`
				ipmax=`getcfgx $configfile ip${n}max`
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
							if [ "$ipmax" = "NULL" ]
								then
								ip6tables -D PREROUTING -t mangle -d  ${ipmin} -j MARK --set-mark 0x${msk}0000000/0xf0000000
							
							else
								
							ip6tables -D PREROUTING -t mangle -m iprange --dst-range  ${ipmin}-${ipmax} -j MARK --set-mark 0x${msk}0000000/0xf0000000
							fi
							ip -6 route del  table ${mi} 
								#del route table
							if [ $? -ne 0 ]; then
								ip -6 rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table 501
								
								ip -6 rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table 502
							else
							ip -6 rule del iif br0 fwmark 0x${msk}0000000/0xf0000000 table ${mi} 
		
							fi
						
					fi
				fi
			done
		fi
	ip route flush cache
	echo "ip route flush cache"
else
	echo -e "Usage:\tipforwardv6.sh.sh add [interface] [gateway]"
	echo -e "\tipforwardv6.sh.sh del [interface] "
fi

exit 0
