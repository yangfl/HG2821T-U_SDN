#!/bin/sh

case $1 in
	1)
		tmp_file=/var/wan_info/*_internet
		;;
	2)
		tmp_file=/var/wan_info/*_tr069
		;;
	3)
		tmp_file=/var/wan_info/*_voip
		;;
	*)
		tmp_file=/var/wan_info/*_internet
esac

if [ ! -f $tmp_file ]; then
	exit 1
fi
 
intf=`ls $tmp_file | awk -F "_" '{print $3}'`

echo "$intf"

exit 0