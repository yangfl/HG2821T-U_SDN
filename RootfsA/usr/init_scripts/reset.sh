#!/bin/sh

. /usr/init_scripts/env_para.sh

#kill cm & dm
killall cm
rem -k 01
rem -k 02

#kill processes of ovs
killall ovsdb-server
killall ovs-vswitchd

#clean db-in-flash
rm -rf /usr/local/db/*


mkdir -p /usr/local/db
touch /usr/local/db/conf.fact

if [ -n "$1" ]; then
	factory_restore 0 > /dev/zero
	#reset loid
else
	factory_restore 1 > /dev/zero
fi
