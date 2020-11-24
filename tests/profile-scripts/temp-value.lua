-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local file = require("lib-tde.file")

function get_temp_usage()
    local stdout = file.string("/sys/class/thermal/thermal_zone0/temp") or ""
    if stdout == "" then
        return
    end
    local temp = stdout:match("(%d+)")
    print("Current temperature: " .. (temp / 1000) .. " °C")
end

get_temp_usage()
