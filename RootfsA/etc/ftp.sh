#!/bin/sh
#开机启动
while :
do
	if [ -f /var/manager_finished ]
	then
		break
	fi
	if [ -f /var/agent_error_flag ]
	then
		exit
	fi
	sleep 1
done

USERADMINPASSWD=`cat /rom/cfg/agentconf/hgcxml.conf | grep IGD_DI_XFIBCOMUA_Password | cut -d = -f 2 `
PASSWD=`inter_web get $USERADMINPASSWD |  awk -F '&' '{print $1}' `


if [ ! -d /var/e8client/upload ]
then    
        mkdir -p /var/e8client/upload
        mkdir -p /var/e8client/download
        passwd useradmin $PASSWD
        chown useradmin:user -R /var/e8client/
		chmod 750 /var/e8client/
        passwd useradmin-Read $PASSWD
fi
SWITCH=`cat /data/tr069_control.conf | grep smart_client_mgrt_switch | cut -d '=' -f 2`
if [ "$SWITCH" == "0" ]
then
	exit 0
fi
	
while true
do
		
		
			#make sure the password is the same to web
			PASSWD_NEW=`inter_web get $USERADMINPASSWD | awk -F '&' '{print $1}' `
			if [ "$PASSWD" != "$PASSWD_NEW" ]
			then
				passwd useradmin $PASSWD_NEW
				passwd useradmin-Read $PASSWD_NEW
				PASSWD=$PASSWD_NEW
			fi
		
		
		
			if [ -f /var/e8client/upload/e8DigConfig.txt ]
			then
				dos2unix /var/e8client/upload/e8DigConfig.txt
				#判断ITMS交互
				ITMS=`getcfgx /var/hgstatus itms_interactive_status`
				if [ "$ITMS" == "1" ]
				then
					echo "4" >/var/e8client/download/e8DigConfigResult.txt
					unix2dos /var/e8client/download/e8DigConfigResult.txt
					rm -rf /var/e8client/upload/e8DigConfig.txt
				elif [ -f /var/WEB-GUI/session/telecomadmin_* ]
				then
					echo "5" >/var/e8client/download/e8DigConfigResult.txt
					unix2dos /var/e8client/download/e8DigConfigResult.txt
					rm -rf /var/e8client/upload/e8DigConfig.txt
				else

					HEAD=`head -1 /var/e8client/upload/e8DigConfig.txt | cut -d '.' -f 1 `
					if [ "$HEAD" != "InternetGatewayDevice" ]
					then
						echo "1" >/var/e8client/download/e8DigConfigResult.txt
						unix2dos /var/e8client/download/e8DigConfigResult.txt
						rm -rf /var/e8client/upload/e8DigConfig.txt
					fi
						
					#判断配置文件
					cat /var/e8client/upload/e8DigConfig.txt | while read line
					do
						VALUE=`echo $line | awk -F '=' '{print $2}'`
						echo "valve1=$VALUE"
						if [ -z $VALUE ]
						then
							echo "2" >/var/e8client/download/e8DigConfigResult.txt
							unix2dos /var/e8client/download/e8DigConfigResult.txt
							rm -rf /var/e8client/upload/e8DigConfig.txt
							break
						fi
					done < 	/var/e8client/upload/e8DigConfig.txt
				fi
				
				
				if [ -f /var/e8client/upload/e8DigConfig.txt ]
				then
					#解析wlan配置文件到网关
					wifi down
					cat /var/e8client/upload/e8DigConfig.txt | while read line
					do
						PARAM=`echo $line | awk -F '=' '{print $1}'`
						VALUE=`echo $line | awk -F '=' '{print $2}'`
						NUMBER=`cat /rom/cfg/agentconf/hgcxml.param | grep $PARAM | awk -F '=' '{print $1}'`
						if [ ! -z $VALUE ]
						then
							echo "number=$NUMBER valve2=$VALUE"
							inter_web set $NUMBER $VALUE
						fi
					done < 	/var/e8client/upload/e8DigConfig.txt
					echo "0" > /var/e8client/download/e8DigConfigResult.txt
					unix2dos /var/e8client/download/e8DigConfigResult.txt
					rm -rf /var/e8client/upload/e8DigConfig.txt
					wifi up
				fi
			fi
		
		sleep 5
done