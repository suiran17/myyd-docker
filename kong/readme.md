### 网关镜像使用

docker.io/jingwu/kong:v1.3.1 是基于 yum 安装的 kong 1.3.0 的基础镜像
docker.io/jingwu/kong_yd:v0.1 是测试环境的镜像


升级：

docker pull kong:2.1.0-centos
docker pull kong:2.1.0-ubuntu

kong migrations up

kong migrations finish
