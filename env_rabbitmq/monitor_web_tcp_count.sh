#!/bin/bash

## 监控来自WEB服务器的连接池请求
## 计划任务
## * * * * * /bin/bash /root/devops/env_rabbitmq/monitor_web_tcp_count.sh

logFile=/tmp/rabbitmq_amqproxy_tcpcount.log
tcpCount248="`date '+%Y-%m-%d %H:%M:%S'`    9988<-172.16.100.248 connect count: `netstat -tunlpa  | grep 9988 | grep 172.16.100.248 | wc -l`"
tcpCount240="`date '+%Y-%m-%d %H:%M:%S'`    9988<-172.16.100.240 connect count: `netstat -tunlpa  | grep 9988 | grep 172.16.100.240 | wc -l`"
tcpCount241="`date '+%Y-%m-%d %H:%M:%S'`    9988<-172.16.100.241 connect count: `netstat -tunlpa  | grep 9988 | grep 172.16.100.241 | wc -l`"
echo $tcpCount248 >> ${logFile}
echo $tcpCount240 >> ${logFile}
echo $tcpCount241 >> ${logFile}
