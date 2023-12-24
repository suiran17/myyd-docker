### 服务报告镜像

#### 说明
```
服务报告指的是生成pdf及word，并提供下载的服务
pdf生成是基于linux版本的libreoffice6.4
word生成是用python python-docx组件实现的，python版本3.8，内置pipenv
在运行项目时，需提供启动命令

在生成pdf/word时，因中文原因，将windows下的字体复制到的镜像中，导致镜像很大

镜像提供两个目录：
/www 用于运行程序 
/static 用于存放生成的文档
```