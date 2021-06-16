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
-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local filehandle = require("lib-tde.file")

local interface = "wlp2s01"

local function grabText()
    -- would have populated the widget from the result of this call
    io.popen("iw dev " .. interface .. " link")
end

function get_wifi_usage()
    local widgetIconName = "wifi-strength"
    local interface_res = filehandle.lines("/proc/net/wireless", nil, 3)[3]
    if interface_res == nil then
        connected = false
        collectgarbage("collect")
        return
    end

    local interface_name, num, link = interface_res:match("(%w+):%s+(%d+)%s+(%d+)")

    interface = interface_name
    print("Wifi interface: " .. interface)
    filehandle.overwrite("/tmp/interface.txt", interface_name)

    local wifi_strength = (tonumber(link) / 70) * 100
    if (wifi_strength ~= nil) then
        connected = true
        -- Update popup text
        local wifi_strength_rounded = math.floor(wifi_strength / 25 + 0.5)
        print("Wifi strenght: " .. wifi_strength_rounded)
        widgetIconName = widgetIconName .. "-" .. wifi_strength_rounded
    else
        connected = false
    end
    if (connected and (essid == "N/A" or essid == nil)) then
        grabText()
    end
    collectgarbage("collect")
end

get_wifi_usage()
