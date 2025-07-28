#!/bin/sh
ROUTE_SHELL=/rom/fhshell/misc_shell/l3_forward.sh
RUNNING_FILE=/var/l3.tmp
if [ ! -f $RUNNING_FILE ]; then
	touch $RUNNING_FILE
	sleep 5
	$ROUTE_SHELL
	rm -rf $RUNNING_FILE
fi

exit 0
