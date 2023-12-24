#!/bin/bash

source /etc/profile
#根据是否初始化，执行不同的动作
if [ ! -f "${PGDATA}/pg_hba.conf" ]; then
    #不存在，初始化

    cfilePostgresql="${PGDATA}/postgresql.conf"
    cfilePgHba="${PGDATA}/pg_hba.conf"
    /usr/pgsql-11/bin/pg_ctl init
    grep '^listen_addresses' ${cfilePostgresql} && sed -i "s/^listen_addresses.*$/listen_addresses = '*'/" ${cfilePostgresql} || sed -i "/#listen_addresses/i\listen_addresses = '*'" ${cfilePostgresql}
    grep '^unix_socket_directories' ${cfilePostgresql} && sed -i "s/^unix_socket_directories.*$/unix_socket_directories = '\/tmp'/" ${cfilePostgresql} || sed -i "/#unix_socket_directories/i\unix_socket_directories = '\/tmp'" ${cfilePostgresql}
    grep '^host\s*all\s*all\s*0.0.0.0/0' ${cfilePgHba} && sed -i "s/^host\s*all\s*all\s*0.0.0.0\/0\s.*$/host    all             all             0.0.0.0\/0               md5/" ${cfilePgHba} || sed -i "/^host\s*all\s*all\s*127/a\host    all             all             0.0.0.0\/0               md5" ${cfilePgHba}
    ##本机登录不用密码
    #&& sed -i '/^host\s*all\s*all/s/trust/md5/' ${cfilePgHba}
    ##启动，修改 postgres 密码
    /usr/pgsql-11/bin/pg_ctl start
    ##重置 postgres 密码
    psql "host=127.0.0.1 port=5432 user=postgres" -c "alter user postgres with password 'dbadmin';"
    ##停止服务
    /usr/pgsql-11/bin/pg_ctl stop
fi

#存在，启动
/usr/pgsql-11/bin/pg_ctl start
tail -f /dev/null
