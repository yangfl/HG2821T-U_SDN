#!/bin/sh

###############################################################################
# (C) 2012 Fiberhome Inc <www.fiberhome.com.cn> lfyang@fiberhome.com.cn
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# shell script for linux TCP/IP v6 protocol stack fastpath.
#
###############################################################################
enable=`cat /proc/net/fhroute/fhroute_enable`
conf_enable=`getcfgx /flash/cfg/misc_conf/kernel.conf ipv6_mode`
case "$1" in
2)
	if [ "$enable" != "2" ]; then
		echo 2 > /proc/net/fhroute/fhroute_enable
		echo -e "\t# Fiberhome ipv6 hw fastpath enable!\n"
	else
		echo -e "\t# Fiberhome ipv6 hw fastpath is already enabled!\n"
	fi
	;;
0)
	if [ "$enable" != "0" ]; then
		echo 0 > /proc/net/fhroute/fhroute_enable
		echo -e "\t# Fiberhome ipv6 fastpath disabled!\n"
	else
		echo -e "\t# Fiberhome ipv6 fastpath is already disabled!\n"
	fi
	;;
*)
	echo -e "\tUsage: `basename $0` [0|2] "
	echo -e "\t\t 0: disable TCP/IP ipv6 napt hw fastpath"
	echo -e "\t\t 2: enable ipv6 napt hw fastpath"
	exit 0
	;;
esac
if [ "$conf_enable" != "$1" ]
then
	setcfgx /flash/cfg/misc_conf/kernel.conf ipv6_mode "$1"
fi
