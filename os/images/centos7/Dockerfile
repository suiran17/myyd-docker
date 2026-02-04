FROM docker.io/centos:7

# RUN cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
# #&& curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# && sed -i s/^mirrorlist/#mirrorlist/ /etc/yum.repos.d/CentOS-Base.repo \
# && sed -i s/#baseurl/baseurl/ /etc/yum.repos.d/CentOS-Base.repo \
# && sed -i s/mirror.centos.org/mirrors.tuna.tsinghua.edu.cn/ /etc/yum.repos.d/CentOS-Base.repo
# #RUN cat  /etc/yum.repos.d/CentOS-Base.repo






#  yum源    2025-08-26 11:03:50
# 2026-02-03 更新：CentOS 7 已 EOL，使用官方归档镜像 vault.centos.org
# 
# 使用 CentOS 官方归档镜像（vault.centos.org）
RUN cat > /etc/yum.repos.d/CentOS-Base.repo <<EOF
[base]
name=CentOS-\$releasever - Base
baseurl=http://vault.centos.org/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1

[updates]
name=CentOS-\$releasever - Updates
baseurl=http://vault.centos.org/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1

[extras]
name=CentOS-\$releasever - Extras
baseurl=http://vault.centos.org/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1

[centosplus]
name=CentOS-\$releasever - Plus
baseurl=http://vault.centos.org/\$releasever/centosplus/\$basearch/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
skip_if_unavailable=1
EOF

# 清理YUM缓存并创建缓存
RUN yum clean all && yum makecache fast

# 配置源 end






RUN yum makecache \
    && yum update -y \
    && yum -y install epel-release \
    && yum install -y gcc gcc-c++ make autoconf automake libtool linux-headers git vim file \
        libcurl-devel curl-devel \
        libxml2 libxml2-devel \
        openssl openssl-devel \
        libjpeg-devel libpng-devel freetype-devel libmcrypt-devel freetype-devel libjpeg-devel libpng-devel \
        librabbitmq-devel libmemcached-devel libyaml-devel libbz2-devel \
        python3 python3-devel python3-pip \
    && yum clean all \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && echo "" > /etc/pip.conf \
    && echo "[global]" >> /etc/pip.conf \
    && echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf \
    && echo "[install]" >> /etc/pip.conf \
    && echo "trusted-host = https://pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf \
    && pip install --upgrade pip

COPY ./soft /tmp/
RUN cd /tmp && tar -xf cmake-3.18.2.tar.gz && cd cmake-3.18.2 \
    && ./bootstrap && make -j 15 && make install
RUN cd /tmp && tar -xf re2c-2.0.3.tar.xz && cd re2c-2.0.3 \
    && autoreconf -i -W all && ./configure && make -j 15 && make install
RUN cd /tmp && tar -xf libzip-1.7.3.tar.xz && cd libzip-1.7.3 \
    && mkdir build && cd build && cmake .. && make -j 15 && make install
RUN echo '/usr/local/lib64' >> /etc/ld.so.conf \
    && echo '/usr/local/lib' >> /etc/ld.so.conf \
    && echo '/usr/lib64' >> /etc/ld.so.conf \
    && echo '/usr/lib' >> /etc/ld.so.conf \
    && ldconfig -v
