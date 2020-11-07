-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local filehandle = require("lib-tde.file")

local interface = "wlp2s01"

local function grabText()
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
