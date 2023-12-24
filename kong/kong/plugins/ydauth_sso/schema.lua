local typedefs = require "kong.db.schema.typedefs"

return {
    name = "ydauth_sso",
    fields = {
        { consumer = typedefs.no_consumer },
        { run_on = typedefs.run_on_first },
        { protocols = typedefs.protocols_http },
        {
            config = {
                type = "record",
                fields = {
                    { session_name = { type = "string",  default = "sso_token_yundunv5" }, },
                    { redis_host = typedefs.host({ default = "127.0.0.1" }), },
                    { redis_port = typedefs.port({ default = 6379 }), },
                    { redis_password = { type = "string", len_min = 0 }, },
                    { redis_timeout = { type = "number", default = 2000 }, },
                    { not_login_message = { type = "string", default = "没有登录" }, },
                }, 
            }, 
        },
    },
}
