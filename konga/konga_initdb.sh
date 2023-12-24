#!/bin/bash
#https://github.com/pantsel/konga

##初始化数据库
#docker run --rm docker.io/pantsel/konga:latest -c prepare -a postgres -u 'postgresql://konga:konga123@192.168.1.106:5432/konga'
docker run --rm docker.io/pantsel/konga:latest -c prepare -a postgres -u 'postgresql://konga:konga123@172.16.100.200:5432/konga'

## 预发布环境
docker run --rm docker.io/pantsel/konga:latest -c prepare -a postgres -u 'postgresql://kongapre:kongapre123@172.16.100.188:5432/kongapre'

### 启动
#docker run -p 1337:1337 \
#    -e "TOKEN_SECRET=tester123456" \
#    -e "DB_ADAPTER=postgres" \
#    -e "DB_URI=postgresql://konga:konga123@192.168.1.106:5432/konga?connect_timeout=10&application_name=konga" \
#    -e "NODE_ENV=production" \
#    --name konga \
#    docker.io/pantsel/konga:latest

