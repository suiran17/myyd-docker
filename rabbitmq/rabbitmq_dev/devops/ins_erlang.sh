#!/bin/bash

######################################### 注意 #########################################
#权限是与节点相关的，节点名定好后就不能修改了
######################################### 注意 #########################################
# https://www.cnblogs.com/xishuai/p/rabbitmq-cluster.html

softDir="/data/soft/rabbitmq/"

##### 安装 erlang
##源码包安装 erlang 最新版
yum install openssl-devel gcc-c++ unixODBC-devel ncurses-devel

cd ${softDir}
#wget http://erlang.org/download/otp_src_21.3.tar.gz
tar -zxvf otp_src_21.3.tar.gz
cd otp_src_21.3
./configure --prefix=/data/server/erlang_21.3
make
make install

cat << EOF > /etc/profile.d/erlang.sh
# erlang 环境变量
ERLANG_HOME=/data/server/erlang_21.3/
export PATH=\$PATH:\$ERLANG_HOME/bin
EOF

#加载环境变量
source /etc/profile.d/erlang.sh

##使用
##erl 

cd -
