##基础镜像
#FROM docker.io/jingwu/kong_basis:v0.1
FROM centos:7

##新镜像维护人
MAINTAINER jingwu

ARG  cfilePostgresql=/var/lib/pgsql/11/data/postgresql.conf
ARG  cfilePgHba=/var/lib/pgsql/11/data/pg_hba.conf

##环境变量 变量值	设置一个环境变量的值，会被后面的RUN使用
ENV PGDATA /var/lib/pgsql/11/data/

##开启的端口
EXPOSE 5432

## 安装 postgresql11
RUN echo "export LC_ALL=en_US.UTF-8" >> /etc/profile \
    && source /etc/profile \
    && useradd postgres \
    && echo "204.145.124.244 download.postgresql.org" >> /etc/hosts \
    && yum install -y epel-release \
    && rpm -ivh https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    && yum install -y postgresql11-server postgresql11-contrib \
    && yum clean all

###添加文件到镜像
ADD pg_start.sh                /home/postgres/
RUN chmod +x /home/postgres/pg_start.sh \
    && chown -R postgres.postgres /home/postgres/

##切换用户到 postgres
USER postgres

##工作目录, RUN/CMD/ENTRYPOINT
WORKDIR  /home/postgres/

##创建挂载点
VOLUME ["/var/lib/pgsql/11/data/"]

##构建镜像时运行命令
#ONBUILD

##当启动容器时执行的脚本文件
CMD ["/home/postgres/pg_start.sh"]

