default:
	make build_php72_yd build_php56_yd

build_php72_alpine_yd:
	cp -R soft ./images/alpine/
	docker-compose build php72_alpine_yd
	rm -rf ./images/alpine/soft
	docker-compose push php72_alpine_yd

build_php56_alpine_yd:
	cp -R soft ./images/alpine/
	docker-compose build php56_alpine_yd
	rm -rf ./images/alpine/soft
	docker-compose push php56_alpine_yd

build_php72_yd:
	cp -R soft ./images/centos7/
	docker-compose build php72_yd
	rm -rf ./images/centos7/soft
	docker-compose push php72_yd

build_php72_ydweb:
	cp -R soft ./images/centos7/
	docker-compose build php72_ydweb
	rm -rf ./images/centos7/soft
	docker-compose push php72_ydweb

build_php72_yd-beast:
	cp -R soft ./images/centos7/
	docker-compose build php72_yd-beast
	rm -rf ./images/centos7/soft
	docker-compose push php72_yd-beast

build_php7234_yd:
	cp -R soft ./images/centos7/
	docker-compose build php7234_yd
	rm -rf ./images/centos7/soft
	docker-compose push php7234_yd
