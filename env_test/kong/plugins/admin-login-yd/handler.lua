local ck = require "kong.plugins.admin-login-yd.resty.cookie"
local redis  = require "resty.redis" 
local kong = kong
local sessionunserialize = require "kong.plugins.admin-login-yd.session.unserialize"
local ngx  = ngx
local BasePlugin = require "kong.plugins.base_plugin"

-- local AdminLoginHandler = {}
local AdminLoginHandler = BasePlugin:extend()


AdminLoginHandler.PRIORITY = 1
AdminLoginHandler.VERSION = "1.0.0"

function AdminLoginHandler:access(conf)
    local session_name = conf.session_name
    local session_prefix = conf.session_prefix
    local serialize_handler = conf.serialize_handler

    local redis_host = conf.redis_host
    local redis_port = conf.redis_port
    local redis_password = conf.redis_password
    local redis_timeout = conf.redis_timeout
    local redis_database = conf.redis_database

    local not_login_message = conf.not_login_message

    -- get cookie
    local cookie, err = ck:new()
    if not cookie then
        kong.log.err("cookie new fialed", err)
        return
    end
    local sessionCookie, err = cookie:get(session_name)
    if not sessionCookie then
    kong.log.err("failed to get login session cookie: ", err)
    -- session cookie not exist ,not login
    return kong.response.exit(403, {
        message = not_login_message
        })
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
    -- select
    local ok, err = red:select(redis_database)
    if not ok then
        kong.log.err("failed to change Redis database: ", err)
        return nil, err
    end

     -- get redis
    local session_redis_key = session_prefix..sessionCookie
    local sessionValue, err = red:get(session_redis_key)
    local unserializeOk = false
    local sessionInfo = {}
    if serialize_handler == "php_serialize" then
        unserializeOk, sessionInfo = pcall(sessionunserialize.unserialize, sessionValue)
    elseif serialize_handler == "php" then
        unserializeOk, sessionInfo = pcall(sessionunserialize.unserializeSession, sessionValue)
    end
    
    -- 登录判断
    if not unserializeOk then
        return kong.response.exit(403, {
            message = not_login_message
            })
    else
        -- ngx.say("logined", type(sessionInfo), " id ", sessionInfo.adminV5BackendLogin.id, " nickname ", sessionInfo.adminV5BackendLogin.nickname)
        ngx.req.set_header("X-Admin-User-ID", sessionInfo.adminV5BackendLogin.id)
        --ngx.req.set_uri_args({ admin_user_id = sessionInfo.adminV5BackendLogin.id })
        --ngx.req.read_body()
        --local args, err = ngx.req.get_post_args()
        --args['admin_user_id'] = sessionInfo.adminV5BackendLogin.id
        --ngx.req.set_body_data(args)
    end
    

end

return AdminLoginHandler
