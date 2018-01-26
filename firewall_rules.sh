#!/bin/bash

#User config
TCPPortAllow=22,80
UDPPortAllow=67,68,53
portDrop=0

#Flush out both INPUT/OUTPUT 
iptables -F

#default policy to DROP inbound traffic
iptables -P INPUT DROP

#default policy to DROP outbound traffic
iptables -P OUTPUT DROP


#define chains
iptables -N tcpin
iptables -N tcpout
iptables -N udpin
iptables -N udpout 

# Drop traffic from 80 for ports less than 1024
iptables -A tcpin -p tcp --sport 0:1023  --dport 80 -j DROP

# Drop all incoming packets from reserved port and outbound traffic to port 0
iptables -A tcpin -p tcp -m multiport --dport $portDrop -j DROP
iptables -A tcpout -p tcp -m multiport --dport $portDrop -j DROP

# Permit inbound/outbound ssh packets
iptables -A tcpin -p tcp -m multiport --dport $TCPPortAllow -j ACCEPT
iptables -A tcpout -p tcp -m multiport --sport $TCPPortAllow -j ACCEPT

#Allow all DNS, DHCP traffic
iptables -A udpin -p udp -m multiport --dport $UDPPortAllow -j ACCEPT
iptables -A udpout -p udp -m multiport --sport $UDPPortAllow -j ACCEPT

#Correlating tcpin/tcpout/udpin/udpout with the INPUT/OUTPUT rules
iptables -A INPUT -p tcp -j tcpin
iptables -A OUTPUT -p tcp -j tcpout
iptables -A INPUT -p udp -j udpin
iptables -A OUTPUT -p udp -j udpout
