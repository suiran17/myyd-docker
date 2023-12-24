#!/bin/sh
cp -Rf /etc/kong/plugins/* /usr/local/share/lua/5.1/kong/plugins/
/docker-entrypoint-yd.sh kong docker-start
