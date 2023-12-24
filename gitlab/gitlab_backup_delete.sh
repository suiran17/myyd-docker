#!/bin/bash
#### 定时删除30天前的备份，并同步到备份机
#### 删除只在当前机器上执行，不做同步操作

date
beforeDay=$1
if [[ ${beforeDay} -lt 15 ]]; then
    echo "最少要保存15天的备份数据"
    beforeDay=15
fi
backupDate=`date '+%Y_%m_%d' -d '-'${beforeDay}'days'`
files=`ls /data/docker/gitlab/opt/backups/*_${backupDate}_*_gitlab_backup.tar`
ret=$?
if [ ${ret} == 0 ]; then
    for bfile in ${files[@]}; do
        if [ -f "${bfile}" ]; then
            echo "存在备份文件：${bfile}，执行删除动作"
            ls ${bfile}
            rm -rf ${bfile}
        else
            echo "不存在备份文件：${bfile}"
        fi
    done
else
    echo "没有找到匹配的文件"
fi
