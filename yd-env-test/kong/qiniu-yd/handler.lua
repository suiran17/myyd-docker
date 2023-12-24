local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"
local qiniu = require "kong.plugins.qiniu-yd.qiniu"

local QiniuYdHandler = BasePlugin:extend()

QiniuYdHandler.VERSION = "1.0.0"


function QiniuYdHandler:new()
  QiniuYdHandler.super.new(self, "qiniu-yd")
end


function QiniuYdHandler:access(conf)
    QiniuYdHandler.super.access(self)

    qiniu.upfilter(conf)
end

return QiniuYdHandler

