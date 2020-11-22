-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")

function get_disk_usage()
    -- find all hardisk and their size
    local statvfs = require "posix.sys.statvfs".statvfs
    local res = statvfs("/")
    local usage = (res.f_bfree / res.f_blocks) * 100

    -- by default f_blocks is in 512 byte chunks
    local block_size = res.f_frsize or 512
    local size_in_bytes = res.f_blocks * block_size

    print("Hard drive size: " .. size_in_bytes .. "B")
    print("Hard drive usage: " .. usage .. "%")

    collectgarbage("collect")
end

get_disk_usage()
