#!/bin/bash

wget http://download.redis.io/releases/redis-5.0.5.tar.gz
tar -zxvf redis-5.0.5.tar.gz
cd redis-5.0.5
make
make install
mkdir /etc/redis/
cp redis.conf /etc/redis/redis_6379_disp.conf

redis-server -c /etc/redis/redis_6379_disp.conf
