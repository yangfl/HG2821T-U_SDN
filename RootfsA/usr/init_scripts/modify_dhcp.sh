#!/bin/sh

# call by cm
# modify_dhcp.sh

killall udhcpd
ip netns exec NM /usr/bin/udhcpd /var/udhcpd.conf > /dev/zero &
