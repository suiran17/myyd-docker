FROM alpine
RUN apk add --no-cache beanstalkd
RUN mkdir -p /var/lib/beanstalkd/binlog
EXPOSE 11300
ENTRYPOINT ["/usr/bin/beanstalkd"]