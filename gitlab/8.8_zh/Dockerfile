##基础镜像
FROM docker.io/gitlab/gitlab-ce:8.8.7-ce.1

##新镜像维护人
MAINTAINER jingwu

##环境变量 变量值	设置一个环境变量的值，会被后面的 RUN 使用
ENV LANG zh_CN.UTF-8

###添加文件到镜像
ADD ./diff/8.8.diff /root/

###开启的端口
#EXPOSE 22
#EXPOSE 80
#EXPOSE 443

##在镜像中执行命令
RUN patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < /root/8.8.diff

##运行时用户名/UID
#USER 

##工作目录, RUN/CMD/ENTRYPOINT
WORKDIR  /root/

##创建挂载点
#VOLUME ["/etc/gitlab/gitlab.rb", "/etc/gitlab/ssl", "/var/opt/gitlab"]

##构建镜像时运行命令
#ONBUILD

##当启动容器时执行的脚本文件
#CMD ["gitlab-ctl reconfigure && gitlab-ctl start"]
