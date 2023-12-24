-- 创建kong用户
CREATE USER kongpre WITH PASSWORD 'kongpre123456..';

-- 创建数据库
create database kongpre owner kongpre;
create database kongapre owner kongpre;

-- 授权
GRANT ALL PRIVILEGES ON DATABASE kongapre TO kongpre;
GRANT ALL PRIVILEGES ON DATABASE kongpre  TO kongpre;
