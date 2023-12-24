#
# PHP source directory
#
#SOURCE_DIR=./www
SOURCE_DIR=/data/www


# 内部网络固定IP
DOCKER_SUBNET=172.1.0.0/16
NGINX_IP=172.1.0.10
PHP72_IP=172.1.0.11
MYSQL_IP=172.1.0.12

# HOST
SSO_HOST=sso-backend-server.pre.nodevops.cn
APIV4_HOST=yundunapiv4.pre.nodevops.cn
APIV3_HOST=yundunapi.pre.nodevops.cn
APIV5_HOST=adminv5api.pre.nodevops.cn
YD_HOST=mariadb.yundun.com:172.16.100.165

#
# Container Timezone
#
TZ=Asia/Shanghai

#
# Container package fetch url
#
# Can be empty, followings or others:
# mirrors.163.com
# mirrors.aliyun.com
# mirrors.ustc.edu.cn
#
CONTAINER_PACKAGE_URL=mirrors.aliyun.com

#
# Nginx
#
NGINX_VERSION=1.15.7-alpine
NGINX_HTTP_HOST_PORT=80
NGINX_HTTPS_HOST_PORT=443
NGINX_CONFD_DIR=./services/nginx/conf.d/pro
NGINX_CONF_FILE=./services/nginx/nginx.conf
NGINX_SSL_CERTIFICATE_DIR=./services/nginx/ssl
NGINX_LOG_DIR=./logs/nginx
# Available apps: certbot
NGINX_INSTALL_APPS=



#
# PHP7
#
# Available PHP_EXTENSIONS:
#
# pdo_mysql,zip,pcntl,mysqli,mbstring,exif,bcmath,calendar,
# sockets,gettext,shmop,sysvmsg,sysvsem,sysvshm,pdo_rebird,
# pdo_dblib,pdo_oci,pdo_odbc,pdo_pgsql,pgsql,oci8,odbc,dba,
# gd,intl,bz2,soap,xsl,xmlrpc,wddx,curl,readline,snmp,pspell,
# recode,tidy,gmp,imap,ldap,imagick,sqlsrv,mcrypt,opcache,
# redis,memcached,xdebug,swoole,pdo_sqlsrv,sodium,yaf,mysql,
# amqp,mongodb,event,rar,ast,yac,yaconf,msgpack,igbinary,
# seaslog,varnish,yaml,memcache
#
# You can let it empty to avoid installing any extensions,
# or install multi plugins as:
# PHP_EXTENSIONS=pdo_mysql,mysqli,gd,curl,opcache
#
PHP_VERSION=7.2.19
PHP_PHP_CONF_FILE=./services/php/php.ini
PHP_FPM_CONF_FILE=./services/php/php-fpm.conf
PHP_LOG_DIR=./logs/php
PHP_EXTENSIONS=pdo_mysql,pcntl,mysqli,mbstring,bcmath,gd,swoole,amqp,mongodb,curl,opcache,memcached,redis,sockets,yaml,memcache


#
# MySQL8
#
MYSQL_VERSION=8.0.13
MYSQL_HOST_PORT=3306
MYSQL_ROOT_PASSWORD=123456
MYSQL_DATA_DIR=./data/mysql
MYSQL_CONF_FILE=./services/mysql/mysql.cnf

