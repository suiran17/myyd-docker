#!/bin/bash

useRateMax=85

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


useRates=`df -k | awk '{print $5}'`

for useRate in $useRates ;
do
if [ $useRate == "Use%" ] || [ $useRate == "已用%" ];then
        continue;
fi
rateStr=${useRate:0:${#useRate}-1};
rateNum=$((10#${rateStr}));
if [ $rateNum -ge $useRateMax ];then
  title="Dev"
  content="【测服磁盘使用率超过$useRateMax%,目前为$useRate】，请联系李德强进行处理！\n\r处理方法：\n\r1.联系李德强(138114900970)"
  sendMsg ${urlPhpDev} ${title} ${content}
  break
fi
done
