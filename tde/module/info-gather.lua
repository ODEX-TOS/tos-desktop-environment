--[[
--MIT License
--
--Copyright (c) 2019 manilarome
--Copyright (c) 2020 Tom Meyers
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.
]]
local signals = require("lib-tde.signals")
local hardware = require("lib-tde.hardware-check")
local filehandle = require("lib-tde.file")
local config = require("config")
local delayed_timer = require("lib-tde.function.delayed-timer")
local statvfs = require("posix.sys.statvfs").statvfs
local common = require("lib-tde.function.common")

local function get_username()
    -- get the username
    local username = os.getenv("USER")

    -- make the first letter capital
    local name = username:sub(1, 1):upper() .. username:sub(2)

    signals.emit_username(name)

    signals.connect_request_user(function()
        signals.emit_username(name)
    end)
end

local function get_distro_name()
    local name = ""
    -- get the distro
    if filehandle.exists("/etc/os-release") then
        local lines = filehandle.lines("/etc/os-release")
        for _, line in ipairs(lines) do
            if string.find(line, "NAME") then
                name = line:match('"(.*)"')
                break
            end
        end
    end

    signals.connect_request_distro(function()
        signals.emit_distro(name)
    end)
end



local function get_uptime()
    local function uptime_func()
        awful.spawn.easy_async("uptime -p", function (stdout)
            local uptime = string.gsub(stdout, "%\n", "") or ""
            signals.emit_uptime(uptime)
        end)
    end

    delayed_timer(
        600,
        uptime_func,
        0
    )

    signals.connect_request_uptime(uptime_func)
end

local function get_ram_info()
    local function ram_func()
        local usage, total = hardware.getRamInfo()
        signals.emit_ram_usage(usage)
        signals.emit_ram_total(common.num_to_str(total))
        print("Ram usage: " .. usage .. "%")
    end
    delayed_timer(
        config.ram_poll,
        ram_func,
        config.ram_startup_delay
    )

    signals.connect_request_ram(ram_func)
end

local function get_disk_info()
    local function disk_func()
        local res = statvfs("/")
        local usage = ((res.f_blocks - res.f_bfree) / res.f_blocks) * 100

        -- by default f_blocks is in 512 byte chunks
        local block_size = res.f_frsize or 512
        local size_in_bytes = res.f_blocks * block_size

        print("Hard drive size: " .. size_in_bytes .. "b")
        print("Hard drive usage: " .. usage .. "%")

        signals.emit_disk_usage(usage)
        signals.emit_disk_space(common.bytes_to_grandness(size_in_bytes))
    end

    delayed_timer(
        config.harddisk_poll,
        disk_func,
        config.harddisk_startup_delay
    )

    signals.connect_request_ram(disk_func)
end


local function get_profile_pic()
    signals.connect_request_profile_pic(
        function()
            local picture = "/etc/xdg/tde/widget/user-profile/icons/user.svg"
            if filehandle.exists(os.getenv("HOME") .. "/.face") then
              picture = os.getenv("HOME") .. "/.face"
            end

            print("Loading profile picture")
            signals.emit_profile_picture_changed(picture)
        end
    )
end

local function get_kernel()
    local kernel = "N/A"
    awful.spawn.easy_async_with_shell(
        "uname -r | cut -d '-' -f 1,2",
        function(out)
          kernel = out:gsub("%\n", "")
          signals.emit_kernel(kernel)
        end
      )

    signals.connect_request_kernel(function ()
        signals.emit_kernel(kernel)
    end)
end

local function get_cpu()
    local total_prev = 0
    local idle_prev = 0

    local last_cpu_state = 100

    delayed_timer(
        config.cpu_poll,
        function()
            local stdout = filehandle.string("/proc/stat", "^cpu")
            if stdout == "" then
                return
            end
            local user, nice, system, idle, iowait, irq, softirq, steal, _, _ =
            stdout:match("(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s")

            local total = user + nice + system + idle + iowait + irq + softirq + steal

            local diff_idle = idle - idle_prev
            local diff_total = total - total_prev
            local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10

            print("CPU usage: " .. diff_usage .. "%")
            signals.emit_cpu_usage(diff_usage)
            last_cpu_state = diff_usage

            total_prev = total
            idle_prev = idle
        end,
        config.cpu_startup_delay
    )

    signals.connect_request_cpu(function()
        signals.emit_cpu_usage(last_cpu_state)
    end)
end

local function init()
    get_username()
    get_distro_name()
    get_uptime()
    get_ram_info()
    get_disk_info()
    get_cpu()

    get_profile_pic()

    get_kernel()
end

init()
