#!/bin/sh

#-----lqu modify 20120816
COMMON_CONF=/etc/fh_common.conf
GETCFG=`grep "MISC_SHELL_PATH_GETCFG=" $COMMON_CONF | cut -d = -f 2 `
PINGCONDIF=`grep "MISC_SHELL_PATH_PINGCONDIF=" $COMMON_CONF | cut -d = -f 2 `

PINGCONFIG_PATH="/var/ping.config"
while true
do
    if [ -f /var/wancc_finished ]
    then
        ALL_ENABLE=`$GETCFG $PINGCONFIG_PATH PingConfigEnable`
        if [ "x$ALL_ENABLE" == "x0" ]
        then 
            # echo "Value of PingConfigEnable is $ALL_ENABLE, now break the loop~"
            break 
        else        
            # echo "Value of PingConfigEnable is $ALL_ENABLE, now go to start the pingconfig~"            
            
            # sleep 60 seconds to wait the interface and udhcpc or pppoed getting the IP.
            echo "sleep 60 seconds to wait the interface and udhcpc or pppoed getting the IP.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~."
            sleep 300 
            INDEX="1 2 3"
            for PING_INDEX in $INDEX
            do
                sleep 1
                # echo "ping_index = $PING_INDEX"
                STATE=`$GETCFG $PINGCONFIG_PATH State_$PING_INDEX`
                STOP=`$GETCFG $PINGCONFIG_PATH Stop_$PING_INDEX`                
                # echo "Value of State_$PING_INDEX is $STATE"
                # echo "Value of Stop_$PING_INDEX is $STOP"
                
                if [ "x$STATE" == "xRequested" ]
                then
                    if [ "x$STOP" == "x0" ]
                    then
                        # echo "start_command: start-stop-daemon -S -b -x /usr/bin/pingconfig -- $PING_INDEX 2 1 &"
                        start-stop-daemon -S -b -x $PINGCONDIF -- $PING_INDEX 2 1 &
                    else
                        continue
                    fi    
                else
                    continue
                fi
            done 
            break 
        fi    
    else
        echo "Pingconfig is waiting for the flag of wancc_finished to start............................."
        sleep 5
    fi
done
