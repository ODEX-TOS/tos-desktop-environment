---------------------------------------------------------------------------
-- This module contains usefull helper functions when working with batteries.
--
-- To get the charging status of the battery you must do an asynchronous call to not block the main thread
-- a function call must be wrapped in a awful.spawn.easy_async_with_shell
--
--     awful.spawn.easy_async_with_shell(lib-tde.function.battery.chargedScript, function(stdout)
--        lib-tde.function.battery.isBatteryCharging(stdout) -- returns is the battery is charging eg false
--     end)
--
-- Another example is to check the current battery percentage
--
--     awful.spawn.easy_async_with_shell(lib-tde.function.battery.upowerBatteryScript, function(stdout)
--        lib-tde.function.battery.getBatteryInformationFromUpower(stdout) -- returns battery percentage eg 87
--     end)
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
    local bat0 = "/sys/class/power_supply/BAT0"
    local bat1 = "/sys/class/power_supply/BAT1"
    if filehandle.dir_exists(bat0) then
        return bat0
    end
    if filehandle.dir_exists(bat1) then
        return bat1
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
