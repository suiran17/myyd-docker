# Example rabbitmq-env.conf file entries. Note that the variables
# do not have the RABBITMQ_ prefix.

# 自定义节点名
# 格式: 节点名@主机名，如：rabbit@jwlocal
# 节点名, 自定义的名字, 如rabbit, 集群中结名名不能重复
# 主机名，有两种方式设置
#   1. 默认取系统的hostname, 但不推荐，因为日常运维中，可能会更改hostname, 这会导致 rabbitmq 不可用
#   2. 自定义，要在 /etc/hosts 绑定，推荐
#       因为日常运维中，被改动的机率小，即使机器迁移，只改host就可以了，不影响授权
#       /etc/hosts 绑定如下：
#       127.0.0.1 jwlocal
#
# 注意：节点名与用户授权是相关的，不能随意更改
NODENAME=__nodename__

## .erlang.cookie 路径
# yum安装                            默认在 /var/lib/rabbitmq/.erlang.cookie 
# rabbitmq-server-generic-unix 安装  默认在 $HOME/.erlang.cookie 
# 这里自定义到安装目录的 etc文件内，方便日后的维护, 集群部署时，不易弄混
HOME=__home__

#定义节点所使用的端口
NODE_PORT=__node_port__
SERVER_START_ARGS="-rabbitmq_management listener [{port,__management_port__}] -rabbitmq_stomp tcp_listeners [__stomp_port__] -rabbitmq_mqtt tcp_listeners [__mqtt_port__]"

# Specifies new style config file location
# 默认 $RABBITMQ_HOME/etc/rabbitmq/rabbitmq.conf
#CONFIG_FILE=etc/rabbitmq/rabbitmq.conf

# Specifies advanced config file location
# 默认 $RABBITMQ_HOME/etc/rabbitmq/advanced.config
#ADVANCED_CONFIG_FILE=etc/rabbitmq/advanced.config

