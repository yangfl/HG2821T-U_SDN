#!/bin/sh

setcfgx /var/loid.txt $1 $2

led_ctrl set xvr_tx off
sleep 1
led_ctrl set xvr_tx on

sleep 5

pon_flag=`cat /data/factory.conf |grep pon_flag | cut -d = -f 2`
if [ "$pon_flag" = "EPON" ]
then
       #hi_cli /home/cli/epon/mpcp/setsilence -v llidindex 0  reason 1 timeout 1
       killall fhoam                                                                   
       fhoam -M 1 -L 3 & 
fi

