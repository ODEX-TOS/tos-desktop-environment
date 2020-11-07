-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local file = require("lib-tde.file")
local sleep = require("lib-tde.function.common").sleep

local idle_prev = 0
local total_prev = 0

function get_cpu_usage()
    stdout = file.string("/proc/stat", "^cpu")
    if stdout == "" then
        return
    end
    local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
        stdout:match("(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s")

    local total = user + nice + system + idle + iowait + irq + softirq + steal

    local diff_idle = idle - idle_prev
    local diff_total = total - total_prev
    local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

    print("CPU usage: " .. diff_usage .. "%")

    total_prev = total
    idle_prev = idle
    collectgarbage("collect")
end

get_cpu_usage()
sleep(1)
get_cpu_usage()
