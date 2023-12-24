ls: 
	ls
start:
	make php_start nginx_start
stop:
	make php_stop nginx_stop

init_dir:
	mkdir /data
	mkdir /data/www
	mkdir /data/log
	mkdir /data/log/nginx
	mkdir /data/log/php
	mkdir /data/log/php_tmp

#安装docker
docker_install:
	cd ./docker/ && sh ./install.sh && cd ..

#安装kong
kong_up:
	docker-compose up kong
kong_start:
	docker-compose start kong
kong_stop:
	docker-compose stop kong

#安装konga
konga_up:
	docker-compose up konga
konga_start:
	docker-compose start konga
konga_stop:
	docker-compose stop konga

#安装apollo_portal
apollo_portal_up:
	docker-compose up konga
apollo_portal_start:
	docker-compose start konga
apollo_portal_stop:
	docker-compose stop konga

#安装apollo_config
apollo_config_up:
	docker-compose up konga
apollo_config_start:
	docker-compose start konga
apollo_config_stop:
	docker-compose stop konga

#安装apollo_config
postgres_up:
	docker-compose up postgres
postgres_start:
	docker-compose start postgres
postgres_stop:
	docker-compose stop postgres

nginx_up:
	docker-compose up nginx
nginx_start:
	docker-compose start nginx
nginx_stop:
	docker-compose stop nginx

php_up:
	docker-compose up php
php_start:
	docker-compose start php
php_stop:
	docker-compose stop php

redis_sentinel_start:
	docker-compose up --no-start senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381
	docker-compose start senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381

redis_sentinel_stop:
	docker-compose stop senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381
	docker-compose rm senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381
	docker volume rm ydredis_data_6379 ydredis_data_6380 ydredis_data_6381
## mongo 备份及恢复
mongo_db_export:
	mkdir -p `pwd`/mongo/backup/oplog && chmod -R 0777 `pwd`/mongo/backup/oplog
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.200-d oplog -o /tmp/
	mkdir -p `pwd`/mongo/backup/batch && chmod -R 0777 `pwd`/mongo/backup/batch
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.200 --port=27018 -u admin -p admin --authenticationDatabase admin -d batch -o /tmp/
	mkdir -p `pwd`/mongo/backup/disp3 && chmod -R 0777 `pwd`/mongo/backup/disp3
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.200-d disp3 -o /tmp/
	mkdir -p `pwd`/mongo/backup/cdn && chmod -R 0777 `pwd`/mongo/backup/cdn
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.200 --port=27018 -u admin -p admin --authenticationDatabase admin -d cdn   -o /tmp/
mongo_db_import:
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.114 -u admin -p admin --authenticationDatabase admin -d oplog  /tmp/oplog
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.114 -u admin -p admin --authenticationDatabase admin -d batch  /tmp/batch
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.114 -u admin -p admin --authenticationDatabase admin -d disp3  /tmp/disp3
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.114 -u admin -p admin --authenticationDatabase admin -d cdn    /tmp/cdn

