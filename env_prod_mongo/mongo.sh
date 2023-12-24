#!/bin/bash

####cat > /etc/yum.repos.d/mongodb-org-3.4.repo <<EOF
####[mongodb-org-3.4]
####name=MongoDB Repository
####baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.4/x86_64/
####gpgcheck=1
####enabled=1
####gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc
####
#####这里可以修改 gpgcheck=0, 省去gpg验证
####EOF

act=$1

if [ "${act}" == "export" ]; then
    backupDir=/data/backup
    cd ${backupDir}
    backupName=dump_mongo_`date '+%Y%m%d%H%M%S'`
    dbs=(batch cdn disp oplog)
    for db in ${dbs[@]}
    do
        mkdir -p ${backupName}/${db}
        mongodump   -h 172.16.100.200:27017 --forceTableScan -d ${db}  -o ${backupName}/
    done
    tar -zcvf ${backupName}.tar.gz ${backupName}
    rm -rf ${backupName}
    rsync -avt /data/backup/ root@172.16.100.168:/YundunData/backup
fi
if [ "${act}" == "import" ]; then
    #cd  /data/backup
    name=$2
    cp /data/backup/${name}.tar.gz /data/docker/mongo/data/
    cd /data/docker/mongo/data/
    tar -xf ${name}.tar.gz
    for doc in `ls ${name}/`
    do
        echo docker exec -t mongod mongorestore -h 10.102.1.164 -p 27017 -d ${doc} /data/db/${name}/${doc}
        docker exec -t mongod mongo 10.102.1.164:27017/${doc} --eval 'db.dropDatabase();'
        docker exec -t mongod mongorestore -h 10.102.1.164 -p 27017 -d ${doc} /data/db/${name}/${doc}
    done
fi
