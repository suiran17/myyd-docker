#!/bin/bash

######################################### 注意 #########################################
# 添加用户，在集群的一个节点上执行即可
######################################### 注意 #########################################
# 

user="tester"
pass="tester"
utag="administrator"

##节点添加用户
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl add_user      -n node00@rabbitmq0 ${user} ${pass}

##设用用户权限
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl set_user_tags -n node00@rabbitmq0 ${user} ${utag}
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl set_user_tags -n node01@rabbitmq0 ${user} ${utag}
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl set_user_tags -n node02@rabbitmq0 ${user} ${utag}
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl set_user_tags -n node10@rabbitmq1 ${user} ${utag}
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl set_user_tags -n node11@rabbitmq1 ${user} ${utag}
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl set_user_tags -n node12@rabbitmq1 ${user} ${utag}

#设置vhost权限
/usr/local/rabbitmq_server-3.7.14-00/sbin/rabbitmqctl set_permissions -p / ${user} ".*" ".*" ".*"

cd -
