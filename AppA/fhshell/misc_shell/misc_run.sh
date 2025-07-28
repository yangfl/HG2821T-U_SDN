#!/bin/sh

PROGRAM_CONF=/var/program.conf
COMMON_CONF=/etc/fh_common.conf
CONF_PATH=`grep "APP_CONF_PATH_TR069=" $COMMON_CONF | cut -d = -f 2 `
INTERNET_LED_CHECK_PATH=`grep "MISC_SHELL_PATH_INTERNETLED_CTRL_ITMSV4=" $COMMON_CONF | cut -d = -f 2 `
MISC_SHELL_PATH=`cat /etc/fh_common.conf | grep "MISC_SHELL_PATH=" | cut -d = -f 2 `

NSM_RUN=`grep "APP_PATH_NSM=" $COMMON_CONF | cut -d = -f 2 `
Param_File_Path=`grep "APP_CONF_PATH_TR069_HGCXML=" $COMMON_CONF | cut -d = -f 2 `
MISC_FILE_PATH=/var/misc_run_param.conf

init_seq_num()
{
grep "IGD_T_.*"   $Param_File_Path  > $MISC_FILE_PATH
grep "IGD_WAND_1_WANCD_.*Status"   $Param_File_Path  >> $MISC_FILE_PATH
grep "IGD_WAND_1_WANCD_.*_NATEnabled"   $Param_File_Path  >> $MISC_FILE_PATH
grep "IGD_WAND_1_WANCD_.*ExternalIPAddress"   $Param_File_Path  >> $MISC_FILE_PATH
}
detect_fix_mac()
{
	if [ ! -f /usr/local/fh/debug_mode ]; then
		UPTIME="`cat /proc/uptime | awk -F  "." '{print $1}'`"
		if [ "$UPTIME" -le "240" ]; then
			LANID=1
			FIX_MAC=`get_mac $LANID |grep 10:88:ce:6e:b3:db`
			if [ ! -z "$FIX_MAC" ]; then
				echo "LAN $LANID is fix mac!"
				touch /usr/local/fh/debug_mode
				sync
				/rom/fhshell/misc_shell/led_all_blk.sh &
				sleep 10
				reboot
				exit
			fi
		fi
	fi
}

internet_led_check()
{
	PROC_ID=`pidof service_internet_led_check`
	if [ -z "$PROC_ID" ]
	then
		$MISC_SHELL_PATH/service_internet_led_check &
	fi	
}

ntpdate_check()
{
	PROC_ID=`pidof service_ntpdate_check`
	if [ -z "$PROC_ID" ]
	then
		$MISC_SHELL_PATH/service_ntpdate_check &
	fi
}

firewall_check()
{
	PROC_ID=`pidof service_firewall_check`
	if [ -z "$PROC_ID" ]
	then
		$MISC_SHELL_PATH/service_firewall_check &
	fi
}

nsm_start()
{
	PROC_ID=`pidof fh_nsm`
	if [ -z "$PROC_ID" ]
	then
		if [ -f /var/WEB-GUI/web_init.sh ]
		then
			chmod +x /var/WEB-GUI/web_init.sh
			/var/WEB-GUI/web_init.sh &
			setcfgx $PROGRAM_CONF nsm 3
		fi
		$NSM_RUN &
	fi
}

nsm_stop()
{
	PROC_ID=`pidof fh_nsm`
	if [ ! -z "$PROC_ID" ]
	then
		killall fh_nsm
	fi
}

nsm_check()
{
	PROC_ID=`pidof fh_nsm`
	if [ -z "$PROC_ID" ]
	then
		$NSM_RUN &
	fi
}

agent_start()
{
	PROC_ID=`pidof agent`
	Wait_Time=0
	if [ -z "$PROC_ID" ]
	then
		echo "FiberHome agent start.........."
		if [ -f /var/agent.log ]
		then
			echo "agent.log exist in /var"
		else
			echo "[ The LOG information of Agent................. ] " > /var/agent.log
			echo "   "  >> /var/agent.log
		fi
		
		agent -F ${CONF_PATH}/ -M 1 -L 5 -S 2000 -X 1  >> /dev/zero &
		while :
		do
			Wait_Time=`expr $Wait_Time + 1 `
			if [ -f /var/manager_finished ]
			then
				break
			fi
			sleep 1
			if [ $Wait_Time -ge 10 ]
			then
				TMP_PROC_ID=`pidof agent`
				if [ -z "$TMP_PROC_ID" ]
				then
					touch /var/agent_error_flag
					break
				fi
			fi
		done
		setcfgx $PROGRAM_CONF agent 3
	fi
}

agent_stop()
{
	PROC_ID=`pidof agent`
	if [ ! -z "$PROC_ID" ]
	then
		killall agent
	fi
}

agent_check()
{
	#detect_fix_mac
	PROC_ID=`pidof agent`
	if [ -z "$PROC_ID" ]
	then
		touch /var/agent_error_flag

		echo "agent error Exit at:`date`, HG Will Reboot Auto." > /usr/local/fh/logbak/agent_error_log

		echo 
		echo 
		echo "Agent Error"
		echo "Fatal error, HG need to reboot...."
		echo "Begin to backup the log abdout Agent.................."

		echo 
		cp /var/agent.log /usr/local/fh/logbak/agent.exit.log -rf
		echo "Backup agent.log finished..........."
		sleep 1

		echo 
		cp /var/devfunc.log /usr/local/fh/logbak/devfunc.exit.log -rf
		echo "Backup devfunc.log finished..........."
		sleep 1

		echo 
		cp /var/libcfgrw.log /usr/local/fh/logbak/libcfgrw.exit.log -rf
		echo "Backup libcfgrw.log finished..........."
		sleep 1

		echo 
		cp /var/libmsg.log /usr/local/fh/logbak/libmsg.exit.log -rf
		echo "Backup libmsg.log finished..........."
		sleep 1

		echo 
		cp /var/libsharedmem.log /usr/local/fh/logbak/libsharedmem.exit.log -rf
		echo "Backup libsharedmem.log finished..........."
		sleep 1

		echo 
		echo "HG will Reboot in 1 minitues."
		sleep 60

		echo "HG Rebotting..........."
		sleep 5

		reboot 
	fi
}

start_service()
{
	case $1 in
		"agent")
			agent_start
			;;
		"nsm")
			nsm_start
			;;
		*)
			;;
	esac
}

stop_service()
{
	case $1 in
		"agent")
			agent_stop
			;;
		"nsm")
			nsm_stop
			;;	
		*)
			;;
	esac
}

check_service()
{
	case $1 in
		"agent")
			agent_check
			;;
		"nsm")
			nsm_check
			;;	
		"internet_led")
			internet_led_check
			;;
		"firewall")
			firewall_check
			;;
		"ntpdate")
			ntpdate_check
			;;
		*)
			;;
	esac
}

do_ctrl_service()
{	
	while read line
	do
		service_name=`echo $line | awk -F '=' '{print $1}'`
		service_status=`echo $line | awk -F '=' '{print $2}'`
		if [ "$service_status" == "1" ]
		then
			start_service $service_name
		elif [ "$service_status" == "0" ]
		then
			stop_service $service_name
		fi
	done  < $PROGRAM_CONF
}

do_check_service()
{
	while read line
	do
		service_name=`echo $line | awk -F '=' '{print $1}'`
		service_status=`echo $line | awk -F '=' '{print $2}'`
		if [ "$service_status" == "3" ]
		then
			check_service $service_name
		fi
	done  < $PROGRAM_CONF
}

fwinit()
{
	FIREWALL_PATH=`grep "APP_SHELL_PATH_FIREWALL=" $COMMON_CONF | cut -d = -f 2 `
	$FIREWALL_PATH/fwinit.sh
}

main()
{
	fwinit
	init_seq_num
	if [ ! -f $PROGRAM_CONF ]
	then
		touch $PROGRAM_CONF
	fi
	setcfgx $PROGRAM_CONF agent 1
	setcfgx $PROGRAM_CONF nsm 1
	setcfgx $PROGRAM_CONF internet_led 3
	setcfgx $PROGRAM_CONF firewall 3
	setcfgx $PROGRAM_CONF ntpdate 3
	setcfgx $PROGRAM_CONF NTPCounts 0
	sync
	
	while :
	do
		do_ctrl_service
		sleep 4
		do_check_service
		sleep 8
	done
}

main