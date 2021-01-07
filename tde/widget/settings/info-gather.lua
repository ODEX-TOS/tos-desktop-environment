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
end

local function get_distro_name()
    -- get the distro
    if filehandle.exists("/etc/os-release") then
        local lines = filehandle.lines("/etc/os-release")
        for _, line in ipairs(lines) do
            if string.find(line, "NAME") then
                local distroname = line:match('"(.*)"')
                signals.emit_distro(distroname)
                break
            end
        end
    end
end

local function get_uptime()
    -- get the uptime
    awful.widget.watch(
        "uptime -p",
        600,
        function(_, stdout)
            local uptime = string.gsub(stdout, "%\n", "") or ""
            signals.emit_uptime(uptime)
        end
    )
end

local function get_ram_info()
    delayed_timer(
        config.ram_poll,
        function()
            local usage, total = hardware.getRamInfo()
            signals.emit_ram_usage(usage)
            signals.emit_ram_total(total)
            print("Ram usage: " .. usage .. "%")
        end,
        config.ram_startup_delay
    )
end

local function get_disk_info()
    delayed_timer(
        config.harddisk_poll,
        function()
            local res = statvfs("/")
            local usage = ((res.f_blocks - res.f_bfree) / res.f_blocks) * 100

            -- by default f_blocks is in 512 byte chunks
            local block_size = res.f_frsize or 512
            local size_in_bytes = res.f_blocks * block_size

            print("Hard drive size: " .. size_in_bytes .. "b")
            print("Hard drive usage: " .. usage .. "%")

            signals.emit_disk_usage(usage)
            signals.emit_disk_space(common.bytes_to_grandness(size_in_bytes))
        end,
        config.harddisk_startup_delay
    )
end

local function init()
    get_username()
    get_distro_name()
    get_uptime()
    get_ram_info()
    get_disk_info()

    -- TODO: don't create a dependency to the left panel
    -- extract that info here
end

init()
