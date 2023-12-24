#!/bin/bash

######################################### 注意 #########################################
# stop_app  表示终止应用，但是Erlang节点还在运行，用在需要RabbitMQ应用被停止的管理行为之前，例如 reset
# reset     表示恢复节点为原始状态，从cluster中删除节点信息，从管理数据库中删除所有数据, 执行前要先执行过 stop_app
# stop      表示stop 在RabbitMQ服务器上运行的一个Erlang 节点
######################################### 注意 #########################################

#################      集群顺序时，有顺序，不要轻易改动 #####################################
################## 以下是 ram 节点 #################################################

## node11@rabbitmq1 ram节点
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl -n node11@rabbitmq1 stop_app
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl -n node11@rabbitmq1 stop

## node12@rabbitmq1 ram节点
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl -n node12@rabbitmq1 stop_app
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl -n node12@rabbitmq1 stop

################## 以下是 disc 节点 #################################################
#最后停 disc 节点, 不能执行 reset 操作

## node10@rabbitmq0 disc节点
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl -n node10@rabbitmq1 stop_app
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl -n node10@rabbitmq1 stop

cd -
