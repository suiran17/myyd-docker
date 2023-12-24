##基础镜像
FROM docker.io/jingwu/java:v1.8

##新镜像维护人
MAINTAINER jingwu

##设定参数
ARG  db_host=172.16.100.242
ARG  db_port=3306
ARG  db_name=apollo_portal
ARG  db_user=apollo
ARG  db_password=FNUyOTtcTMV_zi9m
ARG  api_config_local=http://172.16.100.188:10001
ARG  api_config_dev=http://172.16.100.188:10011
ARG  api_config_fat=http://172.16.100.188:10021
ARG  api_config_lpt=http://172.16.100.188:10031
ARG  api_config_uat=http://172.16.100.200:10041
ARG  api_config_pro=http://172.16.100.200:10051
ARG  server_port=10000

##开启的端口
EXPOSE 10000

##环境变量 变量值	设置一个环境变量的值，会被后面的RUN使用
ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

##添加文件到镜像
#http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz
ADD  tpl/apollo-1.4.0.tar.gz           /root/

##在镜像中执行命令
RUN sleep 1 \ 
    #配置 apollo_portal
    && sed -i "s|^apollo_portal_db_url.*$|apollo_portal_db_url=jdbc:mysql://${db_host}:${db_port}/${db_name}?characterEncoding=utf8|" /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^apollo_portal_db_username.*$|apollo_portal_db_username=${db_user}|"           /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^apollo_portal_db_password.*$|apollo_portal_db_password=${db_password}|"       /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^local_meta.*$|local_meta=${api_config_local}|"  /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^dev_meta.*$|dev_meta=${api_config_dev}|"        /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^fat_meta.*$|fat_meta=${api_config_fat}|"        /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^lpt_meta.*$|lpt_meta=${api_config_lpt}|"        /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^uat_meta.*$|uat_meta=${api_config_uat}|"        /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^pro_meta.*$|pro_meta=${api_config_pro}|"        /root/apollo-1.4.0/scripts/build.sh \
    #编译apollo_portal
    && sh /root/apollo-1.4.0/scripts/build.sh \
    #安装apollo_portal
    && unzip /root/apollo-1.4.0/apollo-portal/target/apollo-portal-1.4.0-SNAPSHOT-github.zip -d /usr/local/apollo-portal-1.4.0 \
    && sed -i "s|^SERVER_PORT.*$|SERVER_PORT=${server_port}|"     /usr/local/apollo-portal-1.4.0/scripts/startup.sh \
    && sed -i "s|exit 0;|tail -f /dev/null|"                      /usr/local/apollo-portal-1.4.0/scripts/startup.sh \
    && chmod +x                                                   /usr/local/apollo-portal-1.4.0/scripts/startup.sh \
    #启动脚本
    && echo "#!/bin/bash"                                               >> /root/apollo_startup.sh \
    && echo "nohup /usr/local/apollo-portal-1.4.0/scripts/startup.sh &" >> /root/apollo_startup.sh \
    && echo "tail -f /dev/null"                                         >> /root/apollo_startup.sh \
    && chmod +x                                                            /root/apollo_startup.sh \
    #清理文件
    && rm -rf /root/apollo-1.4.0*

##运行时用户名/UID
#USER 
##工作目录, RUN/CMD/ENTRYPOINT
WORKDIR  /root/

##创建挂载点
#VOLUME["目录"]

##构建镜像时运行命令
#ONBUILD

##当启动容器时执行的脚本文件
CMD ["/root/apollo_startup.sh"]
