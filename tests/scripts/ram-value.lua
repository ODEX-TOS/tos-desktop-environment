-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local file = require("lib-tde.file")

function get_ram_usage()
    local stdout = file.lines("/proc/meminfo", nil, 3)
    if #stdout < 3 then
        return
    end
    local total = string.gmatch(stdout[1], "%d+")()
    local free = string.gmatch(stdout[3], "%d+")()
    local usage = (1 - (free / total)) * 100
    print("Ram usage: " .. usage .. "%")
    print("Ram total: " .. total .. "kB")
end

get_ram_usage()
