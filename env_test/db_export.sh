#!/bin/bash

mysqlDbs(){
    dbConn="$1"
    dbs=$(mysql ${dbConn} -e "show databases;" | grep -v Database | grep -v information_schema | grep -v mysql | grep -v performance_schema)
    echo ${dbs[*]}
}

mysqlExport(){
    dbConn="$1"
    dbName="$2"
    bakDir="$3"
    dDate=`date "+%Y%m%d"`
    bakFile=${bakDir}/dump-${dbName}-${dDate}.sql
    dbs=$(mysql ${dbConn} -e "show databases;" | grep -v Database | grep -v information_schema | grep -v mysql | grep -v performance_schema)

    #### 检查参数是否为指定的数据库
    flag='no_exists'
    for key in ${dbs[@]}
    do
        if [[ "${key}" == "${dbName}" ]]; then
            dbName=${key}
            flag='exists'
        fi
    done
    if [[ "${flag}" == "not_exists" ]]; then
    	echo "数据库 ${dbName} 不存在！"
        echo "可选择的数据库：${dbs[@]}"
        return
    fi
    
    echo "导出数据库[${dbName}]开始 ${dDate} `date`"
    start=`date "+%s"`
    
    #### 导出数据
    #echo "mysqldump ${dbconn} --events --single-transaction ${dbName} > ${bakFile}"
    mysqldump ${dbConn} --events --single-transaction ${dbName} > ${bakFile}
    gzip -f ${bakFile}
    end=`date "+%s"`
    echo "导出数据库[${dbName}]结束 ${dDate} `date` 用时" `echo "${end}-${start}" | bc` "秒"
}

##数据备份
dbConn='-h mysql.test.nodevops.cn -uphp -pku5Ne(szK4'
for key in $(mysqlDbs "${dbConn}")
do
    mysqlExport "${dbConn}" $key /data/backup/
done

##数据同步
rsync -avt /data/backup/ root@172.16.100.116:/data/backup/

