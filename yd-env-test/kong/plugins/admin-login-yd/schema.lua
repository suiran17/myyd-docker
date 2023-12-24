local typedefs = require "kong.db.schema.typedefs"


return {
    name = "admin-login-yd",
    fields = {
        { consumer = typedefs.no_consumer },
        --{ run_on = typedefs.run_on_first },
        { protocols = typedefs.protocols_http },
        {
            config = {
                type = "record",
                fields = {
                    { session_name = { type = "string",  default = "PHPSESSID" }, },
                    { session_prefix = { type = "string",  default = "PHPREDIS_SESSION:" }, },
                    { serialize_handler = { type = "string", required = true,  default= "php_serialize",  one_of = { "php", "php_serialize" },}, },
                    { redis_host = typedefs.host({default= "172.16.100.106"}), },
                    { redis_port = typedefs.port({ default = 6379 }), },
                    { redis_password = { type = "string", len_min = 0 }, },
                    { redis_timeout = { type = "number", default = 2000 }, },
                    { redis_database = { type = "number", default = 0 }, },
                    { not_login_message = { type = "string", default = "没有登录" }, },
                }, 
            }, 
        },
    },
}
