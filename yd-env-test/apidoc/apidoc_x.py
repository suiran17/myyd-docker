import os
import math
import json
import zipfile
import tarfile 
from shutil import copyfile

srcDir = '/Users/crystal/codes/php/gitlabcompany'
docDir = '/Users/crystal/codes/php/gitlabcompany/apidoc'
docDirTmp = '/Users/crystal/codes/php/gitlabcompany/apidoc/tmp/'

srcServiceDir = '/Users/crystal/codes/go/src/git.nodevops.cn/gcode/'


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
    #cmd = "docker run -it -v %s:/tmp -v %s:/doc dmitrymomot/apidoc -i /tmp -o /doc" % (apiDir, docDir)
    cmd = "apidoc -i %s -o %s" % (apiDir, docDir)
    print(cmd)
    os.system(cmd)

def unzipDocTpl():
    tarDir = os.path.dirname(os.path.abspath(__file__))
    print(tarDir)
    srcTpl = "%s/apidoc.tar.gz" % tarDir
    toTpl = "%s/apidoc.tar.gz" % docDirTmp
    copyfile(srcTpl, toTpl)
    with tarfile.open(toTpl) as t:
        t.extractall(path = docDirTmp)
    os.remove(toTpl)

def reformatDoc(projectDocDir, groups, excludeApis, apiRenames, urlPre=""):
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
            item["url"] = urlPre + item["url"]
            apis.append(item)
    return apis


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
        'getTjkdDnsExpiringDomains',
        'FireWallReport_getSdkPackageBlockList',
        'FireWallReport_getSdkPackageBlockDetails',
        'MemberMessage_getUsableSmsNum',
        'getDnsDomainPackageInfo',
        'MemberReport_getMemberMealList',
        'Zhengan_turnDomain',
        'Firewall_memberHasTransferDomain',
        'Firewall_zhengan_turnDomain',
        'Firewall_triggerFwPolicyStatus',
        'Firewall_getsPolicyByTjkdAppId',
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

    createDoc("%s/service_batch/api" % srcServiceDir, "%s/service_batch" % docDir)
    apisDoc.extend(reformatDoc(projectDocDir='%s/service_batch' % docDir, groups=groups, excludeApis=excludeApis, apiRenames=apiRenames, urlPre="agw/batch/console/v1"))

    createDoc("%s/service_oplog/api" % srcServiceDir, "%s/service_oplog" % docDir)
    apisDoc.extend(reformatDoc(projectDocDir='%s/service_oplog' % docDir, groups=groups, excludeApis=excludeApis, apiRenames=apiRenames, urlPre="agw/oplog/console"))

    zipDoc('%s/apidoc' % docDirTmp, '/Users/crystal/codes/php/gitlabcompany/apidoc/apidoc.zip', apisDoc)
