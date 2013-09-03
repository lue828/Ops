#!/bin/bash
#
# The interface that connect Internet

# echo
echo "Enable IP Forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "Starting iptables rules..."

IFACE="eth0"

# include module
modprobe ip_tables
modprobe iptable_nat
modprobe ip_nat_ftp
modprobe ip_nat_irc
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_conntrack_irc
modprobe ipt_MASQUERADE


# init
iptables -F 
iptables -X
iptables -Z
iptables -F -t nat
iptables -X -t nat
iptables -Z -t nat

iptables -X -t mangle

# drop all
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT


iptables -A INPUT -f -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -m limit --limit 20/sec --limit-burst 200 -j ACCEPT

iptables -A INPUT -p icmp -m limit --limit 12/min --limit-burst 2 -j DROP

iptables -A FORWARD -f -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -m limit --limit 20/sec --limit-burst 200 -j ACCEPT


# open ports
iptables -A INPUT -p tcp -j LOG --log-prefix "IPTABLES TCP-IN: "
iptables -A INPUT -i $IFACE -p tcp --dport 21 -j ACCEPT            #FTP
iptables -A INPUT -i $IFACE -p tcp --dport 22 -j ACCEPT            #SSH
iptables -A INPUT -i $IFACE -p tcp --dport 25 -j ACCEPT            #Mail
iptables -A INPUT -i $IFACE -p tcp --dport 53 -j ACCEPT            #DNS TCP
iptables -A INPUT -i $IFACE -p udp --dport 53 -j ACCEPT            #DNS UDP
iptables -A INPUT -i $IFACE -p tcp --dport 80 -j ACCEPT            #Httpd
iptables -A INPUT -i $IFACE -p tcp --dport 3306 -j ACCEPT          #MySQL
iptables -A INPUT -i $IFACE -p tcp --dport 5672 -j ACCEPT          #Rabbitmq


# close ports
iptables -I INPUT -p udp --dport 69 -j DROP
iptables -I INPUT -p tcp --dport 135 -j DROP
iptables -I INPUT -p udp --dport 135 -j DROP
iptables -I INPUT -p tcp --dport 136 -j DROP
iptables -I INPUT -p udp --dport 136 -j DROP
iptables -I INPUT -p tcp --dport 137 -j DROP
iptables -I INPUT -p udp --dport 137 -j DROP
iptables -I INPUT -p tcp --dport 138 -j DROP
iptables -I INPUT -p udp --dport 138 -j DROP
iptables -I INPUT -p tcp --dport 139 -j DROP
iptables -I INPUT -p udp --dport 139 -j DROP
iptables -I INPUT -p tcp --dport 445 -j DROP
iptables -I INPUT -p udp --dport 445 -j DROP
iptables -I INPUT -p tcp --dport 593 -j DROP
iptables -I INPUT -p udp --dport 593 -j DROP
iptables -I INPUT -p tcp --dport 1068 -j DROP
iptables -I INPUT -p udp --dport 1068 -j DROP
iptables -I INPUT -p tcp --dport 4444 -j DROP
iptables -I INPUT -p udp --dport 4444 -j DROP
iptables -I INPUT -p tcp --dport 5554 -j DROP
iptables -I INPUT -p tcp --dport 1434 -j DROP
iptables -I INPUT -p udp --dport 1434 -j DROP
iptables -I INPUT -p tcp --dport 2500 -j DROP
iptables -I INPUT -p tcp --dport 5800 -j DROP
iptables -I INPUT -p tcp --dport 5900 -j DROP
iptables -I INPUT -p tcp --dport 6346 -j DROP
iptables -I INPUT -p tcp --dport 6667 -j DROP
iptables -I INPUT -p tcp --dport 9393 -j DROP

iptables -A FORWARD -p tcp -j LOG --log-prefix "IPTABLES FORWARD: "
iptables -I FORWARD -p udp --dport 69 -j DROP
iptables -I FORWARD -p tcp --dport 135 -j DROP
iptables -I FORWARD -p udp --dport 135 -j DROP
iptables -I FORWARD -p tcp --dport 136 -j DROP
iptables -I FORWARD -p udp --dport 136 -j DROP
iptables -I FORWARD -p tcp --dport 137 -j DROP
iptables -I FORWARD -p udp --dport 137 -j DROP
iptables -I FORWARD -p tcp --dport 138 -j DROP
iptables -I FORWARD -p udp --dport 138 -j DROP
iptables -I FORWARD -p tcp --dport 139 -j DROP
iptables -I FORWARD -p udp --dport 139 -j DROP
iptables -I FORWARD -p tcp --dport 445 -j DROP
iptables -I FORWARD -p udp --dport 445 -j DROP
iptables -I FORWARD -p tcp --dport 593 -j DROP
iptables -I FORWARD -p udp --dport 593 -j DROP
iptables -I FORWARD -p tcp --dport 1068 -j DROP
iptables -I FORWARD -p udp --dport 1068 -j DROP
iptables -I FORWARD -p tcp --dport 4444 -j DROP
iptables -I FORWARD -p udp --dport 4444 -j DROP
iptables -I FORWARD -p tcp --dport 5554 -j DROP
iptables -I FORWARD -p tcp --dport 1434 -j DROP
iptables -I FORWARD -p udp --dport 1434 -j DROP
iptables -I FORWARD -p tcp --dport 2500 -j DROP
iptables -I FORWARD -p tcp --dport 5800 -j DROP
iptables -I FORWARD -p tcp --dport 5900 -j DROP
iptables -I FORWARD -p tcp --dport 6346 -j DROP
iptables -I FORWARD -p tcp --dport 6667 -j DROP
iptables -I FORWARD -p tcp --dport 9393 -j DROP

iptables -A INPUT -i $IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i $IFACE -m state --state NEW,INVALID -j DROP


# drop ping
iptables -A INPUT -p icmp -j DROP

# drop ip
#iptables -I INPUT -s 172.16.27.1 -j DROP


#############¼ÇÂ¼ÈÕÖ¾#############
#vim /etc/rsyslog.conf
## Save Iptables log to iptables.log
#kern.debug;kern.info                                    /var/log/iptables.log

# service rsyslog restart