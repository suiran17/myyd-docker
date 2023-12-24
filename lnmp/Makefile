clearOpcache:
	docker exec -it php php /www/tools/cachetool.phar opcache:reset --fcgi=127.0.0.1:9000
statusOpcache:
	docker exec -it php php /www/tools/cachetool.phar opcache:status --fcgi=127.0.0.1:9000
confOpcache:
	docker exec -it php php /www/tools/cachetool.phar opcache:configuration --fcgi=127.0.0.1:9000
ips:
	docker inspect --format='{{.Name}} - {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $$(docker ps -aq)
ps:
	docker ps -a
env_local:
	cp .env.local .env
env_test:
	cp .env.test .env
env_pre:
	cp .env.pre .env
env_pro:
	cp .env.pro .env
down:
	docker-compose down --remove-orphans
up:
	docker-compose up -d
conf:
	docker-compose config
build_php:
	docker-compose build --no-cache php
php:
	docker exec -it php bash
phpHost:
	docker exec -it php cat /etc/hosts
nginx:
	docker exec -it nginx sh
mysql:
	docker exec -it mysql sh
reloadNg:
	docker exec -it nginx nginx -s reload
rsync:
	rsync -avt --delete --exclude .env --exclude data/  ./ root@172.16.100.188:/data/docker/lnmp
replace_test_host:
	cp /etc/hosts /etc/hosts_bak
	cp hosts/host_tester /etc/hosts
replace_pre_host:
	cp /etc/hosts /etc/hosts_bak
	cp hosts/host_pre /etc/hosts
scpNgxConfTesterToLocal:
	#scp   root@172.16.100.33:/data/server/openresty-1.9.15.1/nginx/conf/vhost/php7/adminV5.conf ./services/nginx/conf.d/test/adminV5.conf
	#scp   root@172.16.100.33:/data/server/openresty-1.9.15.1/nginx/conf/vhost/php7/admin-v5-api_admin-v5-api.com.conf ./services/nginx/conf.d/test/admin-v5-api_admin-v5-api.com.conf
	scp   -r root@172.16.100.33:/data/www/v5-order-cli-tester/dist ./services/node/v5-order-cli-tester/dist

scpToTesterOrigin:
	scp Readme.md root@172.16.100.33:/test/readme.md

believe:
	ssh-copy-id root@172.16.100.188

curltest:
	curl homev5.test.nodevops.cn
	curl yundunapiv4.test.nodevops.cn
	curl adminv5.test.nodevops.cn
	curl adminv5api.test.nodevops.cn
	curl sso-backend-server.test.nodevops.cn

cpadminv5fronttest:
	cp -r services/node/v5-order-cli-tester /data/www

.PHONY: clearOpcache statusOpcache confOpcache ips ps php phpHost reloadNg env_test env_pre env_pro down up conf rsync replace_test_host replace_pre_host believe curltest




