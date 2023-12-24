#!/bin/bash

openssl genrsa -des3 -out ./gitlab/ssl/git.nodevops.cn.key 2048
openssl req -new -key ./gitlab/ssl/git.nodevops.cn.key -out ./gitlab/ssl/git.nodevops.cn.csr
合并上面两行为下面一行：
openssl req -nodes -newkey rsa:2048 -keyout gitlab.domain.com.key -out gitlab.domain.com.csr


cp -v ./gitlab/ssl/git.nodevops.cn.{key,original}
openssl rsa -in ./gitlab/ssl/git.nodevops.cn.original -out ./gitlab/ssl/git.nodevops.cn.key
rm -v ./gitlab/ssl/git.nodevops.cn.original

openssl x509 -req -days 1460 -in ./gitlab/ssl/git.nodevops.cn.csr -signkey ./gitlab/ssl/git.nodevops.cn.key -out ./gitlab/ssl/git.nodevops.cn.crt

rm -v ./gitlab/ssl/git.nodevops.cn.csr
