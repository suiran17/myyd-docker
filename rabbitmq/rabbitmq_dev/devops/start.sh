#!/bin/bash

######################################### 注意 #########################################
#权限是与节点相关的，节点名定好后就不能修改了
######################################### 注意 #########################################
# https://www.cnblogs.com/xishuai/p/rabbitmq-cluster.html

softDir="/data/soft/rabbitmq/"

### 启动 rabbitmq 集群
#启动 rabbit0@jwlocal0 节点
/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmq-server -detached

#启动 rabbit1@jwlocal1 节点, 并加入rabbit0 集群
/data/server/rabbitmq_server-3.7.14-1/sbin/rabbitmq-server -detached
/data/server/rabbitmq_server-3.7.14-1/sbin/rabbitmqctl stop_app
/data/server/rabbitmq_server-3.7.14-1/sbin/rabbitmqctl reset
/data/server/rabbitmq_server-3.7.14-1/sbin/rabbitmqctl join_cluster rabbit0@jwlocal0 --disc
/data/server/rabbitmq_server-3.7.14-1/sbin/rabbitmqctl start_app

#启动 rabbit2@jwlocal0 节点, 并加入rabbitmq0 集群
/data/server/rabbitmq_server-3.7.14-2/sbin/rabbitmq-server -detached
/data/server/rabbitmq_server-3.7.14-2/sbin/rabbitmqctl stop_app
/data/server/rabbitmq_server-3.7.14-2/sbin/rabbitmqctl reset
/data/server/rabbitmq_server-3.7.14-2/sbin/rabbitmqctl join_cluster rabbit0@jwlocal0 --ram
/data/server/rabbitmq_server-3.7.14-2/sbin/rabbitmqctl start_app

#启动 rabbit3@jwlocal0 节点, 并加入rabbitmq0 集群
/data/server/rabbitmq_server-3.7.14-3/sbin/rabbitmq-server -detached
/data/server/rabbitmq_server-3.7.14-3/sbin/rabbitmqctl stop_app
/data/server/rabbitmq_server-3.7.14-3/sbin/rabbitmqctl reset
/data/server/rabbitmq_server-3.7.14-3/sbin/rabbitmqctl join_cluster rabbit0@jwlocal0 --ram
/data/server/rabbitmq_server-3.7.14-3/sbin/rabbitmqctl start_app

#启动 rabbit4@jwlocal1 节点, 并加入rabbit0 集群
/data/server/rabbitmq_server-3.7.14-4/sbin/rabbitmq-server -detached
/data/server/rabbitmq_server-3.7.14-4/sbin/rabbitmqctl stop_app
/data/server/rabbitmq_server-3.7.14-4/sbin/rabbitmqctl reset
/data/server/rabbitmq_server-3.7.14-4/sbin/rabbitmqctl join_cluster rabbit0@jwlocal0 --ram
/data/server/rabbitmq_server-3.7.14-4/sbin/rabbitmqctl start_app

#启动 rabbit5@jwlocal1 节点, 并加入rabbit0 集群
/data/server/rabbitmq_server-3.7.14-5/sbin/rabbitmq-server -detached
/data/server/rabbitmq_server-3.7.14-5/sbin/rabbitmqctl stop_app
/data/server/rabbitmq_server-3.7.14-5/sbin/rabbitmqctl reset
/data/server/rabbitmq_server-3.7.14-5/sbin/rabbitmqctl join_cluster rabbit0@jwlocal0 --ram
/data/server/rabbitmq_server-3.7.14-5/sbin/rabbitmqctl start_app

cd -
