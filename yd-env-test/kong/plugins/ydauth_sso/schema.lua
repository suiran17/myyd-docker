local typedefs = require "kong.db.schema.typedefs"

return {
    name = "ydauth_sso",
    fields = {
        { consumer = typedefs.no_consumer },
        --{ run_on = typedefs.run_on_first },
        { protocols = typedefs.protocols_http },
        {
            config = {
                type = "record",
                fields = {
                    { not_login_message = { type = "string", default = "没有登录" }, },
                }, 
            }, 
        },
    },
}
