ARG IMAGE
FROM ${IMAGE}

ARG PKGS
ARG EXT_SRC
ARG EXT_OUT
ARG EXT_ENABLE

ENV APPLICATION_ENV=''

COPY ./soft /tmp/

#mirror
## apk更新及配置
## 添加www用户
###php源码中扩展安装
RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g" /etc/apk/repositories \
&& apk update  && apk upgrade \
&& apk add --no-cache autoconf g++ gcc libtool make linux-headers tzdata file curl-dev re2c git vim \
&& cp "/usr/share/zoneinfo/Asia/Shanghai" /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& apk del tzdata \
&& adduser -D www \
&& apk add --no-cache ${PKGS} \
&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
&& for ext in ${EXT_SRC}; do docker-php-ext-install ${ext}; done

###非标准扩展安装
RUN cd /tmp/ext/ && ls *.tgz | xargs -I{} tar -xf {} \
&& for ext in ${EXT_OUT}; do cd ${ext}; phpize; ./configure; make; make install; cd ../; done

## 配置相应的扩展
RUN docker-php-ext-enable ${EXT_ENABLE}

##composer安装及配置
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
&& composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

##python安装及配置
RUN cd /tmp/ \
&& ls *.tar.xz | xargs -I{} tar -xf {} \
&& apk add --no-cache libffi-dev tk-dev openssl \
&& cd Python-3.8.2 && ./configure && make && make install && ln -s /usr/local/bin/pip3 /usr/local/bin/pip && cd ../ \
&& echo "" > /etc/pip.conf \
&& echo "[global]" >> /etc/pip.conf \
&& echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf \
&& echo "[install]" >> /etc/pip.conf \
&& echo "trusted-host = https://pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf \
&& pip install --upgrade pip \
&& pip install pipenv

RUN rm -rf /tmp/*

## Fix: https://github.com/docker-library/php/issues/240
#RUN apk add gnu-libiconv --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/edge/community/ --allow-untrusted
#ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

WORKDIR /www
