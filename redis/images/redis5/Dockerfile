FROM redis:5

##开启的端口
EXPOSE 6379
EXPOSE 26379

RUN mkdir /etc/redis \
  && mkdir /var/log/redis \
  && chown -R redis.root /etc/redis \
  && chown -R redis.root /var/log/redis \
  && echo "vm.overcommit_memory=1" >> /etc/sysctl.conf \
  && echo "net.core.somaxconn= 1024" >> /etc/sysctl.conf
VOLUME ["/etc/redis/", "/data/", "/var/log/redis/"]
WORKDIR /data
#CMD ["redis-server", "/etc/redis/redis.conf"]
