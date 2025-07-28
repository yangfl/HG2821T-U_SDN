#!/bin/sh

if [ $# != "2" ]; then
    echo "Input parameter fault"
    exit 0
fi

PORTNUM=$1
MAXNUM=$2
MACNUM=0

brctl showmacs br0 | sed -n '1!p' > /var/upnpmacs.temp

while read line
do
    TEMP=`echo $line | awk '{printf $1}'`  
	FLAG_ONLINE=`echo $line | awk '{printf $3}'`
	
    if [ "$TEMP" == "$PORTNUM" ] && [ "$FLAG_ONLINE" == "no" ]; then
		MACNUM=$((MACNUM+1))
		
		if [ $MACNUM -gt $MAXNUM ]; then
			MACNUM=$((MACNUM-1))
			break
		else
			MAC=`echo $line | awk '{printf $2}'`	
			if [ -f /var/upnpmacs.txt ]; then
				echo -n "$MAC" | sed 's/://g' >> /var/upnpmacs.txt
			else
				touch /var/upnpmacs.txt
				echo -n "macs=$MAC" | sed 's/://g' > /var/upnpmacs.txt				
			fi
		fi
	fi
done </var/upnpmacs.temp

echo "" >> /var/upnpmacs.txt
echo "macnum=$MACNUM" >> /var/upnpmacs.txt