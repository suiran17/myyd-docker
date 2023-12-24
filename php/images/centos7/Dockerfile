ARG IMAGE
FROM ${IMAGE}

#mirror
RUN cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && sed -i s/^mirrorlist/#mirrorlist/ /etc/yum.repos.d/CentOS-Base.repo \
    && sed -i s/#baseurl/baseurl/ /etc/yum.repos.d/CentOS-Base.repo \
    && sed -i s/mirror.centos.org/mirrors.tuna.tsinghua.edu.cn/ /etc/yum.repos.d/CentOS-Base.repo

#RUN cat  /etc/yum.repos.d/CentOS-Base.repo
RUN yum makecache
RUN yum update -y
RUN yum install -y autoconf gcc-c++ gcc libtool make linux-headers libcurl-devel git vim file wget libmcrypt libmcrypt-devel mcrypt mhash \
    && wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

## 包更新及配置
ARG PKGS
RUN yum install -y ${PKGS}

###python安装及配置
COPY ./soft/Python-3.8.2.tar.xz /root/
RUN cd /root/ && tar -xf Python-3.8.2.tar.xz \
    && yum install -y libffi-devel tk-devel \
    && cd Python-3.8.2 && ./configure && make && make install && ln -s /usr/local/bin/pip3 /usr/local/bin/pip && cd ../ \
    && echo "" > /etc/pip.conf \
    && echo "[global]" >> /etc/pip.conf \
    && echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf \
    && echo "[install]" >> /etc/pip.conf \
    && echo "trusted-host = https://pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf \
    && pip install --upgrade pip \
    && pip install pipenv

###php源码中扩展安装
ARG PHP_VERSION
COPY ./soft/re2c-2.0.3.tar.xz /tmp/
RUN cd /tmp && tar -xf re2c-2.0.3.tar.xz && cd re2c-2.0.3 \
&& ./configure && make && make install

COPY ./soft/cmake-3.18.2.tar.gz /tmp/
RUN cd /tmp && tar -xf cmake-3.18.2.tar.gz && cd cmake-3.18.2 \
&& ./bootstrap && make && make install

COPY ./soft/libzip-1.7.3.tar.xz /tmp/
RUN cd /tmp && tar -xf libzip-1.7.3.tar.xz && cd libzip-1.7.3 \
&& mkdir build && cd build && cmake .. && make && make install

RUN echo '/usr/local/lib64' >> /etc/ld.so.conf \
&& echo '/usr/local/lib' >> /etc/ld.so.conf \
&& echo '/usr/lib64' >> /etc/ld.so.conf \
&& echo '/usr/lib' >> /etc/ld.so.conf \
&& ldconfig -v


COPY ./soft/${PHP_VERSION}.tar.xz /root/
RUN cd /root/ && tar -xf ${PHP_VERSION}.tar.xz && cd ${PHP_VERSION} \
&& ./configure  --prefix=/usr/local/${PHP_VERSION} \
    --with-config-file-path=/usr/local/${PHP_VERSION}/etc/ \
    --with-config-file-scan-dir=/usr/local/${PHP_VERSION}/etc/php.d \
    --with-openssl \
    --enable-fpm \
    --enable-sockets \
    --enable-sysvshm \
    --enable-mbstring \
    --with-freetype-dir=/usr \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib-dir \
    --with-libxml-dir=/usr/lib64/ \
    --enable-xml \
    --with-mhash \
    --with-curl \
    --with-bz2 \
    --with-libzip \
    --with-gd \
    --enable-zip \
    --enable-pcntl \ 
    --enable-pdo \
    --enable-soap \
    --with-pdo-mysql \
    --disable-cgi \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-zlib \
    --with-jpeg-dir=shared \
    --with-png-dir=shared \
    --without-pear \
    && make \
    && make install \
    && ln -s /usr/local/${PHP_VERSION}       /usr/local/php \
    && ln -s /usr/local/php/bin/php          /usr/bin/php \
    && ln -s /usr/local/php/bin/phpize       /usr/bin/phpize \
    && ln -s /usr/local/php/bin/php-config   /usr/bin/php-config \
    && ln -s /usr/local/php/bin/pear         /usr/bin/pear \
    && ln -s /usr/local/php/bin/pecl         /usr/bin/pecl \
    && ln -s /usr/local/php/bin/phar         /usr/bin/phar \
    && ln -s /usr/local/php/sbin/php-fpm     /usr/bin/php-fpm \
    && ln -s /usr/local/php/bin/php          /usr/local/bin/php \
    && ln -s /usr/local/php/bin/phpize       /usr/local/bin/phpize \
    && ln -s /usr/local/php/bin/php-config   /usr/local/bin/php-config \
    && ln -s /usr/local/php/bin/pear         /usr/local/bin/pear \
    && ln -s /usr/local/php/bin/pecl         /usr/local/bin/pecl \
    && ln -s /usr/local/php/bin/phar         /usr/local/bin/phar \
    && ln -s /usr/local/php/sbin/php-fpm     /usr/local/bin/php-fpm
COPY ./soft/go-pear.phar /root/
RUN /usr/bin/php /root/go-pear.phar

## 标准扩展安装
ARG EXT_SRC
RUN for ext in ${EXT_SRC}; do cd /root/${PHP_VERSION}/ext/${ext}; phpize; ./configure; make; make install; done

##composer安装及配置
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

COPY ./soft/libdatrie-0.2.11.tar.xz /root/
RUN cd /root && tar -xf libdatrie-0.2.11.tar.xz && cd libdatrie-0.2.11 \
&& ./configure && make && make install

##非标准扩展安装
ARG EXT_OUT
RUN mkdir /root/ext
COPY ./soft/ext /root/ext
RUN cd /root/ext/ && ls *.tgz | xargs -I{} tar -xf {} \
    && for ext in ${EXT_OUT}; do cd ${ext}; phpize; ./configure; make; make install; cd ../; done

## 基础的文件路经(配置及日志)
RUN useradd www
RUN mkdir -p /var/log/php \
    && chown -R www.www /var/log/php \
    && mkdir -p /usr/local/${PHP_VERSION}/etc/php.d \
    && cp /root/${PHP_VERSION}/php.ini-production /etc/php.ini \
    && cp /usr/local/${PHP_VERSION}/etc/php-fpm.conf.default /usr/local/${PHP_VERSION}/etc/php-fpm.conf \
    && cp /usr/local/${PHP_VERSION}/etc/php-fpm.d/www.conf.default /usr/local/${PHP_VERSION}/etc/php-fpm.d/www.conf \
    && sed -i 's/;daemonize = yes/daemonize = no/' /usr/local/${PHP_VERSION}/etc/php-fpm.conf

## 安装扩展与配置扩展分离
ARG EXT_ENABLE
RUN for ext in ${EXT_ENABLE}; do echo "extension=${ext}.so" > /usr/local/${PHP_VERSION}/etc/php.d/${ext}.ini; done
RUN for ext in ${ZEND_EXT_ENABLE}; do echo "zend_extension=${ext}.so" > /usr/local/${PHP_VERSION}/etc/php.d/${ext}.ini; done

## 为crontab_processd 安装必要的扩展
RUN pip3 install click ifcfg sqlalchemy pymysql setproctitle greenstalk

## 针对不同的环境做软链
RUN mkdir /root/script \
    && mkdir /usr/local/nginx-1.8.1 \
    && ln -s /www /usr/local/nginx-1.8.1/html \
    && mkdir /www001 && chown -R www.www /www001 \
    && mkdir /www003 && chown -R www.www /www003 \
    && mkdir /var/log/yundun \
    && mkdir /var/log/nsq && chown -R www.www /var/log/nsq \
    && mkdir /var/log/php-fpm-log  && chown -R www.www /var/log/php-fpm-log

#RUN rm -rf /tmp/*

EXPOSE 9500-9599

## 添加www用户
ENV APPLICATION_ENV=''
WORKDIR /www

## 针对不同的环境做软链
RUN git config --global user.email "lideqiang@yundun.com" \
    && git config --global user.name "lideqiang" \
    && mkdir -p /xhprof \
    && cp -R /root/ext/xhprof-2.3.3/* /xhprof/
