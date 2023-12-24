VersionKong=1.3.1
VersionKonga=latest

d_all:
	make kong_yd
kong_yd:
	docker-compose build kong_yd
	docker-compose push  kong_yd
kong21_yd:
	docker-compose build kong21_yd
	docker-compose push  kong21_yd
kong1.3.1_yd:
	docker-compose build kong1.3.1_yd
	docker-compose push  kong1.3.1_yd
kong2.1.0_yd:
	docker-compose build kong2.1.0_yd
	docker-compose push  kong2.1.0_yd
	docker tag docker.nodevops.cn/web/kong:2.1.0_yd harbor-jh.bs58i.baishancdnx.com/safe_biz/kong:2.1.0_yd
	docker push harbor-jh.bs58i.baishancdnx.com/safe_biz/kong:2.1.0_yd
kong2.1_c7_yd:
	docker-compose build kong2.1_c7_yd
	docker-compose push  kong2.1_c7_yd
	docker tag docker.nodevops.cn/web/kong:2.1_c7_yd harbor-jh.bs58i.baishancdnx.com/safe_biz/kong:2.1_c7_yd
	docker push harbor-jh.bs58i.baishancdnx.com/safe_biz/kong:2.1_c7_yd
