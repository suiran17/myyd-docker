#!/bin/bash

argName=$1
dbdate=$2

#### 表与数据库的映射
declare -A dbs
dbs=(
    [yundun_mcs]='mcs@yundun'
    [yundun_cp]='yundun_cp@yundun'
    [yundun_dns]='yundun_dns@yundun'
    [yundun_api]='yundun_api@yundun'
    [yundun_sso]='yundun_sso@yundun'
    [yundun_cbms]='yundun_cbms@yundun'
    [yundun_tsgz]='yundun_tsgz@yundun'
    [yundun_rbac]='yundun_rbac@yundun'
    [yundun_cp_v4]='yundun_cp_v4@yundun'
    [yundun_admin_v5]='yundun_admin_v5@yundun'
)

#### 数据库连接的映射
declare -A dbConns
dbConns=(
    [yundun]='mysql -h mariadb.uat.nodevops.cn -uuat -pcb6ca8f'
)

#### 变量初始化
dbname=''
dbconn=''
sqlname=${argName}
ignores=()
dbconnKey=''

#### 检查参数是否为指定的数据库
flag="no_exists"
for key in ${!dbs[@]}
do
    if [[ "${key}" == "${argName}" ]]; then
        tmp=${dbs[${argName}]}
        ar=(${tmp//@/ })
        dbname=${ar[0]}
        dbconnKey=${ar[1]}
        flag="exists"
    fi
done
if [[ "${flag}" != "exists" ]]; then
	echo "数据库 ${argName} 不存在！"
    echo "可选择的数据库：${!dbs[@]}"
    exit
fi

### 取出数据库连接配置
flag='no_exists'
for key in ${!dbConns[@]}
do
    if [[ "${key}" == "${dbconnKey}" ]]; then
        flag='exists'
        dbconn=${dbConns[${key}]}
    fi
done
if [[ "${flag}" != "exists" ]]; then
    echo "数据库连接配置不存在"
    exit
fi

#### 导出数据
timeStr=`date "+%Y%m%d_%H%M%S"`
echo "导入数据库[${sqlname}]开始 ${timeStr} `date`"
start=`date "+%s"`
    echo "${dbconn} ${dbname} < ./sql/dump-${sqlname}-${dbdate}.sql"
    sed -i 's|DEFINER=`\w*`@|DEFINER=`uat`@|' ./sql/dump-${sqlname}-${dbdate}.sql
    ${dbconn} ${dbname} < ./sql/dump-${sqlname}-${dbdate}.sql
end=`date "+%s"`
echo "导入数据库[${sqlname}]结束 ${timeStr} `date` 用时" `echo "${end}-${start}" | bc` "秒"

