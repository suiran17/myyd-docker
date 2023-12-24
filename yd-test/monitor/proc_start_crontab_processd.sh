#!/bin/bash

## 每一分钟检查一次进程启动，进程内部已经实现了唯一限制，已存在，会自动退出
## * * * * * /usr/bin/python3 /data/www/crontab_processd/crontab_processd.py start

/usr/bin/python3 /data/www/crontab_processd/crontab_processd.py start
