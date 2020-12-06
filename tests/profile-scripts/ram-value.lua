-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local hardware = require("lib-tde.hardware-check")

function get_ram_usage()
    local usage, total = hardware.getRamInfo()
    print("Ram usage: " .. usage .. "%")
    print("Ram total: " .. total .. "kB")
end

get_ram_usage()
