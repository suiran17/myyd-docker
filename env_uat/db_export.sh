#!/bin/bash

argName=$1
dDate=`date "+%Y%m%d"`

#### 表与数据库的映射
declare -A dbs
dbs=(
    [yundun_mcs]='mcs@mcs'
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
    [mcs]='-h 47.98.60.6 -uydmcser -pn4@jJ27yYgc.V5G0a'
    [yundun]='-h mariadb.yundun.com -ucoder -pK1Jd.8JG_bhK'
    ##[yundun]='-h mariadb.yundun.com -uuat_read -pS8_VCGp#VGPO%SBy'
    ##[yundun]='-h mariadb.yundun.com -uyunwei -pydOps.98F0_0b204e9800A998ecf84'
)

#### 数据库导出时忽视略表的映射
declare -A dbIgnores
dbIgnores=(
    [yundun_sso]='sso_log sso_log_history sso_login_log'
    [yundun_dns]='domain_node_history dnsv4_domain_records_logs'
    [yundun_cp]='user_log member_log dispatch_log dispatch_data waf_dailystats member_login_log admin_operate_log server_monitor_log server_ip_check_log member_domain_ns_record_dns_log'
    [yundun_cp_v4]='cpv4_crontab cpv4_crontab_process cpv4_crontab_server cpv4_crontab_system cpv4_order2 cpv4_log_download  cpv4_message_website cpv4_webcdn_member_log  cpv4_order_20190309_raw cpv4_icpno_interface_log cpv4_transfer_data_error_log cpv4_apiv4_call_data_error_log'
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

tables=()
#### 取出忽略的表
for key in ${!dbIgnores[@]}
do
    echo $key $argName
    if [[ "${key}" == "${argName}" ]]; then
        tmp=${dbIgnores[${argName}]}
        tables=(${tmp})
    fi
done

echo "导出数据库[${sqlname}]开始 ${dDate} `date`"
start=`date "+%s"`

#### 取出全部要忽略的表
tbs=`mysql ${dbconn} -D information_schema -e "select table_name from tables where table_schema='${dbname}'" | grep copy`
tbs=(${tbs[@]} ${tables[@]})
for tb in ${tbs[@]}
do
    ignores+=("--ignore-table=${dbname}.${tb}")
done

#### 导出数据
#echo "mysqldump ${dbconn} `echo ${ignores[@]} | tr '\n' ' '` --events --single-transaction ${dbname} > ./sql/dump-${sqlname}-${dDate}.sql"
mysqldump ${dbconn} `echo ${ignores[@]} | tr '\n' ' '` --events --single-transaction ${dbname} > ./sql/dump-${sqlname}-${dDate}.sql
end=`date "+%s"`
echo "导出数据库[${sqlname}]结束 ${dDate} `date` 用时" `echo "${end}-${start}" | bc` "秒"

