local os        = require "os"
local cjson     = require "cjson"
local Multipart = require 'multipart'
local http      = require "resty.http"
local uuid      = require "kong.tools.utils".uuid

local ngx       = ngx
local find      = string.find
local match     = string.match

local qAK       = "TbOklOe78xWDBuDp0DLXJMVDipBwOUjAXkYQThwB"
local qSK       = "bmIO5pBEJg0HnIvjlOn6563sw_ST4XbEFR6bcws8"
local uURL      = "http://upload.qiniu.com"
local aUrl      = "http://jingwupublic.qiniudn.com/"
local bucket    = "jingwupublic"
local TIMEOUT   = 30 --默认超时时间

local qiniu = {}

--生成随机函数，需要放大后处理
function random(n,m)
    math.randomseed(os.clock()*math.random(100000,9000000)*math.random(100000,900000))
    return math.random(n,m)
end

--生成指定长度的随机字符串
function random_str(len)
    local str = ""
    for i=1,len,1 do
        str = str .. string.char(random(97,122))
    end
    return str
end

function qiniu.token(ak, sk, scope, fkey)
    if fkey == nil then
        -- no code
    else
        scope = scope .. ':' .. fkey
    end
    args = {}
    args["scope"] = scope
    args["deadline"] = os.time() + 3600
    local ct = cjson.encode(args)
    local scopeBase64 = ngx.encode_base64(ct)
    scopeBase64 = string.gsub(scopeBase64, "+", "-")
    scopeBase64 = string.gsub(scopeBase64, "/", "_")

    local sign = ngx.hmac_sha1(sk, scopeBase64)
    local scopeHash = ngx.encode_base64(sign)

    local tmp = scopeHash .. ":" .. scopeBase64
    tmp = string.gsub(tmp, "+", "-")
    tmp = string.gsub(tmp, "/", "_")
    return ak .. ":" .. tmp 
end

function qiniu.uploadFile(conf, filepath, fkey)
    --读取文件内容
    local fh = io.open(filepath, 'r')
    if fh == nil then
        return "", "open file " .. filepath .. " fail"
    end
    local data = fh:read("*a")
    fh:close()
    fname = "tester.log"

    return qiniu.upload(conf, data, fname, fkey)
end

function qiniu.upload(conf, data, fname, fkey)
    local qAK       = conf.access_key
    local qSK       = conf.secret_key
    local uURL      = conf.upload_url
    local aUrl      = conf.access_url
    local bucket    = conf.bucket


    --取token
    url     = uURL
    token   = qiniu.token(qAK, qSK, bucket, fkey)
    local httpc = http.new()

    --使用默认时间
    http:set_timeout(TIMEOUT *1000)

    --生成随机字符串，用于区分各个文件的内容间隔
    local boundary = random_str(12) 

    --组建body
    local str = ""

    --fkey
    str = str .. "------------------------------" .. boundary .. "\r\n"
    str = str .. 'Content-Disposition: form-data; name="key"\r\n\r\n'
    str = str .. fkey .. '\r\n'

    --token
    str = str .. "------------------------------" .. boundary .. "\r\n"
    str = str .. 'Content-Disposition: form-data; name="token"\r\n\r\n'
    str = str .. token .. '\r\n'

    --file body   name="file"; 必须为 file
    str = str .. "------------------------------" .. boundary .. "\r\n"
    str = str .. 'Content-Disposition: form-data; name="file"; filename="' .. fname .. '"\r\n'
    str = str .. "Content-Type: application/octet-stream\r\n"
    str = str .. "Content-Transfer-Encoding: binary\r\n\r\n"
    str = str .. data .. "\r\n"
    str = str .. "------------------------------" .. boundary .. "--\r\n"

    local res, err_ = httpc:request_uri(url, {
        method = "POST",
        body = str,
        ssl_verify = ssl_verify or false,
        --设置headers
        headers = {
            ["Accept"] = "*/*",
            ["Content-Type"] = "multipart/form-data; boundary=----------------------------" .. boundary,
        }
    })
    --ngx.say("response http_code: " .. res.status)
    --ngx.say("response body: " .. res.body)

    if not res then
        return res, err_
    else
        if res.status == 200 then
            return res.body, ""
        else
            return nil, err_
        end
    end
    return nil, "upload ".. filepath  .." ok"
end

--获取文件名
function getFileName(str)
    local idx = str:match(".+()%.%w+$")
    if(idx) then
        return str:sub(1, idx-1)
    else
        return str
    end
end
 
--获取扩展名
function getExtension(str)
    return str:match(".+%.(%w+)$")
end

function qiniu.upfilter(conf)
    --读取数据
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    local headers, err = ngx.req.get_headers()

    --解析数据
    mfFlag = find(headers["content-type"], "multipart/form-data", 1, true)
    --ngx.log(ngx.WARN, "mfFlag", mfFlag)
    if mfFlag then
        --ngx.log(ngx.WARN, "mfFlag--if")
        local mdata = Multipart(body, headers["content-type"])
        --ngx.log(ngx.WARN, "mfFlag--if--mdata")
        for k, v in pairs(mdata._data.data) do
            --ngx.log(ngx.WARN, "mfFlag--if--mdata-k-", k)
            --判断是否有文件
            local isFile = false
            local disp   = ''
            for hk, hv in pairs(v.headers) do
                --ngx.log(ngx.WARN, "mfFlag--if--mdata-k-", k, "-hk-", hk)
                local dFlag = find(hv, "Content-Disposition", 1, true)
                if dFlag then
                    local fFlag = find(hv, "filename", 1, true)
                    if fFlag then
                        disp    = hv
                        isFile  = true
                        break
                    end
                end
            end
            --文件上传并改写post参数
            if isFile then
                local fname = string.match(disp, 'filename="(.*)"')
                if fname then
                    local upResult, er = qiniu.upload(conf, v.value, fname, uuid() .. "." .. os.date("%Y%m%d%H%M%S", os.time()) .. "." .. getExtension(fname))
                    if upResult then
                        local jdq   = cjson.decode(upResult)
                        jdq["real_url"] = aUrl .. jdq["key"]
                        mdata:set_simple('_files['.. v.name .. '][filename]', fname)
                        mdata:set_simple('_files['.. v.name .. '][base_content_url]', jdq["real_url"])
                        mdata:set_simple('_files['.. v.name .. '][hash]', jdq["hash"])
                        mdata:set_simple('_files['.. v.name .. '][key]', jdq["key"])
                        local bodys = mdata:tostring()
                        ngx.req.set_body_data(bodys)
                    else
                        --记日志
                        --ngx.say("upResult-----err----" .. er)
                    end
                end
            end
        end
    end
    return
end

return qiniu
