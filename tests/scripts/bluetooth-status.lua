-- This file tries to get a single cpu usage value
-- It is used to get to know how much time it takes to gain information about the cpu

require("lib-tde.luapath")
local file = require("lib-tde.file")

function get_bluetooth_state()
    local stdout = io.popen("bluetoothctl --monitor list"):read("*all")
    -- Check if there  bluetooth
    checker = stdout:match("Controller") -- If 'Controller' string is detected on stdout
    local widgetIconName

    local status = (checker ~= nil)

    if status then
        widgetIconName = "bluetooth"
    else
        widgetIconName = "bluetooth-off"
    end
    print("Polling bluetooth status: " .. tostring(status))
    collectgarbage("collect")
end

get_bluetooth_state()
