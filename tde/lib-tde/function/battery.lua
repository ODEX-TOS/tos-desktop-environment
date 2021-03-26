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
---------------------------------------------------------------------------
-- This module contains useful helper functions when working with batteries.
--
-- To get the charging status of the battery you must do an asynchronous call to not block the main thread
-- a function call must be wrapped in a `awful.spawn.easy_async_with_shell`
--
--     awful.spawn.easy_async_with_shell(lib-tde.function.battery.chargedScript, function(stdout)
--        lib-tde.function.battery.isBatteryCharging(stdout) -- returns is the battery is charging e.g. false
--     end)
--
-- Another example is to check the current battery percentage
--
--     awful.spawn.easy_async_with_shell(lib-tde.function.battery.upowerBatteryScript, function(stdout)
--        lib-tde.function.battery.getBatteryInformationFromUpower(stdout) -- returns battery percentage e.g. 87
--     end)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.battery
---------------------------------------------------------------------------

local filehandle = require("lib-tde.file")

--- Check if a battery exists
-- @return string The percentage of the battery
-- @staticfct getBatteryPath
-- @usage -- This will /sys/class/power_supply/BAT0 if it exists
-- lib-tde.function.battery.getBatteryPath() -- return location of the battery state
local function getBatteryPath()
    -- check if battery 0 or 1 exists
    local battery_base_dir = "/sys/class/power_supply"
    local data = filehandle.list_dir(battery_base_dir)
    for _, item in ipairs(data) do
        if string.find(filehandle.basename(item), "BAT") ~= nil then
            return item
        end
    end
    return nil
end

--- Return true if the battery is charging
-- @return boolean True if it is charging
-- @staticfct isBatteryCharging
-- @usage -- This will return True if charging
--  lib-tde.function.battery.isBatteryCharging() -- True
local function isBatteryCharging()
    local battery = getBatteryPath()
    if battery then
        local value = filehandle.string(battery .. "/status"):gsub("\n", "")
        if value == "Charging" then
            return true
        end
    end
    return false
end

--- Return the percentage of the battery or nil (if no battery exists)
-- @return number The percentage of the battery
-- @staticfct getBatteryPercentage
-- @usage -- This will 100 if fully charged
-- lib-tde.function.battery.getBatteryPercentage() -- return percentage of battery
local function getBatteryPercentage()
    -- get back a battery location
    local battery = getBatteryPath()
    if battery == nil then
        return nil
    end

    -- battery exists, lets get the percentage back
    local value = filehandle.string(battery .. "/capacity")
    if value then
        value = value:gsub("\n", "")
        return tonumber(value)
    end
    -- something went wrong parsing the value
    return 0
end

return {
    isBatteryCharging = isBatteryCharging,
    getBatteryPercentage = getBatteryPercentage,
    getBatteryPath = getBatteryPath
}
