VersionPg11=v0.3
VersionPg11Basic=v0.3
pg11:
	docker build -t docker.nodevops.cn/web/pg11:${VersionPg11} -f ./Dockerfile .
	docker push docker.nodevops.cn/web/pg11:${VersionPg11}

pg11_basic:
	docker build -t docker.nodevops.cn/web/pg11_basic:${VersionPg11Basic} -f ./Dockerfile_basic .
	docker push docker.nodevops.cn/web/pg11_basic:${VersionPg11Basic}

pg11_yd:
	docker pull postgres:11
	docker tag  postgres:11 docker.nodevops.cn/web/postgres:11_yd
	docker push docker.nodevops.cn/web/postgres:11_yd
