ARG IMAGE
FROM ${IMAGE}

ARG PKGS
ARG RESTY_LIBS
ARG NGINX_VERSION
ARG LUAJIT_VERSION
ARG LUA_NGINX_VERSION
ARG NGX_DEVEL_KIT_VERSION

##开启的端口
##EXPOSE 80
##EXPOSE 443

## 文件映射
#VOLUME ["/etc/nginx/nginx.conf", "/etc/nginx/conf.d/", "/etc/nginx/ssl", "/var/log/nginx/"]

COPY ./soft /tmp/

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
&& apk update  && apk upgrade \
&& apk add --no-cache tzdata autoconf g++ gcc \
&& cp "/usr/share/zoneinfo/Asia/Shanghai" /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& apk add --no-cache ${PKGS} \
&& adduser -D nginx \
&& cd /tmp \
&& ls *.tar.gz | xargs -I{} tar -xf {} \
&& cd /tmp/${LUAJIT_VERSION} \
&& make install PREFIX=/usr/local/luajit \
&& echo "" > /etc/profile.d/lua.sh \
&& echo "export LUAJIT_LIB=/usr/local/luajit/lib" >> /etc/profile.d/lua.sh \
&& echo "export LUAJIT_INC=/usr/local/luajit/include/luajit-2.1" >> /etc/profile.d/lua.sh \
&& source /etc/profile.d/lua.sh \
&& cd /tmp/${NGINX_VERSION} \
&& ./configure \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib/nginx/modules \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_auth_request_module \
--with-http_xslt_module=dynamic \
--with-http_image_filter_module=dynamic \
--with-http_geoip_module=dynamic \
--with-threads \
--with-stream \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-stream_realip_module \
--with-stream_geoip_module=dynamic \
--with-http_slice_module \
--with-mail \
--with-mail_ssl_module \
--with-compat \
--with-http_v2_module \
--with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib" \
--add-module=/tmp/${NGX_DEVEL_KIT_VERSION} \
--add-module=/tmp/${LUA_NGINX_VERSION} \
&& make -j2 \
&& make install

RUN mkdir -p /var/cache/nginx/client_temp \
&& for row in ${RESTY_LIBS}; do cp -R /tmp/${row}/lib/* /usr/local/luajit/share/lua/5.1/; done \
&& echo "#!/bin/sh"           > /docker-entrypoint.sh \
&& echo "nginx"              >> /docker-entrypoint.sh \
&& echo "tail -f /dev/null"  >> /docker-entrypoint.sh \
&& chmod +x /docker-entrypoint.sh

##运行时用户名/UID

#RUN rm -rf /tmp/*

## 工作目录
WORKDIR /

ENTRYPOINT ["/docker-entrypoint.sh"]

## 增加8888监听端口
##EXPOSE 8888

#CMD []
