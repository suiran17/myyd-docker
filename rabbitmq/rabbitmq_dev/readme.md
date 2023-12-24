### 安装rabbit


```
安装时会用到安装包，如下：
# 这是 erlang 源码包
otp_src_21.3.tar.gz  

#这是rabbitmq 二进程包
rabbitmq-server-generic-unix-3.7.14.tar.xz


安装过程中有很多的配置，配置的模板在 etc 文件夹里, 安装脚本会自动读取

脚本中的安装路径，请自行修改
```

1. 安装 erlang
见脚本 devops/ins_erlang.sh

2. 安装 rabbitmq(二进程包)
见脚本 devops/ins_rabbit.sh
配置请在脚本中修改

3. 安装 rabbitmq cluster(二进程包)
见脚本 devops/ins_rabbit_cluster.sh
配置请在脚本中修改

3. 启动 rabbitmq
见脚本 devops/start.sh

4. 停止 rabbitmq
见脚本 devops/stop.sh

5. 添加用户并授权
见脚本 devops/adduser.sh

6. 负载均衡 nginx 版
nginx 配置文件见 devops/nginx_rabbit.conf

