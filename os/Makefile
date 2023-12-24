default:
	make build_php72_yd build_php56_yd

build_centos7:
	cp -R soft ./images/centos7/
	docker-compose build centos7
	rm -rf ./images/centos7/soft
	docker-compose push centos7
