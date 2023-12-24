#!/bin/bash


##定时杀死进程，等程序自动重启，解决程序僵死问题
ps -ef | grep ypf_swoole_async | grep -v grep  | awk '{print $2}' | xargs kill -9
