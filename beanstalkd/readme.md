#### 基于alpine构建beanstalkd镜像 支持启动传入参数
##### docker-compose使用方法: command: -z 66635 -b /var/lib/beanstalkd/binlog -F
##### docker使用方法: docker run -it -d -p 11300:11300 -v /binlog:/var/lib/beanstalkd/binlog --name beanstalkd docker.nodevops.cn/web/yd-beanstalkd:v1.0 -z 66635 -b /var/lib/beanstalkd/binlog -F
