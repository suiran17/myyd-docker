local redis = require "resty.redis"
local cjson = require "cjson"
local kong = kong
local ngx  = ngx
local BasePlugin = require "kong.plugins.base_plugin"
local cookielib = require "kong.plugins.ydauth_sso.ydlib.cookie"
local ydsign = require "kong.plugins.ydauth_sso.ydlib.sign"
local ydphp = require "kong.plugins.ydauth_sso.ydlib.php_unserialize"

-- local Ydauth = {}
local YdAuth = BasePlugin:extend()

YdAuth.PRIORITY = 1
YdAuth.VERSION = "1.0.0"

local redisTimeout = 10000
local redis_host = "redis.test.nodevops.cn"
local redis_port = 6379
local redis_auth = "Gmck7X02"

function redisConn(redisHost, redisPort, redisAuth, redisDb)
    local conn = redis:new()

    -- connect
    conn:set_timeout(redisTimeout)
    local ok, err = conn:connect(redisHost, redisPort)
    if not ok then
        kong.log.err("redis connect host[", redisHost, '] port[', redisPort, "] db[", redisDb, "]    error: ", err)
        return conn, err
    end

    -- auth
    if redisAuth ~= '' then
        local ok, err = conn:auth(redisAuth)
        if not ok then
            kong.log.err('redis auth(', redisAuth, ') Error: ', err)
            return conn, err
        end
    end

    -- select db
    local ok, err = conn:select(redisDb)
    if not ok then
        kong.log.err('redis select(', redisDb, '): ', err)
        return conn, err
    end
    return conn, nil
end

function readSessionFromCookie(sessionNameInCookie)
    local redisSessionId, err = redisConn(redis_host, redis_port, redis_auth, 1)
    if err ~= nil then
        return {}, err
    end
    local sessionOutKeys, err = redisSessionId:keys("*"..sessionNameInCookie.."*")
    if table.getn(sessionOutKeys) ~= 1 then
        kong.log.err("redis keys(*", sessionNameInCookie,"*): ", sessionOutKeys, "    err: ", err)
        return {}, err
    end
    local sessionOutValue, err = redisSessionId:get(sessionOutKeys[1])
    if not sessionOutValue then
        kong.log.err("redis get(", sessionOutKeys[1],"): ", sessionOutValue, "    err: ", err)
        return {}, err
    end
    local sessionId = ""
    if string.sub(sessionOutValue, 1, 2) == 's:' then
        ok, sessionId = pcall(ydphp.unserializePhp, sessionOutValue)
        if not ok then
            kong.log.err("unserializePhp ", ok, sessionId)
            return {}, err
        end
    else
        sessionId = sessionOutValue
    end

    local redisSession, err = redisConn(redis_host, redis_port, redis_auth, 2)
    if err ~= nil then
        return {}, err
    end

    local sessionValue, err = redisSession:get(sessionId)
    if not sessionValue then
        kong.log.err("redis get(", sessionId,"): ", sessionValue, "    err: ", err)
        return {}, err
    end
    -- 登录判断
    local ok, sessionInfo = pcall(ydphp.unserializeSession, sessionValue)
    if not ok then
        kong.log.err("unserializeSession failed: ", unserializeOk, cjson.encode(sessionInfo))
        return {}, err
    end
    return sessionInfo, nil
end

function readSessionFromToken(token)
    local redisToken, err = redisConn(redis_host, redis_port, redis_auth, 2)
    if err ~= nil then
        return {}, err
    end

    local sessionValue, err = redisToken:get("IAM_USER_"..token)
    if err ~= nil then
        kong.log.err("redis get(", "IAM_USER_"..token, "): ", sessionValue, "    err: ", err)
        return {}, err
    end
    -- 登录判断
    local sessionInfo, err = cjson.decode(sessionValue)
    if err ~= nil then
        kong.log.err("cjson.decode failed: Err: ", err, "  sessionValue: ", cjson.encode(sessionInfo))
        return {}, err
    end
    return sessionInfo, nil
end

function YdExit(code, msg)
    local resp = {}
    resp["status"] = {}
    resp["status"]["code"] = code
    resp["status"]["message"] = msg
    return kong.response.exit(200, cjson.encode(resp))
end

function YdExitV2(code, msg)
    local resp = {}
    resp["code"] = code
    resp["message"] = msg
    return kong.response.exit(200, cjson.encode(resp))
end

function GetSessionName(code, msg)
    local cookieKey = ''
    local cookie, err = cookielib:new()
    if err ~= nil then
        return '', err
    end

    for k, v in pairs(cookie:get_all()) do
        if string.sub(k, 1, 10) == 'sso_token_' then
            cookieKey = k
        end
    end
    local sessionName, err = cookie:get(cookieKey)
    if err ~= nil then
        kong.log.err('cookie get(', cookieKey, ') value: ', sessionName, "    err: ", err)
        return '', err
    end
    return sessionName, nil
end

function YdAuth:access(conf)
    local headers, err = ngx.req.get_headers()
    ngx.req.read_body()
    if headers["x-token"] then
        local token = headers["x-token"]
        local sessionInfo, err = readSessionFromToken(token)
        if err ~= nil then
            return kong.response.exit(403, {message = "not login"})
        end
        ngx.req.set_header("X-Ydauth-Type", "sso")
        ngx.req.set_header("X-Ydauth-User-ID", sessionInfo.yduser.member_id)
        ngx.req.set_header("X-Ydauth-User-Email", sessionInfo.email)
        kong.log.warn("request use iam: ")
    elseif headers["x-auth-app-id"] then
        --SDK 请求及签名验证
        --应区分SDK版本
        ngx.req.set_header("x-ydauth-type", "sdk")
        local method = kong.request.get_method()
        local userId  = 0
        local signData = {}
        --数据返回格式 v2为新版，v1或无为默认
        --默认返回格式：{"status": {"code": 0, "message": ""}, "data": []}
        --v2版返回格式：{"code": 0, "message": "", "data": []}
        local responseStyle = headers["x-yd-response-style"]
        if method == "GET" then
            signData, err = ngx.req.get_uri_args()
            if err == "truncated" then
                return YdExit(0, "解析参数异常")
            end
        elseif method == "POST" or method == "PUT" or method == "PATCH" then
            signData, err = ngx.req.get_post_args()
            return YdExit(0, "解析参数异常")
        else
            return YdExit(0, "不支持的请求方法")
        end
        kong.log.info("signData:", cjson.encode(signData))
        if signData["user_id"] then
            userId = signData["user_id"]
        elseif signData["user_id"] then
            userId = signData["user_id"]
        end

        -- 暂时不验签
        ----验签
        --local appSecret = "fa270cfa9ab331bdb989cd0a7f130f48"
        --local verified, err = ydsign.verify(signData, appSecret, headers["x-auth-sign"])
        --if err then
        --    return YdExit(0, err)
        --end
        ----验签失败，返回数据
        --if not verified then
        --    if responseStyle == "V2" then
        --        return YdExitV2(0, "签名验证失败")
        --    else
        --        return YdExit(0, "签名验证失败")
        --    end
        --end

        kong.log.err("userId: ", userId)
        ngx.req.set_header("X-Ydauth-User-ID", userId)
        --这里应从数据库或缓存中查出用户邮箱
        ngx.req.set_header("X-Ydauth-User-Email", "")
        kong.log.warn("request use sdk: ")
    else
        --用户登录，取session数据
        local sessionName, err = GetSessionName()
        if err ~= nil then
            kong.log.err("get session name from cookie err: ", err)
            return kong.response.exit(403, {message = "not login"})
        end

        local sessionInfo, err = readSessionFromCookie(sessionName)
        if err then
            return kong.response.exit(403, {message = "not login"})
        end
        ngx.req.set_header("X-Ydauth-Type", "sso")
        ngx.req.set_header("X-Ydauth-User-ID", sessionInfo.sso_user_id)
        ngx.req.set_header("X-Ydauth-User-Email", sessionInfo.sso_user_email)
	if sessionInfo.sso_subuser_id ~= nil then
            ngx.req.set_header("X-Ydauth-SubUser-ID", sessionInfo.sso_subuser_id)
	end
	if sessionInfo.sso_subuser_name ~= nil then
            ngx.req.set_header("X-Ydauth-SubUser-Name", sessionInfo.sso_subuser_name)
	end
        kong.log.warn("request use browser: ")
    end
end

return YdAuth

