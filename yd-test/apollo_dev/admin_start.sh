#!/bin/bash
##用到的所有的变量均来自docker中定义的环境变量

cd ${ADMIN_DIR}
unzip apollo-adminservice-1.6.1-github.zip

## apollo-adminservice.conf
sed -i "s|^LOG_FOLDER.*$|LOG_FOLDER=${ADMIN_LOG_DIR}|"   ${ADMIN_DIR}/apollo-adminservice.conf

## application-github.properties
datasource="jdbc:mysql://${CONFIG_DB_HOST}:${CONFIG_DB_PORT}/${CONFIG_DB_NAME}?characterEncoding=utf8"
sed -i "s|^spring.datasource.url.*$|spring.datasource.url=${datasource}|"                   ${ADMIN_DIR}/config/application-github.properties
sed -i "s|^spring.datasource.username.*$|spring.datasource.username=${CONFIG_DB_USER}|"     ${ADMIN_DIR}/config/application-github.properties
sed -i "s|^spring.datasource.password.*$|spring.datasource.password=${CONFIG_DB_PASSWORD}|" ${ADMIN_DIR}/config/application-github.properties

## startup.sh
sed -i "s|^SERVER_PORT.*$|SERVER_PORT=${ADMIN_SERVER_PORT}|" ${ADMIN_DIR}/scripts/startup.sh
sed -i "s|^SERVER_URL.*$|SERVER_URL=http://${ADMIN_SERVER_HOST}:${ADMIN_SERVER_PORT}|" ${ADMIN_DIR}/scripts/startup.sh

nohup ${ADMIN_DIR}/scripts/startup.sh &
tail -f /dev/null
