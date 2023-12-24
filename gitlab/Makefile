ls:
	ls
chmod:
	chmod 0600 gitlab/ssh_host_rsa_key
	chmod 0600 gitlab/ssh_host_ecdsa_key
	chmod 0600 gitlab/ssh_host_ed25519_key
#安装docker
docker_install:
	cd ./docker/ && sh ./install.sh && cd ..

build_8.8-zh:
	docker build -t docker.nodevops.cn/web/gitlab:8.8-zh -f ./8.8_zh/Dockerfile .
	docker push docker.nodevops.cn/web/gitlab:8.8.7-ce.1-zh
build_12.3-zh:
	docker build -t docker.nodevops.cn/web/gitlab:12.3-zh -f ./12.3_zh/Dockerfile .
	docker push docker.nodevops.cn/web/gitlab:12.3-zh

start:
	docker-compose rm gitlab
	docker-compose up --no-start gitlab
	docker-compose start gitlab
stop:
	docker-compose stop gitlab

## crontab 每天2点备份并同步到127
## 1 2 * * * source /etc/profile && cd /data/devops/gitlab && make backup
backup:
	docker exec -i gitlab gitlab-rake gitlab:backup:create
	rsync -avt -e "ssh -p 2121 " /data/docker/gitlab/opt/backups/ root@172.16.100.127:/data/docker/gitlab/opt/backups

restore:
	docker exec -it gitlab gitlab-rake gitlab:backup:restore BACKUP=1406691018

## 同步备份到127
rsync_backup:
	rsync -avt -e "ssh -p 2121 " /data/docker/gitlab/opt/backups/ root@172.16.100.127:/data/docker/gitlab/opt/backups

##升级程序
up_8.8_8.17:
	docker-compose stop gitlab
	docker-compose up gitlab8.17
	docker exec -i gitlab8.17 gitlab-rake gitlab:backup:create
up_8.17_9.0:
	docker-compose stop gitlab8.17
	docker-compose up gitlab9.0
	docker exec -i gitlab9.0 gitlab-rake gitlab:backup:create
up_9.0_9.5:
	docker-compose stop gitlab9.0
	docker-compose up gitlab9.5
	docker exec -i gitlab9.5 gitlab-rake gitlab:backup:create
up_9.5_10.0:
	docker-compose stop gitlab9.5
	docker-compose up gitlab10.0
	docker exec -i gitlab10.0 gitlab-rake gitlab:backup:create
up_10.0_10.8:
	docker-compose stop gitlab10.0
	docker-compose up gitlab10.8
	docker exec -i gitlab10.8 gitlab-rake gitlab:backup:create
up_10.8_11.0:
	docker-compose stop gitlab10.8
	docker-compose up gitlab11.0
	docker exec -i gitlab11.0 gitlab-rake gitlab:backup:create
up_11.0_11.11:
	docker-compose stop gitlab11.0
	docker-compose up gitlab11.11
	docker exec -i gitlab11.11 gitlab-rake gitlab:backup:create
up_11.11_12.0:
	docker-compose stop gitlab11.11
	docker-compose up gitlab12.0
	docker exec -i gitlab12.0 gitlab-rake gitlab:backup:create
up_12.0_12.3:
	docker-compose stop gitlab12.0
	docker-compose up gitlab12.3
	docker exec -i gitlab12.3 gitlab-rake gitlab:backup:create
up_12.3_12.10:
	docker-compose stop gitlab12.3
	docker-compose up gitlab12.10
	docker exec -i gitlab12.10 gitlab-rake gitlab:backup:create
