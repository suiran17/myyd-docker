#!/bin/bash

act=$1
if [ "${act}" == "install" ]; then
    cfilePostgresql=/var/lib/pgsql/11/data/postgresql.conf
    cfilePgHba=/var/lib/pgsql/11/data/pg_hba.conf

    ##安装
    yum install -y epel-release
    rpm -ivh https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    yum install -y postgresql11-server postgresql11-contrib

    ##初始化及启动
    su - postgres && /usr/pgsql-11/bin/pg_ctl init -D /var/lib/pgsql/11/data/
    su - postgres && /usr/pgsql-11/bin/pg_ctl start -D /var/lib/pgsql/11/data/

    ## 添加 kong 用户，设置密码并授权
    psql "host=127.0.0.1 port=5432 user=postgres dbname=kong" -c "create user kong with password 'f334ed0e3';"
    psql "host=127.0.0.1 port=5432 user=postgres dbname=kong" -c "create database kong owner kong;"
    psql "host=127.0.0.1 port=5432 user=postgres dbname=kong" -c "grant all privileges on database kong to kong;"

    ## 修改 postgres 密码
    psql "host=127.0.0.1 port=5432 user=postgres dbname=kong" -c "alter user postgres with password 'dbadmin';"

    ## 修改配置，listen_addresses  远程连接及密码登录
    grep '^listen_addresses' ${cfilePostgresql} && sed -i 's/^listen_addresses.*$/listen_addresses = "*"/' ${cfilePostgresql} || sed -i '/#listen_addresses/i\listen_addresses = "*" ' ${cfilePostgresql}
    grep '^host\s*all\s*all\s*0.0.0.0/0' ${cfilePgHba} && sed -i 's/^host\s*all\s*all\s*0.0.0.0\/0\s.*$/host    all             all             0.0.0.0\/0               md5/' ${cfilePgHba} || sed -i '/^host\s*all\s*all\s*127/a\host    all             all             0.0.0.0\/0               md5' ${cfilePgHba}
    sed -i '/^host\s*all\s*all/s/peer/md5/' ${cfilePgHba}
    sed -i '/^host\s*all\s*all/s/trust/md5/' ${cfilePgHba}

    ##重启
    su - postgres && /usr/pgsql-11/bin/pg_ctl restart -D /var/lib/pgsql/11/data/

    #psql -U kong -d kong -h 127.0.0.1 -p 5432
    #kong migrations bootstrap

elif [ "${act}" == "start" ]; then
    su - postgres && /usr/pgsql-11/bin/pg_ctl start -D /var/lib/pgsql/11/data/

elif [ "${act}" == "stop" ]; then
    su - postgres && /usr/pgsql-11/bin/pg_ctl stop -D /var/lib/pgsql/11/data/
else
fi
