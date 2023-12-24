##基础镜像
FROM centos:7

##新镜像维护人
MAINTAINER jingwu

##环境变量 变量值	设置一个环境变量的值，会被后面的RUN使用
ENV LANG C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

##添加文件到镜像
ADD  tpl/apache-maven-3.6.1-bin.tar.gz /root/
COPY tpl/maven_setting.xml             /root/

##在镜像中执行命令
RUN yum -y install wget which zip unzip java java-devel \
    #maven安装
    && cp -R /root/apache-maven-3.6.1 /usr/local/ \
    && ln -s /usr/local/apache-maven-3.6.1/bin/mvn /usr/local/bin/mvn \
    && ln -s /usr/local/apache-maven-3.6.1/bin/mvnyjp /usr/local/bin/mvnyjp \
    && ln -s /usr/local/apache-maven-3.6.1/bin/mvnDebug /usr/local/bin/mvnDebug \
    && cp /root/maven_setting.xml /usr/local/apache-maven-3.6.1/conf/settings.xml \
    && yum clean all \
    ## 清理文件
    && rm -rf /root/apache-maven-3.6.1 \
    && rm -rf /root/maven_setting.xml \

##运行时用户名/UID
#USER 

##工作目录, RUN/CMD/ENTRYPOINT
WORKDIR /root/

##创建挂载点
#VOLUME["目录"]

##构建镜像时运行命令
#ONBUILD

##当启动容器时执行的脚本文件
#CMD ["命令"]

