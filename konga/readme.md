### 使用说明

#### 测试环境容器

docker-compose -f docker-compose-dev.yaml up
docker-compose -f docker-compose-dev.yaml start
docker-compose -f docker-compose-dev.yaml stop

psql -h 172.16.100.188 -U kong


#### 预发布环境容器

docker-compose -f docker-compose-pre.yaml up
docker-compose -f docker-compose-pre.yaml start
docker-compose -f docker-compose-pre.yaml stop

psql -h 172.16.100.188 -U kongapre

