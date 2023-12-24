#!/bin/bash

cd /www/crontab_processd
rm -rf /var/run/crontab_processd.pid
/usr/local/bin/python3.8 crontab_processd.py start
tail -f /dev/null
