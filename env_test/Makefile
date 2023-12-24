ssh_test=root@172.16.100.112
# 应用hosts, 将宿主的host导入容器内
hosts:
	- docker cp /etc/hosts nginx:/tmp/hosts
	- docker exec -t nginx /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts php:/tmp/hosts
	- docker exec -t php /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts phpscript:/tmp/hosts
	- docker exec -t phpscript /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts kong:/tmp/hosts
	- docker exec -t kong /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts konga:/tmp/hosts
	- docker exec -t konga /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts home-v5-bundle:/tmp/hosts
	- docker exec -t home-v5-bundle /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts processd_phpscript_ypf_swoole_async:/tmp/hosts
	- docker exec -t processd_phpscript_ypf_swoole_async /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts processd_phpscript_yundun_api_v4:/tmp/hosts
	- docker exec -t processd_phpscript_yundun_api_v4 /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts processd_phpscript_adminv2:/tmp/hosts
	- docker exec -t processd_phpscript_adminv2 /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts processd_phpscript_adminv3:/tmp/hosts
	- docker exec -t processd_phpscript_adminv3 /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	- docker cp /etc/hosts processd_phpscript_home-v4-cli:/tmp/hosts
	- docker exec -t processd_phpscript_home-v4-cli /bin/bash -c 'cat /tmp/hosts > /etc/hosts'
	#docker cp /etc/hosts processd_phpscript_dispatcher_cli:/tmp/hosts
	#docker exec -t processd_phpscript_dispatcher_cli /bin/bash -c 'cat /tmp/hosts > /etc/hosts'

ls: 
	ls
push:
	rsync -avt --delete ./          ${ssh_test}:/root/devops/env_test

up:
	#docker-compose up memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx
	docker-compose up memcached beanstalkd mongo mongo-express apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx

pull:
	#docker-compose pull memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx
	docker-compose pull memcached beanstalkd mongo mongo-express apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx

start:
	#docker-compose start memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx
	docker-compose start memcached beanstalkd mongo mongo-express apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx

stop:
	#docker-compose stop memcached beanstalkd redis mongo mongo-express apollo_portal apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx
	docker-compose stop memcached beanstalkd mongo mongo-express apollo_config_dev apollo_config_fat apollo_config_lpt kong_yd konga portainer pg11 mysql php nginx

init_dir:
	mkdir -p /data
	mkdir -p /data/www
	mkdir -p /data/docker/
	mkdir -p /data/docker/log
	mkdir -p /data/docker/pg11
	mkdir -p /data/docker/mysql
	mkdir -p /data/docker/redis
	mkdir -p /data/docker/mongo
	mkdir -p /data/docker/portainer
	mkdir -p /data/docker/beanstalkd
	mkdir -p /data/docker/php
	mkdir -p /data/docker/php/log
	mkdir -p /data/docker/nginx
	mkdir -p /data/docker/nginx/log
	mkdir -p /data/docker/nginx_tcp
	mkdir -p /data/docker/nginx_tcp/log
	mkdir -p /data/docker/rabbitmq1/data
	mkdir -p /data/docker/rabbitmq2/data
	mkdir -p /data/docker/rabbitmq3/data
	mkdir -p /data/docker/rabbitmq4/data

#安装docker
docker_install:
	cd ./docker/ && sh ./install.sh && cd ..

#前台node
pm2_list:
	docker exec -t home-v5-bundle pm2 list
	docker exec -t yundun-map-report pm2 list

test_domain:
	curl 172.16.100.112 -i -v -H "Host: adminv5api.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: adminv3.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: adminv3-agent.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: homev3.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: homev5.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: hwws.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: sso-passport.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: sso-backend-server.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: yundunapi.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: yundunapiv4.test.nodevops.cn"
	curl 172.16.100.112 -i -v -H "Host: www.yundun.cn"
	curl 172.16.100.112 -i -v -H "Host: www.yundun.com"
	curl 172.16.100.112 -i -v -H "Host: yundun.cn"
	curl 172.16.100.112 -i -v -H "Host: yundun.com"

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

#安装apollo_config
apollo_up:
	docker-compose up apollo_config_dev apollo_admin_dev
apollo_start:
	docker-compose start apollo_config_dev apollo_admin_dev
apollo_stop:
	docker-compose stop apollo_config_dev apollo_admin_dev

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
nginx_reload:
	docker exec -it nginx nginx -s reload
php_up:
	docker-compose up php
php_start:
	docker-compose start php
php_stop:
	docker-compose stop php

##服务报告
report_up:
	docker-compose up service_report
report_start:
	docker-compose start service_report
report_stop:
	docker-compose stop service_report

redis_sentinel_start:
	docker-compose up --no-start senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381
	docker-compose start senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381

redis_sentinel_stop:
	docker-compose stop senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381
	#docker-compose rm senti_redis_6379 senti_redis_6380 senti_redis_6381 senti_26379 senti_26380 senti_26381
	#docker volume rm ydredis_data_6379 ydredis_data_6380 ydredis_data_6381

###rabbtimq
rabbtimq_up:
	docker-compose up --no-start rabbitmq1 rabbitmq2  rabbitmq3  rabbitmq4
rabbtimq_start:
	docker-compose start rabbitmq1 rabbitmq2  rabbitmq3  rabbitmq4
rabbtimq_stop:
	docker-compose stop rabbitmq1 rabbitmq2  rabbitmq3  rabbitmq4

## rabbtimq cluster conf
rabbtimq_cluster:
	cd ./rabbitmq/ && sh ./cluster.sh && cd ..

## kong数据库初始化，备份及恢复
kong_db_init:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres psql -h postgresql.test.nodevops.cn -p 5432 -U postgres -f /tmp/init.sql
kong_db_export:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres pg_dump -h postgresql.test.nodevops.cn -p 5432 -U kong -d kong -f /tmp/kong.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres pg_dump -h postgresql.test.nodevops.cn -p 5432 -U kong -d konga -f /tmp/konga.sql
kong_db_import:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres psql -h postgresql.test.nodevops.cn -p 5432 -U kong -d kong -f /tmp/kong.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/postgres/:/tmp/ postgres psql -h postgresql.test.nodevops.cn -p 5432 -U kong -d konga -f /tmp/konga.sql

## mongo 备份及恢复
mongo_db_export:
	mkdir -p `pwd`/mongo/backup/oplog && chmod -R 0777 `pwd`/mongo/backup/oplog
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.188 -d oplog -o /tmp/
	mkdir -p `pwd`/mongo/backup/batch && chmod -R 0777 `pwd`/mongo/backup/batch
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.188 --port=27018 -u admin -p admin --authenticationDatabase admin -d batch -o /tmp/
	mkdir -p `pwd`/mongo/backup/disp3 && chmod -R 0777 `pwd`/mongo/backup/disp3
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.188 -d disp3 -o /tmp/
	mkdir -p `pwd`/mongo/backup/cdn && chmod -R 0777 `pwd`/mongo/backup/cdn
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongodump -h 172.16.100.188 --port=27018 -u admin -p admin --authenticationDatabase admin -d cdn   -o /tmp/
mongo_db_import:
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.116 -u admin -p admin --authenticationDatabase admin -d oplog  /tmp/oplog
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.116 -u admin -p admin --authenticationDatabase admin -d batch  /tmp/batch
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.116 -u admin -p admin --authenticationDatabase admin -d disp3  /tmp/disp3
	docker-compose run --rm -v `pwd`/mongo/backup/:/tmp/ mongo mongorestore -h 172.16.100.116 -u admin -p admin --authenticationDatabase admin -d cdn    /tmp/cdn

## mysql 备份及恢复
mysql_export:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_cp > /tmp/yundun_cp.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_cp_v4 > /tmp/yundun_cp_v4.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_dns > /tmp/yundun_dns.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_api > /tmp/yundun_api.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_rbac > /tmp/yundun_rbac.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_sso > /tmp/yundun_sso.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_tag > /tmp/yundun_tag.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_asset > /tmp/yundun_asset.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysqldump -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_mcs > /tmp/yundun_mcs.sql
mysql_import:
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_cp < /tmp/yundun_cp.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_cp_v4 < /tmp/yundun_cp_v4.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_dns < /tmp/yundun_dns.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_api < /tmp/yundun_api.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_rbac < /tmp/yundun_rbac.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_sso < /tmp/yundun_sso.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_tag < /tmp/yundun_tag.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_asset < /tmp/yundun_asset.sql
	docker-compose run --rm -v /etc/hosts:/etc/hosts -v `pwd`/mysql/export/:/tmp mysql mysql -h mysql.test.nodevops.cn -uphp -p'ku5Ne(szK4' yundun_mcs < /tmp/yundun_mcs.sql

code_init:
	mkdir -p /data/www
	cd /data/www && if [ ! -d yundun_api_v4 ]; then                 git clone -b tester git@git.nodevops.cn:web/yundun_api_v4.git; fi
	cd /data/www && if [ ! -d admin-v5-api ]; then                  git clone -b tester git@git.nodevops.cn:web/admin-v5-api.git; fi
	cd /data/www && if [ ! -d home-v5-backend ]; then               git clone -b tester git@git.nodevops.cn:web/home-v5-backend.git; fi
	cd /data/www && if [ ! -d adminv5-backend ]; then               git clone -b tester git@git.nodevops.cn:web/adminv5-backend.git; fi
	cd /data/www && if [ ! -d sso-backend-server ]; then            git clone -b tester git@git.nodevops.cn:web/sso-backend-server.git; fi
	cd /data/www && if [ ! -d sso-backend-client-passport ]; then   git clone -b tester git@git.nodevops.cn:web/sso-backend-client-passport.git; fi
	cd /data/www && if [ ! -d admin-v3 ]; then                      git clone -b tester git@git.nodevops.cn:web/admin-v3.git; fi
	cd /data/www && if [ ! -d yundun_api ]; then                    git clone -b tester git@git.nodevops.cn:web/yundun_api.git; fi
	cd /data/www && if [ ! -d yundun-mcs ]; then                    git clone -b tester git@git.nodevops.cn:web/yundun-mcs.git; fi
	cd /data/www && if [ ! -d home-v4-cli ]; then                   git clone -b tester git@git.nodevops.cn:cli/home-v4-cli.git; fi
	cd /data/www && if [ ! -d home-v4-cli ]; then                   git clone -b tester git@git.nodevops.cn:cli/home-v4-cli.git; fi
	cd /data/www && if [ ! -d home-v3 ]; then                       git clone -b tester git@git.nodevops.cn:web/home-v3.git; fi
	cd /data/www && if [ ! -d home-v3 ]; then                       git clone -b tester git@git.nodevops.cn:web/home-v3-cli.git; fi
	cd /data/www && if [ ! -d ypf_Swoole ]; then                    git clone -b tester git@git.nodevops.cn:web/ypf_Swoole.git; fi
	cd /data/www && if [ ! -d ypf_swoole_async ]; then              git clone -b tester git@git.nodevops.cn:cli/ypf_swoole_async.git; fi
	cd /data/www && if [ ! -d yundun-agent ]; then                  git clone -b tester git@git.nodevops.cn:web/yundun-agent.git; fi
	cd /data/www && if [ ! -d dispatcher_cli ]; then                git clone -b tester git@git.nodevops.cn:cli/dispatcher_cli.git; fi
	mkdir -p /data/www/go
	cd /data/www/go && if [ ! -d service_cdn ]; then                git clone -b tester git@git.nodevops.cn:gcode/service_cdn.git; fi
	cd /data/www/go && if [ ! -d service_oplog ]; then              git clone -b tester git@git.nodevops.cn:gcode/service_oplog.git; fi
	cd /data/www/go && if [ ! -d service_disp ]; then               git clone -b tester git@git.nodevops.cn:gcode/service_disp.git; fi
	cd /data/www/go && if [ ! -d service_dns ]; then                git clone -b tester git@git.nodevops.cn:gcode/service_dns.git; fi
	cd /data/www/go && if [ ! -d service_asset ]; then              git clone -b tester git@git.nodevops.cn:gcode/service_asset.git; fi
	cd /data/www/go && if [ ! -d service_notify ]; then             git clone -b tester git@git.nodevops.cn:gcode/service_notify.git; fi
	cd /data/www/go && if [ ! -d service_tag ]; then                git clone -b tester git@git.nodevops.cn:gcode/service_tag.git; fi
	cd /data/www/go && if [ ! -d service_notice_qywx ]; then        git clone -b tester git@git.nodevops.cn:gcode/service_notice_qywx.git; fi
	cd /data/www/go && if [ ! -d service_upload ]; then             git clone -b tester git@git.nodevops.cn:gcode/service_upload.git; fi
	cd /data/www/go && if [ ! -d service_batch ]; then              git clone -b tester git@git.nodevops.cn:gcode/service_batch.git; fi
	cd /data/www/go && if [ ! -d dns_check ]; then                  git clone -b tester git@git.nodevops.cn:gcode/dns_check.git; fi
	cd /data/www/go && if [ ! -d gtool ]; then                      git clone -b tester git@git.nodevops.cn:gcode/gtool.git; fi
	cd /data/www/go && if [ ! -d nsq ]; then                        git clone -b tester git@git.nodevops.cn:devops_prod/nsq.git; fi

## SCDN服务
service_cdn_stop:
	/data/www/go/service_cdn/bin/service_cdn_api 		-c /data/www/go/service_cdn/cfg/test stop
	/data/www/go/service_cdn/bin/service_cdn_consumer 	-c /data/www/go/service_cdn/cfg/test stop
service_cdn_start:
	/data/www/go/service_cdn/bin/service_cdn_api 		-c /data/www/go/service_cdn/cfg/test start
	/data/www/go/service_cdn/bin/service_cdn_consumer 	-c /data/www/go/service_cdn/cfg/test start

## 操作日志服务
service_oplog_stop:
	/data/www/go/service_oplog/bin/service_oplog_api 		-c /data/www/go/service_oplog/cfg/test stop
	/data/www/go/service_oplog/bin/service_oplog_consumer 	-c /data/www/go/service_oplog/cfg/test stop
service_oplog_start:
	/data/www/go/service_oplog/bin/service_oplog_api 		-c /data/www/go/service_oplog/cfg/test start
	/data/www/go/service_oplog/bin/service_oplog_consumer 	-c /data/www/go/service_oplog/cfg/test start

## 调度服务
service_disp_stop:
	/data/www/go/service_disp/bin/service_disp_api 			-c /data/www/go/service_disp/cfg/test stop
	/data/www/go/service_disp/bin/service_disp_consumer 	-c /data/www/go/service_disp/cfg/test stop
service_disp_start:
	/data/www/go/service_disp/bin/service_disp_api 			-c /data/www/go/service_disp/cfg/test start
	/data/www/go/service_disp/bin/service_disp_consumer 	-c /data/www/go/service_disp/cfg/test start

## DNS服务
service_dns_stop:
	/data/www/go/service_dns/bin/service_dns_api -c /data/www/go/service_dns/cfg/test stop
service_dns_start:
	/data/www/go/service_dns/bin/service_dns_api -c /data/www/go/service_dns/cfg/test start

## 资产服务
service_asset_stop:
	/data/www/go/service_asset/bin/service_asset_api -c /data/www/go/service_asset/cfg/test stop
service_asset_start:
	/data/www/go/service_asset/bin/service_asset_api -c /data/www/go/service_asset/cfg/test start

## 通知服务
service_notify_stop:
	/data/www/go/service_notify/bin/service_notify_api -c /data/www/go/service_notify/cfg/test stop
service_notify_start:
	/data/www/go/service_notify/bin/service_notify_api -c /data/www/go/service_notify/cfg/test start

## 标签服务
service_tag_stop:
	/data/www/go/service_tag/bin/service_tag_api -c /data/www/go/service_tag/cfg/test stop
service_tag_start:
	/data/www/go/service_tag/bin/service_tag_api -c /data/www/go/service_tag/cfg/test start

## 微信通知
service_notice_qywx_stop:
	ps -ef | grep service_notice_qywx | grep -v grep | awk '{print $$2}' | xargs kill -9
service_notice_qywx_start:
	nohup /data/www/go/service_notice_qywx/bin/service_notice_qywx -c /data/www/go/service_notice_qywx/cfg/test/ &

## 上传服务
service_upload_stop:
	ps -ef | grep service_upload | grep -v grep | awk '{print $$2}' | xargs kill -9
service_upload_start:
	nohup /data/www/go/service_upload/bin/service_upload -c /data/www/go/service_upload/cfg/test/ &

## 批量任务服务
service_batch_stop:
	/data/www/go/service_batch/bin/service_batch_api      -c /data/www/go/service_batch/cfg/test stop
	/data/www/go/service_batch/bin/service_batch_consumer -c /data/www/go/service_batch/cfg/test stop
service_batch_start:
	/data/www/go/service_batch/bin/service_batch_api      -c /data/www/go/service_batch/cfg/test start
	/data/www/go/service_batch/bin/service_batch_consumer -c /data/www/go/service_batch/cfg/test start

## 旧版DNS检测
domain_stop:
	ps -ef | grep domain | grep -v grep | grep dns_check | awk '{print $$2}' | xargs kill -9
domain_start:
	nohup cd /data/www/go/dns_check && /data/www/go/dns_check/bin/domain &

## gtool
gtool_stop:
	/data/www/go/gtool/bin/crontab_sched -c /data/www/go/gtool/cfg/test stop
gtool_start:
	/data/www/go/gtool/bin/crontab_sched -c /data/www/go/gtool/cfg/test start

## nsqd
nsqd_stop:
	ps -ef | grep nsqd | grep -v grep | awk '{print $$2}' | xargs kill -9
nsqd_start:
	nohup cd /data/www/go/nsq && ./nsqd -config nsqd.toml >> /tmp/log_nsqd.log 2>&1 &

## file_to_nsq
file_to_nsq_stop:
	ps -ef | grep file_to_nsq | grep -v grep | awk '{print $$2}' | xargs kill -9
file_to_nsq_start:
	nohup cd /data/www/go/nsq && ./file_to_nsq -config file_to_nsq.yaml >> /tmp/log_file_to_nsq.log &

all_init:
	make init_dir
	make code_init
	docker-compose rm -f php phpscript nginx kong_yd konga memcached beanstalkd mongo mongo-express portainer pg11 apollo_config_dev apollo_admin_dev service_report
	docker-compose up --no-start php phpscript nginx kong_yd konga memcached beanstalkd mongo mongo-express portainer pg11 apollo_config_dev apollo_admin_dev service_report
	docker-compose start php phpscript nginx kong_yd konga memcached beanstalkd mongo mongo-express portainer pg11 apollo_config_dev apollo_admin_dev service_report
	make redis_sentinel_start
