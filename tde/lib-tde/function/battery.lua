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
--     local isCharging = lib-tde.function.battery.isBatteryCharging()
--
-- Another example is to check the current battery percentage
--
--     local percentage = lib-tde.function.battery.getBatteryPercentage()

--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.battery
---------------------------------------------------------------------------

local filehandle = require("lib-tde.file")


local _path_cache

local function sys_file_to_int(file)
    local value = filehandle.string(file)
    if value == nil or value == "" then return -1 end

    if value then
        value = value:gsub("\n", "")
        return tonumber(value) or -1
    end

    return -1
end

--- Check if a battery exists
-- @return string The percentage of the battery
-- @staticfct getBatteryPath
-- @usage -- This will /sys/class/power_supply/BAT0 if it exists
-- lib-tde.function.battery.getBatteryPath() -- return location of the battery state
local function getBatteryPath()
    if filehandle.dir_exists(_path_cache) then
        return _path_cache
    end

    -- check if battery 0 or 1 exists
    local battery_base_dir = "/sys/class/power_supply"
    local data = filehandle.list_dir(battery_base_dir)
    for _, item in ipairs(data) do
        if string.find(filehandle.basename(item), "BAT") ~= nil then
            _path_cache = item
            return _path_cache
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
        if value == "Charging" or value == "fully" then
            return true
        end
    end
    return false
end

--- Return the percentage of the battery or -1 (if no battery exists)
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

    -- Let's do an accurate calculation, in case that fails we will fallback to a less accurate way
    local charge_now = sys_file_to_int(battery.. '/charge_now')
    local charge_full = sys_file_to_int(battery.. '/charge_full')

    if charge_full ~= -1 and charge_now ~= -1 then
        return (charge_now / charge_full) * 100
    end


    local energy_now = sys_file_to_int(battery.. '/energy_now')
    local energy_full = sys_file_to_int(battery.. '/energy_full')

    if energy_full ~= -1 and energy_now ~= -1 then
        return (energy_now / energy_full) * 100
    end


    -- In case we can't calculate the accurate usage we need to do it with the less precise implementation
    return sys_file_to_int(battery .. "/capacity")
end

--- Return the percentage of the battery degradation (e.g. how much charge the battery can hold now vs when it was in the factory)
-- @return number The percentage of the battery degradation
-- @staticfct getBatteryDegradation
-- @usage -- This will depend on how good the battery can store it's charge when fully charged
-- lib-tde.function.battery.getBatteryDegradation() -- return percentage of battery degradation
local function getBatteryDegradation()
    -- get back a battery location
    local battery = getBatteryPath()
    if battery == nil then
        return nil
    end

    -- Let's do an accurate calculation, in case that fails we will fallback to a less accurate way
    local charge_now = sys_file_to_int(battery.. '/charge_full')
    local charge_full = sys_file_to_int(battery.. '/charge_full_design')

    if charge_full ~= -1 and charge_now ~= -1 then
        return (charge_now / charge_full) * 100
    end

    local energy_now = sys_file_to_int(battery.. '/energy_full')
    local energy_full = sys_file_to_int(battery.. '/energy_full_design')

    if energy_full ~= -1 and energy_now ~= -1 then
        return (energy_now / energy_full) * 100
    end

    -- In case we can't calculate the degradation simply return what it would be at the factory
    return 100
end

return {
    isBatteryCharging = isBatteryCharging,
    getBatteryPercentage = getBatteryPercentage,
    getBatteryPath = getBatteryPath,
    getBatteryDegradation = getBatteryDegradation
}
