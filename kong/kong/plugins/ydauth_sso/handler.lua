local ck = require "kong.plugins.ydauth_sso.resty.cookie"
local redis  = require "resty.redis" 
local cjson = require "cjson"
local kong = kong
local sessionLib = require "kong.plugins.ydauth_sso.session.unserialize"
local ngx  = ngx
local BasePlugin = require "kong.plugins.base_plugin"

-- local AdminLoginHandler = {}
local AdminLoginHandler = BasePlugin:extend()

AdminLoginHandler.PRIORITY = 1
AdminLoginHandler.VERSION = "1.0.0"

function AdminLoginHandler:access(conf)
    local session_name = conf.session_name

    local redis_host = conf.redis_host
    local redis_port = conf.redis_port
    local redis_timeout = conf.redis_timeout
    local redis_password = conf.redis_password

    local not_login_message = conf.not_login_message

    -- get cookie
    local cookie, err = ck:new()
    if not cookie then
        kong.log.err("cookie new fialed", err)
        return
    end
    local sessionNameInCookie, err = cookie:get(session_name)
    if not sessionNameInCookie then
        kong.log.err("failed to get login session cookie: ", err)
        -- session cookie not exist ,not login
        return kong.response.exit(403, {message = not_login_message})
    end

    local red = redis:new()
    red:set_timeout(redis_timeout)
    -- connect
    local ok, err = red:connect(redis_host, redis_port)
    if not ok then
        kong.log.err("failed to connect Redis: ", err)
        return nil, err
    end
    -- auth
    local ok, err = red:auth(redis_password)
    if not ok then
        kong.log.err("failed to auth Redis: ", err)
        return nil, err
    end

    -- 从 sso session 中取出真正的 session id
    local ok, err = red:select(1)
    if not ok then
        kong.log.err("failed to change Redis database: ", err)
        return nil, err
    end
    local sessionValue, err = red:keys("*"..sessionNameInCookie.."*")
    if table.getn(sessionValue) ~= 1 then
        return kong.response.exit(403, {message = "多地登录，退出"})
    end
    local sessionValue1, err = red:get(sessionValue[1])
    unserializeOk, sessionId = pcall(sessionLib.unserializePhp, sessionValue1)
    if not unserializeOk then
        return kong.response.exit(403, {message = not_login_message})
    end

    -- 取出用户真正的session
    local ok, err = red:select(2)
    if not ok then
        kong.log.err("failed to change Redis database: ", err)
        return kong.response.exit(403, {message = not_login_message})
    end
    local sessionValue, err = red:get(sessionId)
    local unserializeOk, sessionInfo = pcall(sessionLib.unserializeSession, sessionValue)
    --kong.log.err("sessionInfo: ", unserializeOk, cjson.encode(sessionInfo))
    
    -- 登录判断
    if not unserializeOk then
        return kong.response.exit(403, {message = not_login_message})
    else
        ngx.req.set_header("X-Ydauth-Type", "sso")
        ngx.req.set_header("X-Ydauth-User-ID", sessionInfo.sso_user_id)
        ngx.req.set_header("X-Ydauth-User-Email", sessionInfo.sso_user_email)
    end
end

return AdminLoginHandler
