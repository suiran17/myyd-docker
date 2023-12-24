local kong = kong
local cjson = require "cjson"
local str = require "resty.string"
local hmac = require "kong.plugins.ydauth_sso.ydlib.hmac"

local _M = {}
_M._VERSION = '0.01'

-- yundun 签名, 包括了组织数据，sha256
function _M.sign(data, secret)
    --排序组织数据
    --table.sort(data)
    local raw = cjson.encode(data)
    kong.log.err("sign raw: ", raw)

    local hmac_sha256 = hmac:new(secret, hmac.ALGOS.SHA256)
    if not hmac_sha256 then
        return nil, "hmac_sha256 not exists"
    end
    local ok = hmac_sha256:update(raw)
    if not ok then
        return nil, "hmac_sha256 update failed"
    end
    local signBin = hmac_sha256:final()
    local sign64 = ngx.encode_base64(signBin)
    local sign, _ = string.gsub(sign64, "+", "-")
    sign, _ = string.gsub(sign, "/", "_")
    kong.log.err("sign result: ", sign)
    return sign, nil
end

-- yundun 验签, 包括了组织数据
function _M.verify(data, secret, signed)
    local sign, err = _M.sign(data, secret)
    if err then
        return nil, err
    end
    kong.log.err("sign verify signed: ", signed)
    if sign == signed then
        return true, nil
    else
        return false, nil
    end
end

return _M
