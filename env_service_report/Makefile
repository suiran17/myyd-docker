ls:
	ls

#安装docker
docker_install:
	cd ./docker/ && sh ./install.sh && cd ..

#安装service_report
up:
	docker-compose up service_report

pull:
	docker-compose pull service_report

start:
	docker-compose start service_report

stop:
	docker-compose stop service_report

init_dir:
	mkdir /data
	mkdir /data/www
	mkdir /data/static
