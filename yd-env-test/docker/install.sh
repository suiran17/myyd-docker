#!/bin/bash

# https://docs.docker.com/install/linux/docker-ce/centos/

# 卸载
sudo yum remove docker-ce && sudo rm -rf /var/lib/docker

# remove docker-compose
sudo rm -rf /usr/local/bin/docker-compose && rm -rf /usr/bin/docker-compose

# Install yum-utils, which provides the yum-config-manager utility
sudo yum install -y yum-utils \
	device-mapper-persistent-data \
	lvm2

# 官方源

# $ sudo yum-config-manager \
#     --add-repo \
#     https://download.docker.com/linux/centos/docker-ce.repo

# 国内源
sudo yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# less /etc/yum.repos.d/docker-ce.repo


# sudo yum-config-manager --enable docker-ce-edge
# sudo yum-config-manager --disable docker-ce-edge

# 列出可用版本
# yum list docker-ce --showduplicates | sort -r

# install
sudo yum install -y  docker-ce docker-ce-cli containerd.io
docker version

# 启动docker
sudo systemctl enable docker.service
sudo systemctl start docker

# 用户组
#sudo groupadd docker
#sudo usermod -aG docker $USER
#cat /etc/group

# 镜像加速
cp ./daemon.json /etc/docker/daemon.json
docker info

# 重启docker
sudo systemctl daemon-reload
sudo systemctl restart docker

#安装docker-compose
#sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo curl -L "https://get.daocloud.io/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
