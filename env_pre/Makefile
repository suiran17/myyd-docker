## 应用hosts, 将宿主的host导入容器内
hosts:
	docker cp /etc/hosts nginx:/tmp/hosts
	docker exec -t nginx /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	docker cp /etc/hosts php:/tmp/hosts
	docker exec -t php /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	docker cp /etc/hosts phpscript:/tmp/hosts
	docker exec -t phpscript /bin/bash -c 'cat /tmp/hosts > /etc/hosts'

#安装docker
docker_install:
	cd ./docker/ && sh ./install.sh && cd ..

init_dir:
	mkdir /data
	mkdir /data/www
	mkdir /data/docker/
	mkdir /data/docker/log
	mkdir /data/docker/pg11
	mkdir /data/docker/mysql
	mkdir /data/docker/redis
	mkdir /data/docker/mongo
	mkdir /data/docker/portainer
	mkdir /data/docker/beanstalkd
	mkdir /data/docker/php
	mkdir /data/docker/php/log
	mkdir /data/docker/nginx
	mkdir /data/docker/nginx/log

up:
	#docker-compose up memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_uat kong_yd konga portainer pg11 mysql php nginx
	docker-compose up memcached beanstalkd mongo mongo-express apollo_config_uat kong_yd konga portainer pg11 mysql php nginx

pull:
	#docker-compose pull memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_uat kong_yd konga portainer pg11 mysql php nginx
	docker-compose pull memcached beanstalkd mongo mongo-express apollo_config_uat kong_yd konga portainer pg11 mysql php nginx

start:
	#docker-compose start memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_uat kong_yd konga portainer pg11 mysql php nginx
	docker-compose start memcached beanstalkd mongo mongo-express apollo_config_uat kong_yd konga portainer pg11 mysql php nginx

stop:
	#docker-compose stop memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_uat kong_yd konga portainer pg11 mysql php nginx
	docker-compose stop memcached beanstalkd mongo mongo-express apollo_config_uat kong_yd konga portainer pg11 mysql php nginx

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
recreate_php_nginx:
	docker-compose rm -f -s php nginx
	docker-compose up --no-start php nginx
	docker-compose start php nginx

##服务报告
report_up:
	docker-compose stop service_report
report_start:
	docker-compose stop service_report
report_stop:
	docker-compose stop service_report

## kong数据库初始化，备份及恢复
kong_db_init:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres psql -h postgresql.pre.nodevops.cn -p 5432 -U postgres -f /tmp/init.sql
kong_db_export:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres pg_dump -h postgresql.pre.nodevops.cn -p 5432 -U kongpre -d kongpre -f /tmp/kongpre.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres pg_dump -h postgresql.pre.nodevops.cn -p 5432 -U kongpre -d kongapre -f /tmp/kongapre.sql
kong_db_import:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres psql -h postgresql.prenodevops.cn -p 5432 -U kongpre -d kongpre -f /tmp/kongpre.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres psql -h postgresql.pre.nodevops.cn -p 5432 -U kongpre -d kongapre -f /tmp/kongapre.sql
