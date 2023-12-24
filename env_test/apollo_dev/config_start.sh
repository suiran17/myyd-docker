#!/bin/bash
##用到的所有的变量均来自docker中定义的环境变量

cd ${CONFIG_DIR}
unzip apollo-configservice-1.6.1-github.zip

## apollo-configservice.conf
sed -i "s|^LOG_FOLDER.*$|LOG_FOLDER=${CONFIG_LOG_DIR}|"   ${CONFIG_DIR}/apollo-configservice.conf

## application-github.properties
datasource="jdbc:mysql://${CONFIG_DB_HOST}:${CONFIG_DB_PORT}/${CONFIG_DB_NAME}?characterEncoding=utf8"
sed -i "s|^spring.datasource.url.*$|spring.datasource.url=${datasource}|"                   ${CONFIG_DIR}/config/application-github.properties
sed -i "s|^spring.datasource.username.*$|spring.datasource.username=${CONFIG_DB_USER}|"     ${CONFIG_DIR}/config/application-github.properties
sed -i "s|^spring.datasource.password.*$|spring.datasource.password=${CONFIG_DB_PASSWORD}|" ${CONFIG_DIR}/config/application-github.properties

## startup.sh
sed -i "s|^SERVER_PORT.*$|SERVER_PORT=${CONFIG_SERVER_PORT}|"                             ${CONFIG_DIR}/scripts/startup.sh
sed -i "s|^SERVER_URL.*$|SERVER_URL=http://${CONFIG_SERVER_HOST}:${CONFIG_SERVER_PORT}|"  ${CONFIG_DIR}/scripts/startup.sh

nohup ${CONFIG_DIR}/scripts/startup.sh &
tail -f /dev/null
