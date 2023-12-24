import os
import math
import json
import zipfile
import tarfile 
from shutil import copyfile

srcDir = '/data/code/yundun'
docDir = '/data/code/yundun/apidoc'
docDirTmp = '/data/code/yundun/apidoc/tmp/'

srcDir = srcDir.rstrip('/')
docDir = docDir.rstrip('/')
docDirTmp = docDirTmp.rstrip('/')

def printApi(projectDocDir, isGroup=False):
    apis = []
    apiJfile = "%s/api_data.json" % projectDocDir
    fp = open(apiJfile, 'r')
    items = json.load(fp)
    fp.close()
    maxLen = 0
    for item in items:
        if maxLen > len(item['name']):
            pass
        else:
            maxLen = len(item['name'])

    print("项目API文档如下：")
    groups = []
    for item in items:
        spaceLen = maxLen + 4
        if isGroup:
            groups.append((item['group'], item['groupTitle']))
        else:
            print(item['name'], " " * (spaceLen - len(item['name'])), "##", item['group'], "\t",item['title'])
    groups = set(groups)
    for group in groups:
        print(group[0], "\t\t", group[1])

##生成API文档
def createDoc(apiDir, docDir):
    print("生成API文档：", apiDir)
    cmd = "docker run -it -v %s:/tmp -v %s:/doc dmitrymomot/apidoc -i /tmp -o /doc" % (apiDir, docDir)
    os.system(cmd)

def unzipDocTpl():
    tarDir = os.path.dirname(os.path.abspath(__file__))
    srcTpl = "%s/apidoc.tar.gz" % tarDir
    toTpl = "%s/apidoc.tar.gz" % docDirTmp
    copyfile(srcTpl, toTpl)
    with tarfile.open(toTpl) as t:
        t.extractall(path = docDirTmp)
    os.remove(toTpl)

def reformatDoc(projectDocDir, groups, excludeApis, apiRenames):
    apis = []
    apiJfile = "%s/api_data.json" % projectDocDir
    fp = open(apiJfile, 'r')
    items = json.load(fp)
    fp.close()
    for item in items:
        if item['group'] in groups:
            if item['name'] in excludeApis: continue
            item['groupTitle'] = groups[item['group']]
            if item['name'] in apiRenames: item['title'] = apiRenames[item['name']]
            apis.append(item)
    return apis

    ##fp = open('%s/apidoc/api_data.js' % docDirTmp, 'w')
    ##fp.write('define({ "api": ' + json.dumps(apis, indent=4, ensure_ascii=False) + '});')
    ##fp.close()
    ##fp = open('%s/apidoc/api_data.json' % docDirTmp, 'w')
    ##fp.write(json.dumps(apis, indent=4, ensure_ascii=False))
    ##fp.close()

    #### 大数据接口
    ##fp = open(dataApiJson, 'r')
    ##items = json.load(fp)
    ##fp.close()
    ##for item in items:
    ##    item["group"] = "统计-%s" % item["group"]
    ##    item["url"] = item["url"].replace("/dataapi/v1/", "stats_data.")
    ##    item["groupTitle"] = "统计-%s" % item["groupTitle"]
    ##    apis.append(item)

    #### 批量任务接口
    ##fp = open(serviceBatchApiJson, 'r')
    ##items = json.load(fp)
    ##fp.close()
    ##for item in items:
    ##    if item['name'] in ["ListTask", "ListSubTask"]:
    ##        item["group"] = "apiGroupCdnDomainBatch"
    ##        item["url"] = "agw/batch/console/v1" + item["url"]
    ##        item["groupTitle"] = "Web安全加速-批量任务"
    ##        apis.append(item)

    #### 用户IP接口
    ##fp = open(serviceCdnApiJson, 'r')
    ##items = json.load(fp)
    ##fp.close()
    ##for item in items:
    ##    if item['name'] in ["User_ip_item_text_save", "User_ip_item_list", "User_ip_item_edit", "User_ip_item_del_check", "User_ip_item_del"]:
    ##        item["group"] = "apiGroupCdnUserIpList"
    ##        item["url"] = "agw/cdn/console" + item["url"]
    ##        item["groupTitle"] = "Web安全加速-用户IP列表"
    ##        apis.append(item)

    ##fp = open('%s/api_data.js' % apidocDir, 'w')
    ##fp.write('define({ "api": ' + json.dumps(apis, indent=4, ensure_ascii=False) + '});')
    ##fp.close()
    ##fp = open('%s/api_data.json' % apidocDir, 'w')
    ##fp.write(json.dumps(apis, indent=4, ensure_ascii=False))
    ##fp.close()

def zipDoc(newDocDir, zipFile, apis):
    fp = open('%s/api_data.js' % newDocDir, 'w')
    fp.write('define({ "api": ' + json.dumps(apis, indent=4, ensure_ascii=False) + '});')
    fp.close()
    fp = open('%s/api_data.json' % newDocDir, 'w')
    fp.write(json.dumps(apis, indent=4, ensure_ascii=False))
    fp.close()

    currentDir = os.getcwd()
    os.chdir(docDirTmp)
    with zipfile.ZipFile(zipFile, 'w') as target:
        for i in os.walk('apidoc'):
            for n in i[2]:
                target.write(''.join((i[0],'/', n))) 
    os.chdir(currentDir)
    print("整理后的文档是：", zipFile)

    ##DNS安全解析
    ##"apiGroupDnsDiyViews", "apiGroupDnsDomain", "apiGroupDnsDomainGroup", "apiGroupDnsDomainLog", "apiGroupDnsDomainRecord", "apiGroupDnsMember",

if __name__ == "__main__":
    ##API文档所在的组
    groups = {
        ##云解析
        "apiGroupDnsDiyViews" : "DNS安全解析-自定义线路",
        "apiGroupDnsDomain": "DNS安全解析-域名",
        "apiGroupDnsDomainGroup": "DNS安全解析-域名组",
        "apiGroupDnsDomainLog": "DNS安全解析-日志",
        "apiGroupDnsDomainRecord": "DNS安全解析-记录管理",
        "apiGroupDnsMember": "DNS安全解析-用户",

        ##云加速
        "apiGroupCdnDomain": "Web安全加速-域名配置",
        "apiGroupWebCdnDomain": "Web安全加速-域名",
        "apiGroupWebCdnDomainGroup": "Web安全加速-域名组",
        "apiGroupWebCdnDomainLabel": "Web安全加速-域名标签",
        "apiGroupFireWall": "Web安全加速-精准访问控制",
        "apiGroupFireWallReport": "Web安全加速-精准访问控制报表",

        ##太极抗D plus
        "apiGroupTjkdPlus": "TCP安全加速",
        "apiGroupTjkdPlusReport": "TCP安全加速报表",

        ##消息中心
        "apiGroupMessageNotice": "消息中心",
        ##服务报告
        "apiGroupMemberReport": "服务报告",
        ##日志下载
        "apiGroupLogDownload": "日志下载",
        ##权限管理
        "apiGroupSubacl": "权限管理(子账号)",
        ##批量任务
        "apiGroupBatchTask": "批量任务",
        ##操作日志
        "apiGroupOplog": "操作日志",
    }
    ##排除的API
    excludeApis = [
        'permission_strategyUsers',
        'permission_strategyGroups',
        'permission_strategyGets',
        'permission_strategyInfo',
        'permission_strategySave',
        'permission_strategyEdit',
        'permission_strategyDelete',
        'permission_strategySets',
        'permission_modules',
        'permission_strategyBind',
        'permission_strategySysInfo',
        'permission_strategyBindGets',
        'permission_importRouter',
    ]
    ##API名字
    apiRenames = {}
    ## 输出所有的API
    #printApi(projectDocDir='%s/yundun_api_v4' % docDir, isGroup=True)
    ## 生成html压缩包

    unzipDocTpl()

    apisDoc = []
    createDoc("%s/yundun_api_v4/Controller" % srcDir, "%s/yundun_api_v4" % docDir)
    apisDoc.extend(reformatDoc(projectDocDir='%s/yundun_api_v4' % docDir, groups=groups, excludeApis=excludeApis, apiRenames=apiRenames))

    createDoc("%s/service_batch/api" % srcDir, "%s/service_batch" % docDir)
    apisDoc.extend(reformatDoc(projectDocDir='%s/service_batch' % docDir, groups=groups, excludeApis=excludeApis, apiRenames=apiRenames))

    createDoc("%s/service_oplog/api" % srcDir, "%s/service_oplog" % docDir)
    apisDoc.extend(reformatDoc(projectDocDir='%s/service_oplog' % docDir, groups=groups, excludeApis=excludeApis, apiRenames=apiRenames))

    zipDoc('%s/apidoc' % docDirTmp, '/tmp/apidoc.zip', apisDoc)
