#!/bin/bash

#5分钟平均负载阈值
fiveMinuteMax=8.00

oneMinute=`echo $(cat /proc/loadavg | awk '{print $1}')`
fiveMinute=`echo $(cat /proc/loadavg | awk '{print $2}')`
fifteenMinute=`echo $(cat /proc/loadavg | awk '{print $3}')`

urlMasterA='http://monitor.ydsoc.adminv6.com:83/alert?sd=process'
urlPhpDev='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=43a3bcee-0912-4c11-a57e-d108b6b863d9'

function sendMsg(){
 url=$1
 title=$2
 content=$3
 msg=""

 if [ "${url}" == "${urlMasterA}" ]; then
        msg="{\"subject\":\"$title\",\"content\":\"$content\"}"
 elif [ "${url}" == "${urlPhpDev}"  ]; then
        msg="{\"msgtype\":\"text\",\"text\":{\"content\":\"$content\"}}"
 fi
 echo "$msg"
 curl ${url} -i -X POST -H 'Content-Type: application/json' -d "$msg"
}

if [ ${fiveMinute/./} -ge ${fiveMinuteMax/./} ];then
  title="Dev"
  content="【测服5分钟平均负载超过$fiveMinuteMax,目前为$fiveMinute】，请联系李德强进行处理！\n\r处理方法：\n\r1.联系李德强(138114900970)"
  sendMsg ${urlPhpDev} ${title} ${content}
fi