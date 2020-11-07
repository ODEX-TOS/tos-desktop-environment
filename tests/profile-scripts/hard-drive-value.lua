-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local file = require("lib-tde.file")

function get_disk_usage()
    local lines = file.lines("/proc/partitions")

    -- find all hardisk and their size
    local size = 0
    for _, line in ipairs(lines) do
        local nvmeSize, nvmdName = line:match(" %d* *%d* *(%d*) (nvme...)$")
        if nvmeSize ~= nil and nvmdName ~= nil then
            size = size + tonumber(nvmeSize)
        end

        local sataSize, sataName = line:match(" %d* *%d* *(%d*) (sd[a-z])$")
        if sataSize ~= nil and sataName ~= nil then
            size = size + tonumber(sataSize)
        end
    end
    print("Hard drive size: " .. size .. "kB")
    collectgarbage("collect")
end

get_disk_usage()
