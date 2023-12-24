local cjson = require "cjson"
local args = ngx.req.get_uri_args()
local ips = args["ips"]
local ipsTmp = args["ips"]
local key = 1 
local index = 1 
local fnames = {}
local jsondata = {}
local configDir = "/www/upstream/upstream_"
if ips 
then 
    while true do
        index = string.find(ipsTmp, ",")
        if not index
        then
            fnames[key] = ipsTmp
            break
        else
            fnames[key] = string.sub(ipsTmp, 0,index -1) 
            ipsTmp = string.sub(ipsTmp, index + 1)
        end
        key = key + 1 
    end 
    for key, ip in ipairs(fnames) do
        local fname = configDir..ip..".conf"
        local fh = io.open(fname,"r")
        if fh
        then
            local f = io.open(fname, "r")
            local body = f:read("*all")
            f:close()
            jsondata[ip]=body
        end
    end 
    ngx.say(cjson.encode(jsondata))
else
    ngx.say("{}")
end
