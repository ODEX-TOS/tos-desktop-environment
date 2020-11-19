-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local file = require("lib-tde.file")

function get_disk_usage()
    -- find all hardisk and their size
    local statvfs = require "posix.sys.statvfs".statvfs
    local res = statvfs("/")
    local usage = (res.f_bfree / res.f_blocks) * 100
    -- f_blocks is in 512 byte chunks
    local size_in_kb = res.f_blocks / 2

    print("Hard drive size: " .. size_in_kb .. "kB")
    print("Hard drive usage: " .. usage .. "%")

    collectgarbage("collect")
end

get_disk_usage()
