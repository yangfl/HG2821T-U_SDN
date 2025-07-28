#!/bin/sh

hw_nat -T 1
hw_nat -N 1
hw_nat -U 1 1 1 1
sys memwl bfb50e2c  0x1fff3fff
sys memwl bfb50e30  0x00010fff
#echo 8 > /proc/irq/23/smp_affinity
echo 300000 > /proc/sys/net/nf_conntrack_max
qdmamgr_lan set rxratelimit config disable packet
qdmamgr_wan set rxratelimit config Disable Packet
qdmamgr_lan set txratelimit  7 Disable 1000000
echo 4096 > /proc/net/skbmgr_hot_list_len

# for wifi throughput test
echo 8 > /proc/irq/23/smp_affinity
echo 8 > /proc/irq/24/smp_affinity
echo 8 > /proc/irq/25/smp_affinity

#68_JoymeV2_EN7526preSDK_160315_dual_band_throughput_patchs_20161009
echo 6000 > /proc/net/skbmgr_limit
echo 6000 > /proc/net/skbmgr_4k_limit
echo 8192 > /proc/net/skbmgr_driver_max_skb

#66_JoymeV2_EN7526preSDK_160315_hwnat_rps_patchs_20160928
 echo 1 > /sys/class/net/eth0/queues/rx-0/rps_cpus
 echo 1 > /sys/class/net/eth1/queues/rx-0/rps_cpus
 echo 1 > /sys/class/net/eth2/queues/rx-0/rps_cpus
 echo 1 > /sys/class/net/eth3/queues/rx-0/rps_cpus
 echo 1  >  /proc/tc3162/rps_enable
