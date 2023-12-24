APOLLO_VERSION=v0.0.7
d_all:
	make d_portal d_config d_config_local d_config_dev d_config_fat d_config_lpt d_config_uat d_config_pro
d_portal:
	#docker build -t docker.io/jingwu/apollo_portal:$(APOLLO_VERSION) 		-f apollo_portal/Dockerfile .
	#docker push docker.io/jingwu/apollo_portal:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_portal:$(APOLLO_VERSION) 		-f portal/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_portal:$(APOLLO_VERSION)

d_config:
	#docker build -t docker.io/jingwu/apollo_config:$(APOLLO_VERSION) 		-f apollo_config/Dockerfile .
	#docker push docker.io/jingwu/apollo_config:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_config:$(APOLLO_VERSION) 		-f config/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_config:$(APOLLO_VERSION)

d_config_local:
	#docker build -t docker.io/jingwu/apollo_config_local:$(APOLLO_VERSION) 	-f apollo_config_local/Dockerfile .
	#docker push docker.io/jingwu/apollo_config_local:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_config_local:$(APOLLO_VERSION) 	-f config_local/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_config_local:$(APOLLO_VERSION)

d_config_dev:
	#docker build -t docker.io/jingwu/apollo_config_dev:$(APOLLO_VERSION) 	-f apollo_config_dev/Dockerfile .
	#docker push docker.io/jingwu/apollo_config_dev:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_config_dev:$(APOLLO_VERSION) 	-f config_dev/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_config_dev:$(APOLLO_VERSION)

d_config_fat:
	#docker build -t docker.io/jingwu/apollo_config_fat:$(APOLLO_VERSION) 	-f apollo_config_fat/Dockerfile .
	#docker push docker.io/jingwu/apollo_config_fat:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_config_fat:$(APOLLO_VERSION) 	-f config_fat/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_config_fat:$(APOLLO_VERSION)

d_config_lpt:
	#docker build -t docker.io/jingwu/apollo_config_lpt:$(APOLLO_VERSION) 	-f apollo_config_lpt/Dockerfile .
	#docker push docker.io/jingwu/apollo_config_lpt:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_config_lpt:$(APOLLO_VERSION) 	-f config_lpt/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_config_lpt:$(APOLLO_VERSION)

d_config_uat:
	#docker build -t docker.io/jingwu/apollo_config_uat:$(APOLLO_VERSION) 	-f apollo_config_uat/Dockerfile .
	#docker push docker.io/jingwu/apollo_config_uat:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_config_uat:$(APOLLO_VERSION) 	-f config_uat/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_config_uat:$(APOLLO_VERSION)

d_config_pro:
	#docker build -t docker.io/jingwu/apollo_config_pro:$(APOLLO_VERSION) 	-f apollo_config_pro/Dockerfile .
	#docker push docker.io/jingwu/apollo_config_pro:$(APOLLO_VERSION)
	docker build -t docker.nodevops.cn/web/apollo_config_pro:$(APOLLO_VERSION) 	-f config_pro/Dockerfile .
	docker push docker.nodevops.cn/web/apollo_config_pro:$(APOLLO_VERSION)
