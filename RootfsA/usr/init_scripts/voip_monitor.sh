#!/bin/sh

while true
do
    SIP_COUNT=$(ps | grep hgcsip | grep -v grep | wc -l)
    if [ "${SIP_COUNT}" != "0" ]
    then
        echo "The hgcsip process is fine"
    else
        SIP_Switch=`getcfgx /var/voip/voice.conf Line1_Enable`
        now_local_IP_address=`getcfgx /var/voip/voice.conf tempLocalIp`
        if [ "$SIP_Switch" != "Enabled" ] || [ "X$now_local_IP_address" == "X" ]
        then
            echo "no need to start hgcsip process"
        else
			if [ "${SIP_COUNT}" == "0" ]
            then
				if [ ! -f /var/SipAppLogBak ]
				then
					touch /var/SipAppLogBak
					echo 1 > /var/SipAppLogBak
					restart_sip_count=1
					echo "$now_local_IP_address"
					ip netns exec MNG hgcsip&
				else
					restart_sip_count=$(cat /var/SipAppLogBak)
					if [ ${restart_sip_count} -lt 20 ]
					then
						let "restart_sip_count+=1"
						echo "$restart_sip_count" > /var/SipAppLogBak
						echo "$now_local_IP_address"
						ip netns exec MNG hgcsip&
					fi
				fi
            fi
        fi
    fi
    sleep 60
done