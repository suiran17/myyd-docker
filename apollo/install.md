### 线上部署

#### 规划说明

```
配置系统代码部署在两台服务器 
    172.16.100.200  线上环境， portal/pro/uat
    172.16.100.188  开发环境， lpt/fat/dev

配置系统数据库部署在现有的数据库上
    172.16.100.242  线上数据库 apollo_portal/apollo_config_pro/apollo_config_uat
    172.16.100.70   开发数据库 apollo_config_lpt/apollo_config_fat/apollo_config_dev

各服务端口配置：
172.16.100.200:10000 portal 管理后台, 所有环境共用

172.16.100.200:10051 pro    正式环境 config 服务端口
172.16.100.200:10052 pro    正式环境 admin  服务端口

172.16.100.200:10041 uat    预发布 config 服务端口
172.16.100.200:10042 uat    预发布 admin  服务端口

172.16.100.188:10031 lpt    压测环境 config 服务端口
172.16.100.188:10032 lpt    压测环境 admin  服务端口

172.16.100.188:10021 fat    功能测试 config 服务端口
172.16.100.188:10021 fat    功能测试 admin  服务端口

172.16.100.188:10011 dev    开发环境 config 服务端口
172.16.100.188:10011 dev    开发环境 admin  服务端口
```

#### docker 安装

```
#移除低版本的包
yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine

#安装相应工具
yum install -y yum-utils device-mapper-persistent-data lvm2

#添加docker仓库
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#安装docker
yum install docker-ce docker-ce-cli containerd.io

#添加服务
systemctl enable docker

#启动docker
#systemctl start docker
service docker start

#添加aliyun镜像
vim /etc/docker/daemon.json
{
    "registry-mirrors": ["https://mdmhrw1y.mirror.aliyuncs.com"]
}

#安装docker-compose
pip install --upgrade pip
pip install docker-compose
```

#### 编译镜像

```
#修改本次编译的版本
vim Makefile
APOLLO_VERSION=v0.0.5

#编译命令
make d_portal       编译 apollo_portal 镜像
make d_config_dev   编译 apollo_config_dev 镜像
make d_config_fat   编译 apollo_config_fat 镜像
make d_config_lpt   编译 apollo_config_lpt 镜像
make d_config_uat   编译 apollo_config_uat 镜像
make d_config_pro   编译 apollo_config_pro 镜像
make d_all          编译以上所有镜像

#编译 apollo 的 java 环境镜像, apollo 所有的程序编译均基于此镜像
#如果要进行java版本升级，记得修改 tag
make d_java
```

#### 开启端口

```
#在线上及测试环境开放如下端口

##portal
iptables -A INPUT  -p tcp --dport 10000 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10000 -j ACCEPT

##config local
iptables -A INPUT  -p tcp --dport 10001 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10001 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10002 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10002 -j ACCEPT

##config dev
iptables -A INPUT  -p tcp --dport 10011 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10011 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10012 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10012 -j ACCEPT

##config fat
iptables -A INPUT  -p tcp --dport 10021 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10021 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10022 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10022 -j ACCEPT

##config lpt
iptables -A INPUT  -p tcp --dport 10031 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10031 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10032 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10032 -j ACCEPT

##config uat
iptables -A INPUT  -p tcp --dport 10041 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10041 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10042 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10042 -j ACCEPT

##config pro
iptables -A INPUT  -p tcp --dport 10051 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10051 -j ACCEPT
iptables -A INPUT  -p tcp --dport 10052 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 10052 -j ACCEPT


# 测试环境执行
# 测试服务器 172.16.100.188     docker apollo_net网段 172.17.0.1/24
ip route add 172.17.1.0/24 via 172.16.100.200
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT

# 正式环境执行
# 正式服务器 172.16.100.200     docker apollo_net网段 172.17.1.1/24
ip route add 172.17.0.0/24 via 172.16.100.188
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
```

#### 启动/停止服务

```
#线上环境
cd /root/apollo/
#启动服务
docker-composer -f docker-composer-pro.yml up -d
#停止服务
docker-composer -f docker-composer-pro.yml stop


#开发环境
cd /root/apollo/
#启动服务
docker-composer -f docker-composer-dev.yml up -d
#停止服务
docker-composer -f docker-composer-dev.yml stop
```

