#!/bin/bash

mkdir -p /data/docker_images/
cd /data/docker_images/
for image in `docker images | grep -v REPOSITORY | grep -v none | awk '{print $1":"$2}'`
do
    name=${image//\//_}
    name=${name//:/-}
    echo docker save -o ${name}.tar ${image}
    docker save -o ${name}.tar ${image}
    echo rsync -avt /data/docker_images/ root@172.16.100.168:/YundunData/docker_images
    rsync -avt /data/docker_images/ root@172.16.100.168:/YundunData/docker_images
done
