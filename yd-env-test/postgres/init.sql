-- 创建kong用户
CREATE USER kong WITH PASSWORD 'kong123456..';

-- 创建数据库
create database kong owner kong;
create database konga owner kong;

-- 授权
GRANT ALL PRIVILEGES ON DATABASE konga TO kong;
GRANT ALL PRIVILEGES ON DATABASE kong  TO kong;
