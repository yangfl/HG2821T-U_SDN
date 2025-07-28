#!/bin/sh
. /usr/init_scripts/env_para.sh

#enter factory mode
#echo "a" > /usr/local/.onepiece
echo "a" > /usr/local/fh/mf/.onepiece
#cp /userfs/bin/utelnetd /usr/local
#chmod +x /usr/local/utelnetd
touch /usr/local/fh/mf/factory_mode
#$IP_CMD netns exec APP /usr/local/utelnetd &
$IP_CMD netns exec APP telnetd -p 23 &
ovsdb-client transact '["Open_vSwitch",{"op":"delete","table":"FlowsConfig","where":[["br_name","==","SDN-bridge"]]}]'
#rm -rf /usr/local/db/initialized
rm -rf $OVSDB_PATH/initialized


echo "=========================reture factory success======================"
echo "=========================telnet start============================"