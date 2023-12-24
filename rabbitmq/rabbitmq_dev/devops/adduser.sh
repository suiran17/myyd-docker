#!/bin/bash

######################################### 注意 #########################################
# 添加用户，在集群的一个节点上执行即可
######################################### 注意 #########################################
# 

user="tester"
pass="tester"
utag="administrator"

##节点添加用户
/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl add_user      -n rabbit0@jwlocal0 ${user} ${pass}

##设用用户权限
/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl set_user_tags -n rabbit0@jwlocal0 ${user} ${utag}
#/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl set_user_tags -n rabbit1@jwlocal1 ${user} ${utag}
#/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl set_user_tags -n rabbit2@jwlocal0 ${user} ${utag}
#/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl set_user_tags -n rabbit3@jwlocal0 ${user} ${utag}
#/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl set_user_tags -n rabbit4@jwlocal1 ${user} ${utag}
#/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl set_user_tags -n rabbit5@jwlocal1 ${user} ${utag}

#设置vhost权限
/data/server/rabbitmq_server-3.7.14-0/sbin/rabbitmqctl set_permissions -p / ${user} ".*" ".*" ".*"

cd -
