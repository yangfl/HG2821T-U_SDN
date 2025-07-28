#!/bin/sh

while [ -f /var/sip_flag ]
do
	sleep 5
done

touch /var/sip_flag
if [ $# -lt 1 ]
then
        touch /var/cm_sip_flag
fi

sip_pid=`ps | grep hgcsip | grep -v grep`
if [ ! -z "$sip_pid" ];then
	killall hgcsip
	
	sleep 3 
fi

while [ ! -f /var/voip/sip_cm_info ]
do
	sleep 1
done

cat /var/voip/sip_cm_info > /var/voip/voice.conf
cat /var/voip/sip_ip_info >> /var/voip/voice.conf

LINK=`ip netns exec MNG ifconfig manager |grep 'inet addr:' |awk '{print $2}'|awk -F: '{print $2}'`
if [ "${LINK}x" != "x" ]
then
	ip netns exec MNG hgcsip > /dev/zero &
else
	echo "do nothing"
fi

rm /var/sip_flag