##基础镜像
FROM docker.io/jingwu/java:v1.8

##新镜像维护人
MAINTAINER jingwu

##设定参数
ARG  db_host=172.16.100.70
ARG  db_port=3306
ARG  db_name=apollo_config_dev
ARG  db_user=devops
ARG  db_password=devops123456..
ARG  server_port_config=10001
ARG  server_port_admin=10002

##开启的端口
EXPOSE 10001
EXPOSE 10002

##环境变量 变量值	设置一个环境变量的值，会被后面的RUN使用
ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

##添加文件到镜像
#http://mirror.bit.edu.cn/apache/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz
ADD  tpl/apollo-1.4.0.tar.gz           /root/

##在镜像中执行命令
RUN sleep 1 \
    #配置 apollo_config
    && sed -i "s|^apollo_config_db_url.*$|apollo_config_db_url=jdbc:mysql://${db_host}:${db_port}/${db_name}?characterEncoding=utf8|" /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^apollo_config_db_username.*$|apollo_config_db_username=${db_user}|"           /root/apollo-1.4.0/scripts/build.sh \
    && sed -i "s|^apollo_config_db_password.*$|apollo_config_db_password=${db_password}|"       /root/apollo-1.4.0/scripts/build.sh \

    #编译
    && sh /root/apollo-1.4.0/scripts/build.sh \

    #安装apollo_config
    && unzip /root/apollo-1.4.0/apollo-configservice/target/apollo-configservice-1.4.0-SNAPSHOT-github.zip -d /usr/local/apollo-configservice-1.4.0/ \
    && sed -i "s|^SERVER_PORT.*$|SERVER_PORT=${server_port_config}|" /usr/local/apollo-configservice-1.4.0/scripts/startup.sh \
    && sed -i "s|exit 0;||"                                          /usr/local/apollo-configservice-1.4.0/scripts/startup.sh \
    && chmod +x                                                      /usr/local/apollo-configservice-1.4.0/scripts/startup.sh \
    #安装apollo_admin
    && unzip /root/apollo-1.4.0/apollo-adminservice/target/apollo-adminservice-1.4.0-SNAPSHOT-github.zip -d /usr/local/apollo-adminservice-1.4.0/ \
    && sed -i "s|^SERVER_PORT.*$|SERVER_PORT=${server_port_admin}|" /usr/local/apollo-adminservice-1.4.0/scripts/startup.sh \
    && sed -i "s|exit 0;||"                                         /usr/local/apollo-adminservice-1.4.0/scripts/startup.sh \
    && chmod +x                                                     /usr/local/apollo-adminservice-1.4.0/scripts/startup.sh \
    #启动脚本
    && echo "#!/bin/bash"                                                       >> /root/apollo_startup.sh \
    && echo "nohup /usr/local/apollo-adminservice-1.4.0/scripts/startup.sh &"   >> /root/apollo_startup.sh \
    && echo "nohup /usr/local/apollo-configservice-1.4.0/scripts/startup.sh &"  >> /root/apollo_startup.sh \
    && echo "tail -f /dev/null"                                                 >> /root/apollo_startup.sh \
    && chmod +x                                                                    /root/apollo_startup.sh \
    ##清理文件
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

