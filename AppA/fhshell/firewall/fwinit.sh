#!/bin/sh

IPTABLES=iptables
IP6TABLES=ip6tables
LANIF=br0

#*_NOT_FW_USRR is for other app user
create_user_chain()
{
	#add in INPUT CHAIN(INPUT_NOTFW_USER)
	$IPTABLES -N CHAIN_BLACK_ACCESS_CONTROL
	$IPTABLES -A INPUT_NOTFW_USER -j CHAIN_BLACK_ACCESS_CONTROL
	
	$IPTABLES -N CHAIN_BLACK_STORAGE_CONTROL
	$IPTABLES -A INPUT_NOTFW_USER -j CHAIN_BLACK_STORAGE_CONTROL
	
	$IPTABLES -N CHAIN_SERVICE
	$IPTABLES -A INPUT_NOTFW_USER -j CHAIN_SERVICE
	
	$IPTABLES -N PLUGIN_PORT
	$IPTABLES -A INPUT_NOTFW_USER -j PLUGIN_PORT
	
	#add in FOWARD CHAIN(FORWARD_NOTFW_USER)
	$IPTABLES -N BLACK_MAC_FILTER
	$IPTABLES -A FORWARD_NOTFW_USER -j BLACK_MAC_FILTER
}

#======init nat table
#build chain
$IPTABLES -t nat -N safe_port_map 
$IPTABLES -t nat -N safe_dmz 

#apend chain
$IPTABLES -t nat -A PREROUTING -j safe_port_map
$IPTABLES -t nat -A PREROUTING -j safe_dmz
#======end init nat table

#======init filter table
#build chain
$IPTABLES -N chain_mss

#NOT_FW_USRR is for other app user
$IPTABLES -N INPUT_NOTFW_USER
$IPTABLES -N FORWARD_NOTFW_USER

$IPTABLES -N MAC_FILTER
$IPTABLES -N safe_port_filter
$IPTABLES -N safe_url_filter
$IPTABLES -N safe_dos
$IPTABLES -N safe_port_map
$IPTABLES -N safe_dmz

# for firewall-level
$IPTABLES -N INPUT_BOUND
$IPTABLES -N bad_packets
$IPTABLES -N icmp_packets
$IPTABLES -N INPUT_OTHERS
$IP6TABLES -N INPUT_OTHERS
$IPTABLES -N FORWARD_OTHERS

#apend chain-FORWARD
$IPTABLES -A FORWARD -p tcp -j chain_mss
$IPTABLES -A FORWARD -j FORWARD_NOTFW_USER
$IPTABLES -A FORWARD -i $LANIF -j MAC_FILTER
$IPTABLES -A FORWARD -j safe_port_filter
$IPTABLES -A FORWARD -p tcp -i $LANIF -j safe_url_filter
$IPTABLES -A FORWARD ! -i $LANIF -j safe_dos
$IPTABLES -A FORWARD ! -i $LANIF -j safe_port_map
$IPTABLES -A FORWARD ! -i $LANIF -j safe_dmz
$IPTABLES -A FORWARD -j FORWARD_OTHERS

#apend chain-INPUT
$IPTABLES -A INPUT -j INPUT_NOTFW_USER
$IPTABLES -A INPUT -j safe_dos
#  for firewall-level
#   level-low/middle/high(tcp/udp port)
$IPTABLES -A INPUT ! -i $LANIF -j INPUT_BOUND
#   level-middle(icmp)
$IPTABLES -A INPUT -p icmp ! -i $LANIF -j icmp_packets
#   level-middle/high(drop badpacket)
$IPTABLES -A INPUT -j bad_packets
#   level-middle/high(accept esablish packets)
$IPTABLES -A INPUT -j INPUT_OTHERS
$IP6TABLES -A INPUT -j INPUT_OTHERS
#======end init filter table

create_user_chain
