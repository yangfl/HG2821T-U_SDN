#!/bin/sh

. /usr/init_scripts/env_para.sh
mkdir -p /var/voip/

#make CPU balance
#echo 8 > /proc/irq/23/smp_affinity

#change OAM to CPU 1 , need to change for gpon
OAMPID=`pidof epon_oam`
taskset -p 8 $OAMPID

DEL_BR=$CFG_PATH/del_br.sh
BR_INIT_FILE="$CFG_PATH/build_init_br.sh"

$DEL_BR
$BR_INIT_FILE

echo "SDN Init Accomplish!"
