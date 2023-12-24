### PHP镜像

#### php7.2

##### php7.2 测试环境安装的扩展

* pdo_mysql pcntl mysqli bcmath gd sockets zip opcache bz2
* swoole amqp mongodb opcache memcache memcached redis yaml mysql xdebug

##### php7.2 预发布环境安装的扩展

* pdo_mysql pcntl mysqli bcmath gd sockets zip opcache bz2
* swoole amqp mongodb opcache memcache memcached redis yaml mysql

##### php7.2 使用的外部扩展版本
* amqp-1.10.2
* mysql-d7643af
* swoole-4.4.18
* memcache-4.0.5.2
* memcached-3.1.5
* mongodb-1.7.4
* redis-5.2.1
* yaml-2.1.0
* xdebug-2.6.1
* xhprof-2.3.3     因xhprof-2.3.3真正的扩展代码目录是 extension，所以在安装扩展时把extension目录做成了压缩包 xhprof-2.3.3-extension.tgz，在docker-compose.yml中用的也是 xhprof-2.3.3-extension

注意：
* mysql 扩展是过期的，只在 NG配置生成 中有用到
* memcache 未来会迁移到 redis

#### php5.6

##### php5.6 线上(未使用docker)安装的扩展

* mysql pdo_mysql pcntl mysqli bcmath gd sockets zip bz2
* swoole amqp mongodb memcache memcached redis yaml mysql

##### php5.6使用的外部扩展版本

* amqp-1.10.2
* swoole-2.0.11
* memcache-2.2.7
* memcached-2.2.0
* mongodb-1.7.4
* redis-4.1.1
* yaml-1.3.0
* xdebug-2.5.5

#### 重新构建镜像
```
make build_php72test

make build_php72pro

make build_php56test

make build_php56pro
```
