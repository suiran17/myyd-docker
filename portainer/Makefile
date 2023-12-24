
# mkdir -p /data/docker
rsync:
	rsync -avt --delete   ./ root@172.16.100.188:/data/docker/portainer
	rsync -avt --delete   ./ root@172.16.100.103:/data/docker/portainer
up:
	docker-compose up -d
down:
	docker-compose down --remove-orphans

ps:
	docker ps -a
.PHONY: rsync