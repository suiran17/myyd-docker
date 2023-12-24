#!/bin/bash

for image in `docker.nodevops.cn*.tar.xz`
do
    #echo xz -d ${image}
    #echo docker load -i ${image%\\.*}
    #echo ${image%\.*}
    echo ${image}
done
