### gitlab 环境部署

#### 1. docker 环境安装

make docker_install

#### 2. 执环境验证

make up

#### 3. 启动环境

make start

#### 4. 停止环境

make stop

#### 5. 备份

make backup

#### 6. 恢复(注意修改对应的备份版本)

make restore


#### 7. 生成中文补订

```
cd ../
git clone https://gitlab.com/xhang/gitlab.git gitlab_zh
cd gitlab_zh
git diff 8-8-7-stable..8-8-7-zh > ../gitlab/gitlab/8.8.7.diff

gitlab-ctl stop
patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < 8.8.7.diff

#确定没有 .rej 文件，重启 GitLab
gitlab-ctl reconfigure && gitlab-ctl start
```

#### 8. 升级
```
## https://www.cnblogs.com/inxworld/p/11782545.html
## https://docs.gitlab.com/ce/policy/maintenance.html#upgrade-recommendations

8.8  -> 8.17    1589730887_2020_05_17_gitlab_backup.tar
8.17 -> 9.0     1589732978_2020_05_17_gitlab_backup.tar
9.0  -> 9.5     1589735367_2020_05_17_9.5.9_gitlab_backup.tar
9.5  -> 10.0    1589737053_2020_05_17_10.0.0_gitlab_backup.tar
10.0 -> 10.8    1589738687_2020_05_17_10.8.7_gitlab_backup.tar
10.8 -> 11.0    1589740438_2020_05_17_11.0.0_gitlab_backup.tar
11.0 -> 11.11   1589742391_2020_05_17_11.11.8_gitlab_backup.tar
11.11 -> 12.0   1589744184_2020_05_17_12.0.0_gitlab_backup.tar
12.0  -> 12.3   1589752824_2020_05_17_12.3.9_gitlab_backup.tar
```
