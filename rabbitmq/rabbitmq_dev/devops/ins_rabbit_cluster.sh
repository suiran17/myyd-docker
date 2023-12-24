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
cp -R rabbitmq_server-3.7.14   /data/server/rabbitmq_server-3.7.14-1
cp -R rabbitmq_server-3.7.14   /data/server/rabbitmq_server-3.7.14-2
cp -R rabbitmq_server-3.7.14   /data/server/rabbitmq_server-3.7.14-3
cp -R rabbitmq_server-3.7.14   /data/server/rabbitmq_server-3.7.14-4
cp -R rabbitmq_server-3.7.14   /data/server/rabbitmq_server-3.7.14-5

echo "软件包复制完成"

#复制配置文件 etc里已有 .erlang.cookie 文件，所以不用单独配置
cp -R etc /data/server/rabbitmq_server-3.7.14-0/
cp -R etc /data/server/rabbitmq_server-3.7.14-1/
cp -R etc /data/server/rabbitmq_server-3.7.14-2/
cp -R etc /data/server/rabbitmq_server-3.7.14-3/
cp -R etc /data/server/rabbitmq_server-3.7.14-4/
cp -R etc /data/server/rabbitmq_server-3.7.14-5/

echo "配置复制完成"

#配置 .erlang.cookie 权限
chmod 400 /data/server/rabbitmq_server-3.7.14-0/etc/.erlang.cookie
chmod 400 /data/server/rabbitmq_server-3.7.14-1/etc/.erlang.cookie
chmod 400 /data/server/rabbitmq_server-3.7.14-2/etc/.erlang.cookie
chmod 400 /data/server/rabbitmq_server-3.7.14-3/etc/.erlang.cookie
chmod 400 /data/server/rabbitmq_server-3.7.14-4/etc/.erlang.cookie
chmod 400 /data/server/rabbitmq_server-3.7.14-5/etc/.erlang.cookie

echo ".erlang.cookie 更改权限完成"

#配置每个节点的信息
sed -i 's|__nodename__|rabbit0@jwlocal0|g'                         /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5670|g'                                    /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15670|g'                             /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61610|g'                                  /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1880|g'                                    /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/data/server/rabbitmq_server-3.7.14-0/etc/|g'   /data/server/rabbitmq_server-3.7.14-0/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|rabbit1@jwlocal1|g'                         /data/server/rabbitmq_server-3.7.14-1/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5671|g'                                    /data/server/rabbitmq_server-3.7.14-1/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15671|g'                             /data/server/rabbitmq_server-3.7.14-1/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61611|g'                                  /data/server/rabbitmq_server-3.7.14-1/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1881|g'                                    /data/server/rabbitmq_server-3.7.14-1/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/data/server/rabbitmq_server-3.7.14-1/etc/|g'   /data/server/rabbitmq_server-3.7.14-1/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|rabbit2@jwlocal0|g'                         /data/server/rabbitmq_server-3.7.14-2/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5672|g'                                    /data/server/rabbitmq_server-3.7.14-2/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15672|g'                             /data/server/rabbitmq_server-3.7.14-2/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61612|g'                                  /data/server/rabbitmq_server-3.7.14-2/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1882|g'                                    /data/server/rabbitmq_server-3.7.14-2/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/data/server/rabbitmq_server-3.7.14-2/etc/|g'   /data/server/rabbitmq_server-3.7.14-2/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|rabbit3@jwlocal0|g'                         /data/server/rabbitmq_server-3.7.14-3/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5673|g'                                    /data/server/rabbitmq_server-3.7.14-3/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15673|g'                             /data/server/rabbitmq_server-3.7.14-3/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61613|g'                                  /data/server/rabbitmq_server-3.7.14-3/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1883|g'                                    /data/server/rabbitmq_server-3.7.14-3/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/data/server/rabbitmq_server-3.7.14-3/etc/|g'   /data/server/rabbitmq_server-3.7.14-3/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|rabbit4@jwlocal1|g'                         /data/server/rabbitmq_server-3.7.14-4/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5674|g'                                    /data/server/rabbitmq_server-3.7.14-4/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15674|g'                             /data/server/rabbitmq_server-3.7.14-4/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61614|g'                                  /data/server/rabbitmq_server-3.7.14-4/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1884|g'                                    /data/server/rabbitmq_server-3.7.14-4/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/data/server/rabbitmq_server-3.7.14-4/etc/|g'   /data/server/rabbitmq_server-3.7.14-4/etc/rabbitmq/rabbitmq-env.conf

sed -i 's|__nodename__|rabbit5@jwlocal1|g'                         /data/server/rabbitmq_server-3.7.14-5/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__node_port__|5675|g'                                    /data/server/rabbitmq_server-3.7.14-5/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__management_port__|15675|g'                             /data/server/rabbitmq_server-3.7.14-5/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__stomp_port__|61615|g'                                  /data/server/rabbitmq_server-3.7.14-5/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__mqtt_port__|1885|g'                                    /data/server/rabbitmq_server-3.7.14-5/etc/rabbitmq/rabbitmq-env.conf
sed -i 's|__home__|/data/server/rabbitmq_server-3.7.14-5/etc/|g'   /data/server/rabbitmq_server-3.7.14-5/etc/rabbitmq/rabbitmq-env.conf

echo "节点配置完成"
cd -
