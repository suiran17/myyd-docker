##基础镜像
ARG IMAGE
FROM ${IMAGE}

##新镜像维护人
MAINTAINER jingwu

##环境变量 变量值	设置一个环境变量的值，会被后面的 RUN 使用
ENV LANG zh_CN.UTF-8

###添加文件到镜像
#ADd 

##开启的端口
EXPOSE 8000
EXPOSE 8001
EXPOSE 8443
EXPOSE 8444

USER root
##在镜像中执行命令
RUN echo "export LC_ALL=en_US.UTF-8" >> /etc/profile \
    && source /etc/profile                           \
    && echo "export LC_ALL=C" >> /root/.bashrc       \
    && source /root/.bashrc

## 定制 docker-entrypoint.sh
COPY ./docker-entrypoint-yd.sh /docker-entrypoint-yd.sh
RUN chmod +x /docker-entrypoint-yd.sh

##运行时用户名/UID
#USER  kong

##工作目录, RUN/CMD/ENTRYPOINT
#WORKDIR /

##创建挂载点
VOLUME ["/etc/kong/"]

##构建镜像时运行命令
#ONBUILD

##当启动容器时执行的脚本文件
#ENTRYPOINT ["/docker-entrypoint-yd.sh"]

##当启动容器时执行的脚本文件
#CMD ["/yd_init.sh"]
