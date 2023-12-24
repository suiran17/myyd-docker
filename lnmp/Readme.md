## env
- .env.local
	- 本地
- .env.test
	- 测试
- .env.pre
	- 预发布
- .env.pro
	- 生产环境	
- .env
	- 各环境对应文件改为此文件名，例如: 测试环境 .env.test->.env

## init 
- !!!各环境对应环境变量，切记这步!!!
- make env_local/env_test/env_pre/env_pro

## up
- make up

## down
- make down
	

## opCache gui
- 172.16.100.188 opcachegui.test.nodevops.cn admin:admin				