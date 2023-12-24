#!/bin/bash


##yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
### Install PostgreSQL:
##yum install -y postgresql11

act=$1

if [ "${act}" == "export" ]; then
    now=`date '+%Y%m%d%H%M%S'`
    backupDir=/data/backup
    cd ${backupDir}
    backupName=dump_postgres_${now}
    mkdir -p ${backupDir}/${backupName}
    ##正式数据
    ## kong
    host=172.16.100.200; port=5432; user=kong; password=f334ed0e3; dbname=kong;
    pg_dump "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f ${backupDir}/${backupName}/${dbname}.sql
    host=172.16.100.200; port=5432; user=konga; password=konga123; dbname=konga;
    pg_dump "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f ${backupDir}/${backupName}/${dbname}.sql

    ####予发布数据
    ##host=172.16.100.111; port=5432; user=kongpre; password=kongpre123456..; dbname=kongpre;
    ##pg_dump "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f ${backupDir}/${backupName}/${dbname}.sql
    ##host=172.16.100.111; port=5432; user=kongapre; password=kongapre123; dbname=kongapre;
    ##pg_dump "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f ${backupDir}/${backupName}/${dbname}.sql

    tar -zcvf ${backupName}.tar.gz ${backupName}
    rm -rf ${backupName}
    rsync -avt /data/backup/ root@172.16.100.168:/YundunData/backup
fi
if [ "${act}" == "import" ]; then
    backupName=$2
    backupDir=/data/backup
    cd ${backupDir}
    docker cp ${backupName}.tar.gz postgres:/root/
    docker exec -w /root -t postgres tar -xf ${backupName}.tar.gz
    ##正式数据
    ## kong
    host=127.0.0.1; port=5432; user=kong; password=f334ed0e3; dbname=kong;
    echo docker exec -it postgres psql "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f /root/${backupName}/${dbname}.sql
    docker exec -it postgres psql "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f /root/${backupName}/${dbname}.sql
    host=127.0.0.1; port=5432; user=konga; password=konga123; dbname=konga;
    echo docker exec -it postgres psql "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f /root/${backupName}/${dbname}.sql
    docker exec -it postgres psql "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f /root/${backupName}/${dbname}.sql

    ####予发布数据
    ##host=127.0.0.1; port=5432; user=kongpre; password=kongpre123456..; dbname=kongpre;
    ##docker exec -it postgres psql "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f /root/${backupName}/${dbname}.sql
    ##host=127.0.0.1; port=5432; user=kongapre; password=kongapre123; dbname=kongapre;
    ##docker exec -it postgres psql "host=${host} port=${port} user=${user} password=${password} dbname=${dbname}" -f /root/${backupName}/${dbname}.sql
fi
