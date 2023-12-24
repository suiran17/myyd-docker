local typedefs = require "kong.db.schema.typedefs"


return {
    name = "qiniu-yd",
    --no_consumer = true,
    fields = {
        { consumer = typedefs.no_consumer },
        { run_on = typedefs.run_on_first },
        { protocols = typedefs.protocols_http },
        {
            config = {
                type = "record",
                fields = {
                    { access_key = { type = "string", required = true, legacy = true }, },
                    { secret_key = { type = "string", required = true, }, },
                    { bucket     = { type = "string", required = true, }, },
                    { upload_url = { type = "string", required = true, }, },
                    { access_url = { type = "string", required = true, }, },
                }, 
            }, 
        },
    },
    ---- 对输入的配置项进行合法性检查
    --entity_checks = function(schema, plugin_t, dao, is_updating)
    --    -- perform any custom verification
    --    local akey = plugin_t.access_key
    --    if #akey == 0 then
    --        return false, Errors.schema("access_key must not be null")
    --    end
 
    --    local skey = plugin_t.secret_key
    --    if #skey == 0 then
    --        return false, Errors.schema("secret_key must not be null")
    --    end
 
    --    local bucket = plugin_t.bucket
    --    if #bucket == 0 then
    --        return false, Errors.schema("bucket must not be null")
    --    end

    --    local uUrl = plugin_t.upload_url
    --    if #uUrl == 0 then
    --        return false, Errors.schema("upload_url must not be null")
    --    end

    --    local aUrl = plugin_t.access_url
    --    if #aUrl == 0 then
    --        return false, Errors.schema("access_url must not be null")
    --    end

    --    return true
    --end,
}
