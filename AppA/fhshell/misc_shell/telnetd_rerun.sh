#!/bin/sh
killall telnetd 2>/dev/null
start-stop-daemon -S -b -q -x telnetd -- -p $1