### 预发布环境说明

环境是基于docker构建的，在部署前要保证先有docker环境
因为配置hosts麻烦，在环境中使用了内部DNS 172.16.100.115
测试代码发布系统部署在 172.16.100.115
docker镜像存储于内部的仓库

#### 随机启动, /etc/rc.d/rc.local
```
## /etc/rc.d/rc.local 默认是没有可执行权限的，心须加上可执行权限
chmod +x /etc/rc.d/rc.local

vim /etc/rc.d/rc.local 

## 随机启动
/data/devops/env_test/machine_start.sh
```

#### 安装docker
```
make docker_install
```

#### 启动必要的项目
```
make init_dir

make jenkins_start

make postgres_start
make mysql_start
make portainer_start

make kong_start
make konga_start
make php_start
make nginx_start
make apollo_config_start
```

#### 开放必要的端口
```
iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
iptables -A INPUT -p tcp --dport 8001 -j ACCEPT
iptables -A INPUT -p tcp --dport 8443 -j ACCEPT
iptables -A INPUT -p tcp --dport 8444 -j ACCEPT
```

#### 各项目的端口使用情况
```
service_disp 7970
```

#### 内部DNS
```
环境部曙使用了内部DNS 172.16.100.115
宿主机配置 /etc/resolv.conf
docker 配置 /etc/docker/daemon.json
```

#### konga第一次使用时，需要初始化数据
```
docker run --rm docker.nodevops.cn/web/konga -c prepare -a postgres -u 'postgresql://konga:konga123@172.16.100.200:5432/konga'
```

