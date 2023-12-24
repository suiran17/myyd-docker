ARG PHP_VERSION
FROM ${PHP_VERSION}

ARG TZ
ARG PHP_EXTENSIONS
ARG CONTAINER_PACKAGE_URL


COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions

### 添加www用户
RUN adduser -D www

#mirror
RUN if [ "${CONTAINER_PACKAGE_URL}" != "" ]; then \
        sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories; \
    fi

#cache
RUN  apk update \
     && apk upgrade

#git
RUN apk add git

# php extension depend
RUN if [ "${PHP_EXTENSIONS}" != "" ]; then \
        apk add --no-cache autoconf g++ libtool make curl-dev linux-headers; \
    fi

#php extension
RUN chmod +x install.sh && sh install.sh && rm -rf /tmp/extensions

#timezone
RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && apk del tzdata


# Fix: https://github.com/docker-library/php/issues/240
RUN apk add gnu-libiconv --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

#Install-Composer
COPY ./composer /tmp/composer
WORKDIR /tmp/composer
RUN cp /tmp/composer/composer.phar /usr/bin/composer \
	&& chmod +x /usr/bin/composer \
	&& rm -rf /tmp/composer \
	&& composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

#Install-Composer latestest from official script
#RUN curl -sS https://getcomposer.org/installer | \
#    php -- --install-dir=/usr/bin/ --filename=composer \
#    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

#clear
RUN  rm -rf /var/cache/apk/*

WORKDIR /www
