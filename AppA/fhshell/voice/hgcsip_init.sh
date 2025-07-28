#!/bin/sh
#Program:call the shell use 2 parmas to start and stop the hgcsip/hgcmegaco. example:hgcsip_init.sh stop hgcsip
#	start: first kill hgcsip/hgcmegaco then start the hgcsip/hgcmegaco
#	stop:  kill the hgcsip/hgcmegaco
#Histrory:
#2013-2-2    lichh update

kill_proc()
{   
	PROC_ID=`pidof $1` 
	if [ -z "$PROC_ID" ]
	then    
		echo "there is no $1 process."     
		rm -f /var/switch_voip_proc_flag
		return
	else
		touch /var/kill_voip_proc_flag
		killall $1
		count=0
		while [ "x$PROC_ID" != "x" ]
		do
			PROC_ID=`pidof $1`
			if [ "x$PROC_ID" == "x" ];
			then
				break
			else
				if test $count -ge 5
				then
					killall $1
					count=0
				fi
			fi
			sleep 1
			count=$((count+1))
			PROC_ID=`pidof $1`
		done
		sleep 5
		rm -f /var/kill_voip_proc_flag
		rm -f /var/switch_voip_proc_flag
	fi
}

start_proc()
{
	while :
	do
		if [ -f /var/kill_voip_proc_flag ] || [ -f /var/switch_voip_proc_flag ]
		then
			sleep 2
		else
			break
		fi
	done
	
	PROC_ID=`pidof $1` 
	#if no current process,then run program directly, else first kill current process,then run 
	if [ -z "$PROC_ID" ]
	then
		echo "Starting $1"
	else
		echo "Restarting $1"
		killall $1
		count=0
		while [ "x$PROC_ID" != "x" ]
		do
			PROC_ID=`pidof $1`
			if [ "x$PROC_ID" == "x" ];
			then
				break
			else
				if test $count -ge 5
				then
					killall $1
					count=0
				fi
			fi
			sleep 1
			count=$((count+1))
			PROC_ID=`pidof $1`
		done
		sleep 5
	fi
	sh -c "$1 >/dev/zero &" 
}

hgcsip_version()
{
	if [ -f /var/softversion ]
	then
		echo "hgcsip=hgcsip.R01.05.build24" >> /var/softversion
	else
		touch /var/softversion
		echo "hgcsip=hgcsip.R01.05.build24" >> /var/softversion
	fi
	chmod +x /var/softversion
}
hgcmegaco_version()
{
	if [ -f /var/softversion ]
	then
		echo "hgcmegaco=hgcmegaco.R01.01.build01" >> /var/softversion
	else
		touch /var/softversion
		echo "hgcmegaco=hgcmegaco.R01.01.build01" >> /var/softversion
	fi
	chmod +x /var/softversion
}

#if parms are not 2 then exit
if [ $# -ne 2 ] ; then
	echo "arguments wrong!! exit"  
	exit 1
fi

case $1 in 
	"stop")	 
	kill_proc "$2"
	;;
	"start")
	start_proc  "$2"
	;;
esac

case $2 in 
	"hgcsip")	 
	hgcsip_version 
	;;
	"hgcmegaco")
	hgcmegaco_version  
	;;
esac
