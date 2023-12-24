#!/bin/bash

######################################### 注意 #########################################
#权限是与节点相关的，节点名定好后就不能修改了
######################################### 注意 #########################################
# https://www.cnblogs.com/xishuai/p/rabbitmq-cluster.html

softDir="/data/soft/rabbitmq/"

### 安装 rabbitmq
cd ${softDir}
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.14/rabbitmq-server-generic-unix-3.7.14.tar.xz
tar -xvf rabbitmq-server-generic-unix-3.7.14.tar.xz

cp -R rabbitmq_server-3.7.14   /usr/local/rabbitmq_server-3.7.14-00
cp -R rabbitmq_server-3.7.14   /usr/local/rabbitmq_server-3.7.14-01
cp -R rabbitmq_server-3.7.14   /usr/local/rabbitmq_server-3.7.14-02
cp -R rabbitmq_server-3.7.14   /usr/local/rabbitmq_server-3.7.14-10
cp -R rabbitmq_server-3.7.14   /usr/local/rabbitmq_server-3.7.14-11
cp -R rabbitmq_server-3.7.14   /usr/local/rabbitmq_server-3.7.14-12

echo "软件包复制完成"

cd - 

#复制配置文件 etc里已有 .erlang.cookie 文件，所以不用单独配置
cp -R etc /usr/local/rabbitmq_server-3.7.14-00/
cp -R etc /usr/local/rabbitmq_server-3.7.14-01/
cp -R etc /usr/local/rabbitmq_server-3.7.14-02/
cp -R etc /usr/local/rabbitmq_server-3.7.14-10/
cp -R etc /usr/local/rabbitmq_server-3.7.14-11/
cp -R etc /usr/local/rabbitmq_server-3.7.14-12/

echo "配置复制完成"

#配置 .erlang.cookie 权限
chmod 400 /usr/local/rabbitmq_server-3.7.14-00/etc/.erlang.cookie
chmod 400 /usr/local/rabbitmq_server-3.7.14-01/etc/.erlang.cookie
chmod 400 /usr/local/rabbitmq_server-3.7.14-02/etc/.erlang.cookie
chmod 400 /usr/local/rabbitmq_server-3.7.14-10/etc/.erlang.cookie
chmod 400 /usr/local/rabbitmq_server-3.7.14-11/etc/.erlang.cookie
chmod 400 /usr/local/rabbitmq_server-3.7.14-12/etc/.erlang.cookie

echo ".erlang.cookie 更改权限完成"

#配置每个节点的信息
sed -i 's|__nodename__|node00@rabbitmq0|g'                         /usr/local/rabbitmq_server-3.7.14-00/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5670|g'                                    /usr/local/rabbitmq_server-3.7.14-00/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15670|g'                             /usr/local/rabbitmq_server-3.7.14-00/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61610|g'                                  /usr/local/rabbitmq_server-3.7.14-00/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1880|g'                                    /usr/local/rabbitmq_server-3.7.14-00/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/usr/local/rabbitmq_server-3.7.14-00/etc/|g'    /usr/local/rabbitmq_server-3.7.14-00/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|node01@rabbitmq0|g'                         /usr/local/rabbitmq_server-3.7.14-01/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5671|g'                                    /usr/local/rabbitmq_server-3.7.14-01/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15671|g'                             /usr/local/rabbitmq_server-3.7.14-01/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61611|g'                                  /usr/local/rabbitmq_server-3.7.14-01/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1881|g'                                    /usr/local/rabbitmq_server-3.7.14-01/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/usr/local/rabbitmq_server-3.7.14-01/etc/|g'    /usr/local/rabbitmq_server-3.7.14-01/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|node02@rabbitmq0|g'                         /usr/local/rabbitmq_server-3.7.14-02/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5672|g'                                    /usr/local/rabbitmq_server-3.7.14-02/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15672|g'                             /usr/local/rabbitmq_server-3.7.14-02/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61612|g'                                  /usr/local/rabbitmq_server-3.7.14-02/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1882|g'                                    /usr/local/rabbitmq_server-3.7.14-02/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/usr/local/rabbitmq_server-3.7.14-02/etc/|g'    /usr/local/rabbitmq_server-3.7.14-02/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|node10@rabbitmq1|g'                         /usr/local/rabbitmq_server-3.7.14-10/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5670|g'                                    /usr/local/rabbitmq_server-3.7.14-10/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15670|g'                             /usr/local/rabbitmq_server-3.7.14-10/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61610|g'                                  /usr/local/rabbitmq_server-3.7.14-10/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1880|g'                                    /usr/local/rabbitmq_server-3.7.14-10/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/usr/local/rabbitmq_server-3.7.14-10/etc/|g'    /usr/local/rabbitmq_server-3.7.14-10/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|node11@rabbitmq1|g'                         /usr/local/rabbitmq_server-3.7.14-11/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5671|g'                                    /usr/local/rabbitmq_server-3.7.14-11/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15671|g'                             /usr/local/rabbitmq_server-3.7.14-11/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61611|g'                                  /usr/local/rabbitmq_server-3.7.14-11/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1881|g'                                    /usr/local/rabbitmq_server-3.7.14-11/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/usr/local/rabbitmq_server-3.7.14-11/etc/|g'    /usr/local/rabbitmq_server-3.7.14-11/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|node12@rabbitmq1|g'                         /usr/local/rabbitmq_server-3.7.14-12/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5672|g'                                    /usr/local/rabbitmq_server-3.7.14-12/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15672|g'                             /usr/local/rabbitmq_server-3.7.14-12/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61612|g'                                  /usr/local/rabbitmq_server-3.7.14-12/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1882|g'                                    /usr/local/rabbitmq_server-3.7.14-12/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/usr/local/rabbitmq_server-3.7.14-12/etc/|g'    /usr/local/rabbitmq_server-3.7.14-12/etc/rabbitmq/rabbitmq-env.conf

echo "节点配置完成"
cd -
