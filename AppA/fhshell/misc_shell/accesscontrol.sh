#!/bin/sh
echo "start ..."
#URL,IP,MAC
ControlType=$1
#black or white
ControlListType=$2
#192.168.1.111,192.168.1.112... or 00:00:00:00:00:01,00:00:00:00:00:02... or http://www.baidu.com,http://www.sina.com...
ControlList=$3
# mac			black	white
# ip			white	black
# configtype	1		2
# configtype=$4
listcount=`echo $ControlList |cut -d " " -f 2 |awk -F  "," '{ print NF}'`
echo "ControlType=$ControlType,ControlListType=$ControlListType,ControlList=$ControlList,listcount=$listcount"

if [ "$ControlListType" = "White" ];then
	RESULT_ACTION="ACCEPT"
	DEFAULT_ACTION="DROP"
elif [ "$ControlListType" = "Black" ];then
	RESULT_ACTION="DROP"
	DEFAULT_ACTION="ACCEPT"
else
	exit 1
fi

#IP黑白名单
#scoutflt.htm.cgi
set_iplist()
{
	iptables -D FORWARD -j IPLIST_FILTER
	iptables -F IPLIST_FILTER
	iptables -X IPLIST_FILTER
	iptables -N IPLIST_FILTER
	if [ "$ControlListType" = "Black" ];then
		iptables  -I FORWARD -j IPLIST_FILTER
	else
		iptables  -A  FORWARD -j IPLIST_FILTER
	fi
	
	CNT=1
	while [ $CNT -le $listcount ]
	do
		
		IP=`echo $ControlList |cut -d " " -f 2 |awk -F  "," '{ print $'$CNT' }'`
		echo "ipbalck=$IP"
		iptables -I IPLIST_FILTER -s $IP -j $RESULT_ACTION
		CNT=$(($CNT+1))
	done
	
	if [ "$ControlListType" == "White" ];then
		iptables -A IPLIST_FILTER -i br0  -j $DEFAULT_ACTION
	fi
	
	/rom/usr/sbin/wandevconfig clsconns
	
}

#MAC黑白名单
#todmngrroute.htm.cgi
set_maclist()
{
	iptables -D FORWARD -j MACLIST_FILTER
	iptables -F MACLIST_FILTER
	iptables -X MACLIST_FILTER
	iptables -N MACLIST_FILTER
	
	if [ "$ControlListType" = "Black" ];then
		iptables  -I FORWARD -j MACLIST_FILTER
	else
		iptables  -A FORWARD -j MACLIST_FILTER
	fi
	
	CNT=1
	while [ $CNT -le $listcount ]
	do
		
		MAC=`echo $ControlList |cut -d " " -f 2 |awk -F  "," '{ print $'$CNT' }'`
		echo "macbalck=$MAC"
		iptables -I MACLIST_FILTER -m mac --mac-source $MAC -j $RESULT_ACTION
		CNT=$(($CNT+1))
	done
	
	if [ "$ControlListType" == "White" ];then
		iptables -A MACLIST_FILTER -i br0  -j $DEFAULT_ACTION
	fi
	
	/rom/usr/sbin/wandevconfig clsconns
	
}

#URL黑白名单
#todmngr.htm.cgi
set_urllist()
{
	iptables  -D FORWARD -j URLLIST_FILTER
	iptables  -F URLLIST_FILTER
	iptables  -X URLLIST_FILTER
	iptables  -N URLLIST_FILTER
	#iptables  -A FORWARD -j URLLIST_FILTER
	if [ "$ControlListType" = "Black" ];then
		iptables  -I FORWARD -j URLLIST_FILTER
	else
		iptables  -A  FORWARD -j URLLIST_FILTER
	fi
	
	CNT=1
	while [ $CNT -le $listcount ]
	do
		
		URL=`echo $ControlList |cut -d " " -f 2 |awk -F  "," '{ print $'$CNT' }'`
		echo "urlbalck=$URL"
		if [ "$ControlListType" = "White" ]
		then
			HOST="${URL}"
		else
			HOST="Host: ${URL}"
		fi
		echo "URL=$HOST"
		iptables -A URLLIST_FILTER -p tcp --dport 80 -m string --string "${HOST}" --algo bm -j $RESULT_ACTION
		CNT=$(($CNT+1))
	done
	
	if [ "$ControlListType" == "White" ];then
		iptables -A URLLIST_FILTER -p tcp --dport 80 -m string --string "GET" --algo bm -j $DEFAULT_ACTION
	fi
	/rom/usr/sbin/wandevconfig clsconns
}

if [ "$ControlType" == "URL" ];then
	set_urllist
elif [ "$ControlType" == "IP" ];then
	set_iplist
elif [ "$ControlType" == "MAC" ];then
	set_maclist
fi

