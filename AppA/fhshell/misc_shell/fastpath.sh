#!/bin/sh

###############################################################################
# (C) 2012 Fiberhome Inc <www.fiberhome.com.cn> lfyang@fiberhome.com.cn
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# shell script for linux TCP/IP protocol stack fastpath.
#
###############################################################################

case "$1" in
1)
	if [ "$enable" != "1" ]; then
		echo -e "\t# Fiberhome fastpath enabled!\n"
		echo 0 > /proc/tc3162/hwnat_off
	else
		echo -e "\t# Fiberhome fastpath is already enabled!\n"
	fi
	;;
0)
	if [ "$enable" != "0" ]; then
		echo -e "\t# Fiberhome fastpath disabled!\n"
		echo 7 > /proc/tc3162/hwnat_off
	else
		echo -e "\t# Fiberhome fastpath is already disabled!\n"
	fi
	;;
*)
	echo -e "\tUsage: `basename $0` [0|1] "
	echo -e "\t\t 0: disable hw fastpath"
	echo -e "\t\t 1: enable hw fastpath"
	exit 0
	;;
esac

conf_enable=`getcfgx /flash/cfg/misc_conf/kernel.conf ipv4_mode`
if [ "$conf_enable" != "$1" ]
then
	setcfgx /flash/cfg/misc_conf/kernel.conf ipv4_mode "$1"
fi
