#!/bin/bash

act=$1
if [ "${act}" == "install" ]; then
    redis="redis-5.0.5"
    tar zxf ${redis}.tar.gz
    cd ${redis}
    make
    make install
    cd ..
    cp ${redis}/sentinel.conf /etc/redis/sentinel_6379.conf 
    cp ${redis}/sentinel.conf /etc/redis/sentinel_6380.conf
    ./${redis}/utils/install_server.sh

elif [ "${act}" == "config" ]; then

    cfile="/etc/redis/6379.conf"
    sed -i 's|^# requirepass.*$|requirepass|'          ${cfile}

    sed -i 's|^bind.*$|bind 0.0.0.0|'                  ${cfile}
    sed -i 's|^daemonize.*$|daemonize yes|'            ${cfile}
    sed -i 's|^protected-mode.*$|protected-mode yes|'  ${cfile}
    sed -i 's|^protected-mode.*$|protected-mode yes|'  ${cfile}
    sed -i 's|^requirepass.*$|requirepass bdc2cb925|'  ${cfile}

    cfile="/etc/redis/6380.conf"
    sed -i 's|^bind.*$|bind 0.0.0.0|'                  ${cfile}
    sed -i 's|^daemonize.*$|daemonize yes|'                  ${cfile}
    sed -i 's|^protected-mode.*$|protected-mode yes|'  ${cfile}
    sed -i 's|^requirepass.*$|requirepass bdc2cb925|'  ${cfile}
    grep -q '^slaveof' ${cfile} && sed -i 's|^slaveof.*$|slaveof 172.16.100.165 6379|' ${cfile} || echo 'slaveof 172.16.100.165 6379 ' >> ${cfile}

    cfile="/etc/redis/sentinel_6379.conf"
    sed -i 's|^daemonize.*$|daemonize yes|' ${cfile}
    sed -i 's|^sentinel known-replica mymaster.*$|sentinel known-replica mymaster 172.16.100.165 6379|' ${cfile}

    cfile="/etc/redis/sentinel_6380.conf"
    sed -i 's|^daemonize.*$|daemonize yes|' ${cfile}
    sed -i 's|^sentinel known-replica mymaster.*$|sentinel known-replica mymaster 172.16.100.165 6380|' ${cfile}

    echo "配置完成"

elif [ "${act}" == "start" ]; then
    /etc/init.d/redis_6379 start
    /etc/init.d/redis_6380 start
    nohup redis-sentinel /etc/redis/sentinel_6379.conf &
    nohup redis-sentinel /etc/redis/sentinel_6380.conf &

elif [ "${act}" == "stop" ]; then
    /etc/init.d/redis_6379 stop
    /etc/init.d/redis_6380 stop
    ps -ef | grep 'redis-sentinel' | awk '{print $2}' | xargs kill -9

else
    echo "不允许的动作!"
    echo "请选择如下动作：install | config | start | stop"
fi
