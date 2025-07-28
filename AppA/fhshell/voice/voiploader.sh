#!/bin/sh


if [ -f /usr/bin/voip_loader ] ;then
/usr/bin/voip_loader > /dev/zero

if [ $? = 0 ];then
VOIP_LOADER_SUCCESS=yes
#echo "voip_loader success"
echo "voip_loader success" >> /var/zhp_voiploader.txt
else
#echo "voip_loader bad"
echo "voip_loader bad" >> /var/zhp_voiploader.txt
fi

taskset -p 0x8 `pidof ORTP_TASK`
taskset -p 0x8 `pidof fxs_task`
taskset -p 0x8 `pidof DSPProc`
taskset -p 0x8 `pidof DspDlTask`
taskset -p 0x8 `pidof DspUlTask`

# mknod /dev/slic c 251 0
# mknod /dev/vdsp c 245 0


echo 8 > /proc/irq/12/smp_affinity

fi
