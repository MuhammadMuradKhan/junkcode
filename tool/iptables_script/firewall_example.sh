#!/bin/bash
#########################################################################
# Date: 28 Aug, 2005                                                    #
# Author: Matthew Schwartz <matthew.r.schwartz@gmail.com>               #
# Copyright (C) 2005 Matthew Schwartz                                   #
#                                                                       #
# This program is free software; you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, version 2 or later.                     #
#                                                                       #
# This program is distributed in the hope that it will be useful, but   #
# WITHOUT ANY WARRANTY, not even implied warranties such as             #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     #
# General Public License for details.                                   #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# with this program or have been able to obtain it from the program's   #
# download site.  If not, you can obtain it from the Free Software      #
# Foundation's web site, http://www.gnu.org/                            #
#########################################################################
#This firewall script is based around the rule of
#"That which is not explicitly allowed is prohibited"
#In addtion this tool is setup to "ALLOW" all out!
#This method of "ALLOW" all out may not be best suited for your configuration
#There are only 3 sections that the user should need adjustments for there needs
#1 Red interface (RED_INTERFACE)
#2 Green interface (GREEN_INTERFACE)
#3 USER DEFINED RULES 


############################################
# USAGE
############################################
if [ $# != 2 ]; then
        echo "Usuage $0 <RED Interface> <respond to ping (RED Interface) ON/OFF>"
        exit 1
fi

############################################
# LOAD KERNEL MODULES
############################################
#In most modern systems these are allready loaded
#modpobe iptables load by default
#modprobe ip_conntrack_ftp


############################################
# DEFINITIONS
############################################
#Red interface
RED_INTERFACE=$1
#Respond to ICMP Ping (ICMP type 8 "Echo")
PING=$2
#Red ip address
RED_IPADDRESS=`/sbin/ifconfig $RED_INTERFACE | grep 'inet addr:' | awk '{print $2}' | cut -c6-20`
#Green interfaces
GREEN_INTERFACE=`/sbin/ifconfig | awk '/^eth|^lo/ {print \$1}' | egrep -v $RED_INTERFACE`


############################################
# ON THE FLY CHANGES AND DEFAULT POLCY
############################################
#The following is used in case you have rules running and you need to call 
#this script to reconfigure on the fly
iptables -F             #Flush all chains
iptables -t nat -F
iptables -t mangle -F

iptables -X             #Delete all user defined chains
iptables -t nat -X
iptables -t mangle -X

iptables -Z             #Zero the packet and byte counters in all chains
iptables -t nat -Z
iptables -t mangle -Z
#Setup of default policy
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT


#############################################
# KERNEL FLAGS
#############################################
#To disable response to ICMP echo reply (ping):
#/bin/echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all  
#
#To disable response to broadcasts, because you don't want the system becoming a Smurf amplifier:
#see http://www.cert.org/advisories/CA-1998-01.html
if [ -f /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts ]; then
        /bin/echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts 
fi
#
#Do not accept source routed packets (packets that pretend to come from inside your network)
if [ -f /proc/sys/net/ipv4/conf/all/accept_source_route ]; then
        /bin/echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
fi
#
#Do not accept ICMP redirects, ICMP redirects can alter your routing table
#ICMP Redirect (type5)
#Codes
#0 Redirect Datagram for the Network (or subnet)
#1 Redirect Datagram for the Host
#2 Redirect Datagram for the Type of Service and Network
#3 Redirect Datagram for the Type of service and Host
for interface in /proc/sys/net/ipv4/conf/*/accept_redirects; do
        /bin/echo "0" > ${interface}
done
#Turning on reverse path filetering
for interface in /proc/sys/net/ipv4/conf/*/rp_filter; do
        /bin/echo "1" > ${interface}
done
#log spoofed, source routed, and redirected packets
if [ -f /proc/sys/net/ipv4/conf/all/log_martians ]; then
        /bin/echo "1" > /proc/sys/net/ipv4/conf/all/log_martians
fi 
#Enable ICMP bogus error responses
#This may happen is a router sends out invaild responses to broadcast frames
#Thas is a violation to RFC 1122, thus to avoid filling up the log file with clutter,
#we tell the kernel no to issue these warnings.
if [ -f /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses ]; then
        /bin/echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
fi
#SYNC Cookies protection (prevent DoS)
if [ -f /proc/sys/net/ipv4/tcp_syncookies ]; then
        /bin/echo "1" > /proc/sys/net/ipv4/tcp_syncookies
fi
#Turing on IP forwarding, becasue the system is going to act as a router
if [ -f /proc/sys/net/ipv4/ip_forward ]; then
        /bin/echo "1" > /proc/sys/net/ipv4/ip_forward
fi


############################################
# STEALTH SCANS AND BAD TCP STATE FLAGS
############################################
iptables -N BAD_FLAGS
#Pass traffic with bad flags to the BAD_FLAGS chain
iptables -A INPUT -p tcp -j BAD_FLAGS
#Chain for traffic with bad flags
#NMAP Xmas 
iptables -A BAD_FLAGS -p tcp  -m limit --limit 1/m --limit-burst 5 --tcp-flags ALL FIN,URG,PSH -j LOG --log-prefix "IPTABLE TCP NMAP:XMAS FLAG" 
iptables -A BAD_FLAGS -p tcp  --tcp-flags ALL FIN,URG,PSH -j DROP
#Merry Xmas
iptables -A BAD_FLAGS -p tcp  -m limit --limit 1/m --limit-burst 5 --tcp-flags ALL SYN,RST,ACK,FIN,URG -j LOG --log-prefix "IPTABLE MERRY XMAS FLAG"
iptables -A BAD_FLAGS -p tcp  --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
#NMAP FIN
iptables -A BAD_FLAGS -p tcp  -m limit --limit 1/m --limit-burst 5 --tcp-flags ALL FIN -j LOG --log-prefix "IPTABLE TCP NMAP:FIN FLAG"
iptables -A BAD_FLAGS -p tcp  --tcp-flags ALL FIN -j DROP       
#SYN/FIN
iptables -A BAD_FLAGS -p tcp  -m limit --limit 1/m --limit-burst 5 --tcp-flags SYN,FIN SYN,FIN -j LOG --log-prefix "IPTABLE TCP SYN/FIN"
iptables -A BAD_FLAGS -p tcp  --tcp-flags SYN,FIN SYN,FIN -j DROP
#SYN/RST
iptables -A BAD_FLAGS -p tcp  -m limit --limit 1/m --limit-burst 5 --tcp-flags SYN,RST SYN,RST -j LOG --log-prefix "IPTABLE TCP SYN/RST"
iptables -A BAD_FLAGS -p tcp  --tcp-flags SYN,RST SYN,RST -j DROP
#Null
iptables -A BAD_FLAGS -p tcp  -m limit --limit 1/m --limit-burst 5 --tcp-flags ALL NONE -j LOG --log-prefix "IPTABLE TCP NULL FLAG"
iptables -A BAD_FLAGS -p tcp  --tcp-flags ALL NONE -j DROP
#All flags set
iptables -A BAD_FLAGS -p tcp  -m limit --limit 1/m --limit-burst 5 --tcp-flags ALL ALL -j LOG --log-prefix "IPTABLE TCP ALL FLAGS"
iptables -A BAD_FLAGS -p tcp  --tcp-flags ALL ALL -j DROP


############################################
# SYN-FLOODING PROTECTION
############################################
#This rule maximises the rate of incoming connections. To do this we send all tcp
#packets with the SYN bit set off to a new user-defined chain called sync-flood
#--syn The syn flag must ge set as an initial connection request
#SYN packets are packets with the SYN flag set, and RST, and ACK flags cleared.
#"By diallowing only these packets, we stop attempted connections in thier tracks" 
#-- Rusty Russell Linux 2.4 Packet Filtering HOWTO Revision 1.26
iptables -N SYN-FLOOD
iptables -A INPUT -i $RED_INTERFACE -p tcp --syn -j SYN-FLOOD
iptables -A SYN-FLOOD -m limit --limit 1/s --limit-burst 5 -j RETURN
iptables -A SYN-FLOOD -j DROP
#Verifing that new TCP connections are SYN packets
iptables -A INPUT -i $RED_INTERFACE -p tcp ! --syn -m state --state NEW -j DROP


############################################
# SPOOFING
############################################
#Anti-spoofing, this may not be needed due to the kernel flags set....
#However you never know if there is a bug in the TCP/IP stack
#DROP spoofed packets pretending to be from you IP address
iptables -A INPUT -i $RED_INTERFACE -s $RED_IPADDRESS -j DROP
#DROP packets claiming to be from a CLASS A private network
#iptables -A INPUT -i $RED_INTERFACE -s 10.0.0.0/8 -j DROP
#DROP packets claiming to be from a CLASS B private network
#iptables -A INPUT -i $RED_INTERFACE -s 172.16.0.0/12 -j DROP
#DROP packets claiming to be from a CLASS C private network
#iptables -A INPUT -i $RED_INTERFACE -s 192.168.0.0/16 -j DROP
#DROP packets claiming to be from a CLASS D mulitcast address
#iptables -A INPUT -i $RED_INTERFACE -s 224.0.0.0/4 -j DROP
#DROP packets claiming to be from CLASS E reserved IP address
#iptables -A INPUT -i $RED_INTERFACE -s 240.0.0.0/4 -j DROP
#Refuse packets claiming to be the loopback
#iptables -A INPUT -i $RED_INTERFACE -s 127.0.0.0/8 -j DROP
#Refuse malformed broadcast packets
BROADCAST_SRC="0.0.0.0"
BROADCAST_DEST="255.255.255.255"
iptables -A INPUT -i $RED_INTERFACE -s $BROADCAST_DEST -j DROP
iptables -A INPUT -i $RED_INTERFACE -d $BROADCAST_SRC  -j DROP
#A packet will never legitimately orginate from address 255.255.255.255.
#Address 0.0.0.0 is reserved for use as a broadcast source address.  Netfilers convertion
#of specifying a match on any address, any/0, 0.0.0.0/0, or 0.0.0.0/0.0.0.0, doesn't
#match the broadcast source address.  The reason is that a broadcast packet has bit set
#in the Layer 2 frame header indicating that it's a broadcast packet destined for all
#interfaces on the network, rather than a point-to-point, unicast packet destined for a
#particular destination.  Broadcast packets are handled diffently than nonbroadcast packets.
#There is no legitimate nonbroadcast IP address 0.0.0.0

############################################
# GREEN SIDE INTERFACES
############################################
#We want to allow unlimited traffic from Green interfaces
for ip in $GREEN_INTERFACE; do
        iptables -A INPUT -i $ip -j ACCEPT
done


############################################
# ICMP
############################################
#To see the names allowed use the command iptables -p icmp -h
#For an updated  and full list of
#ICMP type numbers  go to http://www.iana.org/
#(last updated 27 January 2005)
#Type    Name                                    Reference
#----    -------------------------               ---------
#  0     Echo Reply                               [RFC792]
#  1     Unassigned                                  [JBP]
#  2     Unassigned                                  [JBP]
#  3     Destination Unreachable                  [RFC792]
#  4     Source Quench                            [RFC792]
#  5     Redirect                                 [RFC792]
#  6     Alternate Host Address                      [JBP]
#  7     Unassigned                                  [JBP]
#  8     Echo                                     [RFC792]
#  9     Router Advertisement                    [RFC1256]
# 10     Router Solicitation                     [RFC1256]
# 11     Time Exceeded                            [RFC792]
# 12     Parameter Problem                        [RFC792]
# 13     Timestamp                                [RFC792]
# 14     Timestamp Reply                          [RFC792]
# 15     Information Request                      [RFC792]
# 16     Information Reply                        [RFC792]
# 17     Address Mask Request                     [RFC950]
# 18     Address Mask Reply                       [RFC950]
# 19     Reserved (for Security)                    [Solo]
# 20-29  Reserved (for Robustness Experiment)        [ZSu]
# 30     Traceroute                              [RFC1393]
# 31     Datagram Conversion Error               [RFC1475]
# 32     Mobile Host Redirect              [David Johnson]
# 33     IPv6 Where-Are-You                 [Bill Simpson]
# 34     IPv6 I-Am-Here                     [Bill Simpson]
# 35     Mobile Registration Request        [Bill Simpson]
# 36     Mobile Registration Reply          [Bill Simpson]
# 37     Domain Name Request                     [RFC1788]
# 38     Domain Name Reply                       [RFC1788]
# 39     SKIP                                    [Markson]
# 40     Photuris                                [RFC2521]
############################################
iptables -N ICMP_IN
iptables -A INPUT -i $RED_INTERFACE -p icmp -j ICMP_IN 
#ALLOW IN
iptables -A ICMP_IN -p icmp --icmp-type 0 -j ACCEPT
iptables -A ICMP_IN -p icmp --icmp-type 3 -j ACCEPT
iptables -A ICMP_IN -p icmp --icmp-type 4 -j ACCEPT
if [ $PING = "ON" ]; then
        iptables -A ICMP_IN -p icmp --icmp-type 8 -m limit --limit 2/s -j ACCEPT
        iptables -A ICMP_IN -p icmp --icmp-type 8 -j LOG --log-prefix "IPTABLE ICMP-TYPE 8 EXCESSIVE"
        iptables -A ICMP_IN -p icmp --icmp-type 8 -j DROP
else  
        iptables -A ICMP_IN -p icmp --icmp-type 8 -j DROP
fi
iptables -A ICMP_IN -p icmp --icmp-type 11 -j ACCEPT
iptables -A ICMP_IN -p icmp --icmp-type 12 -j ACCEPT
iptables -A ICMP_IN -p icmp --icmp-type 14 -j ACCEPT
iptables -A ICMP_IN -p icmp --icmp-type 16 -j ACCEPT
#All other that are not allow are loged and then drop
iptables -A ICMP_IN -m limit --limit 2/s -j LOG --log-prefix "IPTABLE ICMP BAD TYPE INPUT"
iptables -A ICMP_IN -j DROP


############################################
# USER DEFINED RULES
############################################
#Seting up allowd states (Allow in what we sent out)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state INVALID -j LOG --log-prefix "IPTABLE INVAID IN STATE:"
iptables -A INPUT -m state --state INVALID -j DROP
#USER DEFINED RULES
if [ -f /etc/firewall/user_rules ]; then
        sh /etc/firewall/user_rules $RED_INTERFACE 
fi

############################################
# ENABLE NAT SUPPORT
############################################
#iptables -t nat -A POSTROUTING -o $RED_INTERFACE -j MASQUERADE

############################################
# LOGGING
############################################
#Any udp not already allowed is logged and then dropped. 
#iptables -A INPUT  -i $RED_INTERFACE -p udp -j LOG --log-prefix "IPTABLES BAD UDP-IN" 
iptables -A INPUT  -i $RED_INTERFACE -p udp -j DROP 
#Any tcp not already allowed is logged and then dropped. 
iptables -A INPUT  -i $RED_INTERFACE -p tcp -m limit --limit 1/m --limit-burst 5 -j LOG --log-prefix "IPTABLE BAD TCP-IN" 
iptables -A INPUT  -i $RED_INTERFACE -p tcp -j DROP 

