- https://docs.docker.com/engine/reference/builder/

### dockerfile简介
- 通过各种指令让构建docker镜像更加容易，可以将dockerfile加入版本控制系统，和构建的镜像版本对应起来
- 可以快速而精确地重新创建镜像以便于维护和升级
- 便于持续集成


1. 使用.dockerignore. 为了避免在编译镜像时一些无关紧要的文件，我们可以采用.dockerignore文件来排除文件和目录，类似.gitignore作用一样

2. 使用多阶段构建,减少镜像大小以及layer数量

	```text
	
	FROM golang:1.9.2-alpine3.6 AS build
	
	RUN apk add --no-cache git
	RUN go get github.com/golang/dep/cmd/dep
	
	COPY Gopkg.lock Gopkg.toml /go/src/project/
	WORKDIR /go/src/project/
	RUN dep ensure -vendor-only
	
	
	COPY . /go/src/project/
	RUN go build -o /bin/project
	
	
	FROM scratch
	COPY --from=build /bin/project /bin/project
	ENTRYPOINT ["/bin/project"]
	CMD ["--help"]
	
	
	```
3. 每个容器只关心一件事。不要在同个容器启动多个进程

4. 减少layer数量

	```text
	RUN apk --no-cache update && \
		apk --no-cache add curl \
		git \
		make \
		docker \
		bzr \
		cvz
	```

5. 基础镜像尽量小，构建出来的镜像也会比较小，自动部署更加容易，官方很多已经是基于Alpine构建，5MB
    - https://hub.docker.com/_/alpine
    
6. RUN
	- 使用RUN apt update && apt install -y \的方式保证每次制作镜像时，都是安装的最新的软件包
	- 在安装命令后，应清理缓存，减少镜像的大小，执行...&& yum clean all
	- 合并指令 RUN apt-get update && apt-get install -y libgdiplus
 
7. CMD
	- CMD ["command", "arg1", "arg2"] 使用这种形式
	
8. 一般用COPY拷贝文件到容器就好了，ADD会自动解压

9. 切换目录用WORKDIR绝对路径

10. 优化指令顺序
Docker会缓存Dockerfile中尚未更改的所有步骤，但是，如果更改任何指令，将重做其后的所有步骤。
也就是指令3有变动，那么4、5、6就会重做。因此，我们需要将最不可能产生更改的指令放在前面，按照这个顺序来编写dockerfile指令。
这样，在构建过程中，就可以节省很多时间。比如，我们可以把WORKDIR、ENV等命令放前面，COPY、ADD放后面

