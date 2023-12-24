#进入rabbitmq1容器，重新初始化一下，如果是新安装则reset可以忽略重置。
docker exec -it rabbitmq1   rabbitmqctl stop_app
#docker exec -it rabbitmq1   rabbitmqctl reset
docker exec -it rabbitmq1   rabbitmqctl start_app

#进入rabbitmq2容器，重新初始化一下，将02节点加入到集群中
docker exec -it rabbitmq2   rabbitmqctl stop_app
docker exec -it rabbitmq2   rabbitmqctl reset
docker exec -it rabbitmq2   rabbitmqctl join_cluster --ram node01@rabbitmq1 #参数“--ram”表示设置为内存节点，忽略该参数默认为磁盘节点。
docker exec -it rabbitmq2   rabbitmqctl start_app

#进入rabbitmq3容器，重新初始化一下，将03节点加入到集群中
docker exec -it rabbitmq3   rabbitmqctl stop_app
docker exec -it rabbitmq3   rabbitmqctl reset
docker exec -it rabbitmq3   rabbitmqctl join_cluster node01@rabbitmq1 #参数“--ram”表示设置为内存节点，忽略该参数默认为磁盘节点。
docker exec -it rabbitmq3   rabbitmqctl start_app

#进入rabbitmq4容器，重新初始化一下，将04节点加入到集群中
docker exec -it rabbitmq4   rabbitmqctl stop_app
docker exec -it rabbitmq4   rabbitmqctl reset
docker exec -it rabbitmq4   rabbitmqctl join_cluster --ram node01@rabbitmq1 #参数“--ram”表示设置为内存节点，忽略该参数默认为磁盘节点。
docker exec -it rabbitmq4   rabbitmqctl start_app
