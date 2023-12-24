### nginx docker镜像制作

```
docker.io的nginx镜像，如果需要添加一些扩展，则需要重新编译nginx, 因此制作了新的nginx镜像
新镜像的配置及启动方式与docker.io的镜像保持一致！

新的nginx支持了lua, 同时添加了 resty.core, resty.lrucache lua脚本。

nginx编译用到的扩展如下：
https://github.com/vision5/ngx_devel_kit
https://github.com/openresty/luajit2
https://github.com/openresty/lua-nginx-module
https://github.com/openresty/lua-resty-lrucache
https://github.com/openresty/lua-resty-core

编译命令见Dockerfile
```

### 常用命令

```
## 构建nginx1.18镜像, 镜像构建好后会自动推送到 docker.nodevops.cn/web/nginx:1.18-alpine-yd
make build_ngx118yd

## 构建nginx1.19镜像, 镜像构建好后会自动推送到 docker.nodevops.cn/web/nginx:1.19-alpine-yd
make build_ngx119yd

## 执行测试
make test
```
