#!/bin/sh

#添加规则
#Usage: ipforward_all.sh add 
	
#删除规则
#Usage: ipforward_all.sh del 


#configfile=/flash/cfg/app_conf/wancc/${intf}_forwardlist.conf

echo " $0 $1 " >> /var/forward
echo " $0 $1 " >> /var/forwardv6
if [ "$1" = "add" ] 
  then
	i=1
	while [ $i -le 16 ]
		do
		 intf=`ls /flash/cfg/app_conf/wancc/ | grep forwardlist.conf | cut -d _ -f 1 | sed -n $i'p'`
		 if [ "x$intf" = "x" ]
			then 
			break;
		else
		/rom/fhshell/misc_shell/ipforward.sh add $intf 
		
		/rom/fhshell/misc_shell/ipforwardv6.sh add $intf 
	
		fi
		i=$(($i+1))
		done
elif [ "$1" = "del" ]
	then
	i=1
	while [ $i -le 16 ]
		do
		 intf=`ls /flash/cfg/app_conf/wancc/ | grep forwardlist.conf | cut -d _ -f 1 | sed -n $i'p'`
		 if [ "x$intf" = "x" ]
			then 
			break;
		else
		/rom/fhshell/misc_shell/ipforward.sh del $intf 

		/rom/fhshell/misc_shell/ipforwardv6.sh del $intf 

		fi
		i=$(($i+1))
		done
else
	echo -e "Usage:\tipforward_all.sh add "
	echo -e "\tipforward_all.sh delete "
fi

exit 0
