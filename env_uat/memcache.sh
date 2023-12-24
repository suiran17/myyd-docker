#!/bin/bash

act=$1

if [ "${act}" == "install" ]; then
    memcache=memcached-1.5.17
    yum install libevent libevent-devel
    tar -zxvf ./${memcache}.tar.gz
    cd ${memcache}
    ./configure
    make
    make instll
elif [ "${act}" == "start" ]; then 
    memcached -u www -p 11211 --daemon
elif [ "${act}" == "stop" ]; then 
    ps -ef | grep memcached | grep -v grep | awk '{print $2}' | xargs kill -9
else
    echo "不支持的动作！"
    echo "请选择如下动作：install | start | stop"
fi
