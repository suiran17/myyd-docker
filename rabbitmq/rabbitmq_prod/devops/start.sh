#!/bin/bash

######################################### 注意 #########################################
#权限是与节点相关的，节点名定好后就不能修改了
######################################### 注意 #########################################
# https://www.cnblogs.com/xishuai/p/rabbitmq-cluster.html

softDir="/data/soft/rabbitmq/"

### 启动 rabbitmq 集群
#################      集群启动时，有顺序，不要轻易改动 #####################################
#-----------------------启动 disc[硬盘] 节点-------------------------------------------------
#启动 node00@rabbitmq0 disc节点
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmq-server -detached

#启动 node10@rabbitmq1 disc节点, 并加入 node00@rabbitmq0 集群
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmq-server -detached
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl stop_app
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl reset
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl join_cluster node00@rabbitmq0 --ram
/usr/local/rabbitmq_server-3.7.14-10/sbin/rabbitmqctl start_app

#-----------------------启动 ram[内存] 节点-------------------------------------------------
#启动 node01@rabbitmq1 ram节点, 并加入 node00@rabbitmq0 集群
/usr/local/rabbitmq_server-3.7.14-01/sbin/rabbitmq-server -detached
/usr/local/rabbitmq_server-3.7.14-01/sbin/rabbitmqctl stop_app
/usr/local/rabbitmq_server-3.7.14-01/sbin/rabbitmqctl reset
/usr/local/rabbitmq_server-3.7.14-01/sbin/rabbitmqctl join_cluster node00@rabbitmq0 --disc
/usr/local/rabbitmq_server-3.7.14-01/sbin/rabbitmqctl start_app

#启动 node02@rabbitmq0 ram节点, 并加入 node00@rabbitmq0 集群
/usr/local/rabbitmq_server-3.7.14-02/sbin/rabbitmq-server -detached
/usr/local/rabbitmq_server-3.7.14-02/sbin/rabbitmqctl stop_app
/usr/local/rabbitmq_server-3.7.14-02/sbin/rabbitmqctl reset
/usr/local/rabbitmq_server-3.7.14-02/sbin/rabbitmqctl join_cluster node00@rabbitmq0 --ram
/usr/local/rabbitmq_server-3.7.14-02/sbin/rabbitmqctl start_app

#启动 node11@rabbitmq1 ram节点, 并加入 node00@rabbitmq0 集群
/usr/local/rabbitmq_server-3.7.14-11/sbin/rabbitmq-server -detached
/usr/local/rabbitmq_server-3.7.14-11/sbin/rabbitmqctl stop_app
/usr/local/rabbitmq_server-3.7.14-11/sbin/rabbitmqctl reset
/usr/local/rabbitmq_server-3.7.14-11/sbin/rabbitmqctl join_cluster node00@rabbitmq0 --ram
/usr/local/rabbitmq_server-3.7.14-11/sbin/rabbitmqctl start_app

#启动 node12@rabbitmq1 ram节点, 并加入 node00@rabbitmq0 集群
/usr/local/rabbitmq_server-3.7.14-12/sbin/rabbitmq-server -detached
/usr/local/rabbitmq_server-3.7.14-12/sbin/rabbitmqctl stop_app
/usr/local/rabbitmq_server-3.7.14-12/sbin/rabbitmqctl reset
/usr/local/rabbitmq_server-3.7.14-12/sbin/rabbitmqctl join_cluster node00@rabbitmq0 --ram
/usr/local/rabbitmq_server-3.7.14-12/sbin/rabbitmqctl start_app

cd -
