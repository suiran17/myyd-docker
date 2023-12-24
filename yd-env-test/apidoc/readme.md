### api文档整合生成

```
云盾的API分布在好多的项目中，而且有很多过期的API
我们给用户提供的API，不同的用户的API，不一样的，因此对API的处理也不同
部分用户对API中的名词要求不同，也需要作处理
```

```
生成文档，需要执行命令：
python3 apidoc_common.py
```

```
执行前，根据环境及客户要求，修改代码中的如下变量：

srcDir = '/data/code/yundun'
docDir = '/data/code/yundun/apidoc'
docDirTmp = '/data/code/yundun/apidoc/tmp/'

groups = {}
excludeApis = {}
apiRenames = {}
```