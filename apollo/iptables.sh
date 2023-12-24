#!/bin/bash

##portal
iptables -A INPUT  -p tcp --dport 10000 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10000 -j ACCEPT

##config local
iptables -A INPUT  -p tcp --dport 10001 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10001 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10002 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10002 -j ACCEPT

##config dev
iptables -A INPUT  -p tcp --dport 10011 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10011 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10012 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10012 -j ACCEPT

##config fat
iptables -A INPUT  -p tcp --dport 10021 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10021 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10022 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10022 -j ACCEPT

##config lpt
iptables -A INPUT  -p tcp --dport 10031 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10031 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10032 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10032 -j ACCEPT

##config uat
iptables -A INPUT  -p tcp --dport 10041 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10041 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10042 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10042 -j ACCEPT

##config pro
iptables -A INPUT  -p tcp --dport 10051 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10051 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10052 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10052 -j ACCEPT

## 测试服务器 172.16.100.188     docker apollo_net网段 172.17.0.1/24
#ip route add 172.17.1.0/24 via 172.16.100.200
#iptables -P INPUT ACCEPT
#iptables -P FORWARD ACCEPT
#
## 正式服务器 172.16.100.200     docker apollo_net网段 172.17.1.1/24
#ip route add 172.17.0.0/24 via 172.16.100.188
#iptables -P INPUT ACCEPT
#iptables -P FORWARD ACCEPT

