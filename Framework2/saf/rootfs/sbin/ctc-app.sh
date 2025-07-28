#!/bin/ash


DBUS_SEND="dbus-send --system --print-reply --dest=com.ctc.appframework1 /com/ctc/appframework1"
APPAGENT="com.ctc.appframework1.AppAgent"

usage1="Usage: $0 Install/Upgrade ABSOLUTE_PATH_TO_IPK\n
                 Uninstall/Run/Stop/Reload/Restore APP_NAME"
usage2="Usage: $0 List"

if [ $# -ne 1 -a x$1 == xList ]; then
    echo -e $usage2  >&2
    exit 1
fi
if [ $# -ne 2 -a x$1 != xList ]; then
    echo -e $usage1 >&2
    exit 1
fi

if [ x$1 == xList ]; then
	$DBUS_SEND $APPAGENT.List
    exit 1
fi

if [ x$1 == xRun -o x$1 == xStop -o x$1 == xReload -o x$1 == xRestore -o x$1 == xInstall -o x$1 == xUninstall -o x$1 == xUpgrade ]; then
	echo $1 $2
	$DBUS_SEND $APPAGENT.$1 string:$2
fi
