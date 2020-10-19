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

-- TODO: don't use a shell command - instead check file using lua

--- Return how much percentage a battery currently is, if no battery exists return nil
-- @param string stdout The output of @{upowerBatteryScript}
-- @return number a number between 0 and 100 indicating the battery percentage
-- @staticfct lib-tde.function.battery.getBatteryInformationFromUpower
-- @see upowerBatteryScript
-- @usage -- This will return a number like 87
-- awful.spawn.easy_async_with_shell(lib-tde.function.battery.upowerBatteryScript, function(stdout)
--      lib-tde.function.battery.getBatteryInformationFromUpower(stdout)
--end)
local function getBatteryInformationFromUpower(stdout)
    local battery = stdout:gsub("%%", "")
    local value = tonumber(battery)
    if value == nil then
        return
    end
    return value
end

--- Return true if the battery is charging
-- @param string stdout The output of @{chargedScript}
-- @return boolean a number between 0 and 100 indicating the battery percentage
-- @staticfct lib-tde.function.battery.isBatteryCharging
-- @see chargedScript
-- @usage -- This will return True
-- awful.spawn.easy_async_with_shell(lib-tde.function.battery.chargedScript, function(stdout)
--      lib-tde.function.battery.isBatteryCharging(stdout)
-- end)
local function isBatteryCharging(stdout)
    status = tonumber(stdout)
    return status == 1
end

--- A shell script to check what the current percentage of a battery is
-- @property upowerBatteryScript
-- @param string
local upowerBatteryScript = [[
	sh -c "
	upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}'
"]]

--- A shell script to check if a battery is beeing charged
-- @property chargedScript
-- @param string
local chargedScript = [[
	sh -c '
	acpi_listen | grep --line-buffered ac_adapter
']]

return {
    getBatteryInformationFromUpower = getBatteryInformationFromUpower,
    upowerBatteryScript = upowerBatteryScript,
    chargedScript = chargedScript,
    checkBatteryOnlineScript = "cat /sys/class/power_supply/*/online",
    isBatteryCharging = isBatteryCharging
}
