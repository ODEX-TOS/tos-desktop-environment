-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local file = require("lib-tde.file")

function get_ram_usage()
    local stdout = file.lines("/proc/meminfo", nil, 24)
    if #stdout < 3 then
        return
    end
    local total = string.gmatch(stdout[1], "%d+")()
    local free = string.gmatch(stdout[2], "%d+")()
    local buffer = string.gmatch(stdout[4], "%d+")()
    local cache = string.gmatch(stdout[5], "%d+")()
    local sReclaimable = string.gmatch(stdout[24], "%d+")()

    local used = total - free - buffer - cache - sReclaimable

    local usage = (used / total) * 100
    print("Ram usage: " .. usage .. "%")
    print("Ram used: " .. used .. "kB")
    print("Ram total: " .. total .. "kB")
end

get_ram_usage()
