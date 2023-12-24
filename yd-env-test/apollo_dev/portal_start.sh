#!/bin/bash
##用到的所有的变量均来自docker中定义的环境变量

cd ${PORTAL_DIR}
unzip apollo-portal-1.6.1-github.zip

## apollo-portal.conf
sed -i "s|^LOG_FOLDER.*$|LOG_FOLDER=${PORTAL_LOG_DIR}|"   ${PORTAL_DIR}/apollo-portal.conf

## application-github.properties
datasource="jdbc:mysql://${PORTAL_DB_HOST}:${PORTAL_DB_PORT}/${PORTAL_DB_NAME}?characterEncoding=utf8"
sed -i "s|^spring.datasource.url.*$|spring.datasource.url=${datasource}|"                     ${PORTAL_DIR}/config/application-github.properties
sed -i "s|^spring.datasource.username.*$|spring.datasource.username=${PORTAL_DB_USER}|"       ${PORTAL_DIR}/config/application-github.properties
sed -i "s|^spring.datasource.password.*$|spring.datasource.password=${PORTAL_DB_PASSWORD}|"   ${PORTAL_DIR}/config/application-github.properties

## apollo-env.properties
sed -i "s|^local.meta.*$|local.meta=${LOCAL_META}|"   ${PORTAL_DIR}/config/apollo-env.properties
sed -i "s|^dev.meta.*$|dev.meta=${DEV_META}|"         ${PORTAL_DIR}/config/apollo-env.properties
sed -i "s|^fat.meta.*$|fat.meta=${FAT_META}|"         ${PORTAL_DIR}/config/apollo-env.properties
sed -i "s|^lpt.meta.*$|lpt.meta=${LPT_META}|"         ${PORTAL_DIR}/config/apollo-env.properties
sed -i "s|^uat.meta.*$|uat.meta=${UAT_META}|"         ${PORTAL_DIR}/config/apollo-env.properties
sed -i "s|^pre.meta.*$|pro.meta=${PRE_META}|"         ${PORTAL_DIR}/config/apollo-env.properties
sed -i "s|^pro.meta.*$|pro.meta=${PRO_META}|"         ${PORTAL_DIR}/config/apollo-env.properties

## startup.sh
sed -i "s|^SERVER_PORT.*$|SERVER_PORT=${PORTAL_SERVER_PORT}|"                             ${PORTAL_DIR}/scripts/startup.sh
sed -i "s|^SERVER_URL.*$|SERVER_URL=http://${PORTAL_SERVER_HOST}:${PORTAL_SERVER_PORT}|"  ${PORTAL_DIR}/scripts/startup.sh

nohup ${PORTAL_DIR}/scripts/startup.sh &
tail -f /dev/null
