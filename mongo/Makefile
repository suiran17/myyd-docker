
# mkdir -p /data/docker
rsync:
	rsync -avt --delete --exclude Makefile  ./ root@172.16.100.107:/data/docker/docker_install/mongo
	rsync -avt --delete --exclude Makefile ./ root@172.16.100.108:/data/docker/docker_install/mongo
up:
	docker-compose up -d
down:
	docker-compose down --remove-orphans
ps:
	docker ps -a
rockmongo:
	docker exec -it mongo_rockmongo_1 bash

mongo:
	docker exec -it mongo_mongo_1 bash
mongoexpress:
	docker exec -it mongo_mongo-express_1 bash
.PHONY: rsync
push_mongo4.2:
	docker pull mongo:4.2
	docker tag mongo:4.2 docker.nodevops.cn/web/mongo:4.2
	docker push docker.nodevops.cn/web/mongo:4.2
push_mongo3.7:
	docker pull mongo:3.7
	docker tag mongo:3.7 docker.nodevops.cn/web/mongo:3.7
	docker push docker.nodevops.cn/web/mongo:3.7
push_mongo4.4:
	docker pull mongo:4.4
	docker tag mongo:4.4 docker.nodevops.cn/web/mongo:4.4
	docker push docker.nodevops.cn/web/mongo:4.4
