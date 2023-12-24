#!/bin/bash

######################################### 注意 #########################################
#权限是与节点相关的，节点名定好后就不能修改了
######################################### 注意 #########################################
# https://www.cnblogs.com/xishuai/p/rabbitmq-cluster.html

softDir="/data/soft/rabbitmq/"

### 安装 rabbitmq
cd ${softDir}
#wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.14/rabbitmq-server-generic-unix-3.7.14.tar.xz
##tar -xvf rabbitmq-server-generic-unix-3.7.14.tar.xz
tar -xf rabbitmq-server-generic-unix-3.7.14.tar.xz

cp -R rabbitmq_server-3.7.14   /data/server/rabbitmq_server-3.7.14-0

echo "软件包复制完成"

#复制配置文件 etc里已有 .erlang.cookie 文件，所以不用单独配置
cp -R etc /data/server/rabbitmq_server-3.7.14-0/

echo "配置复制完成"

#配置 .erlang.cookie 权限
chmod 400 /data/server/rabbitmq_server-3.7.14-0/etc/.erlang.cookie

echo ".erlang.cookie 更改权限完成"

#配置每个节点的信息
sed -i 's|__nodename__|rabbit0@jwlocal0|g'                         /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5670|g'                                    /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15670|g'                             /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61610|g'                                  /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1880|g'                                    /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/data/server/rabbitmq_server-3.7.14-0/etc/|g'   /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf

echo "节点配置完成"
cd -
