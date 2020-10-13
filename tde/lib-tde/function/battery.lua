function getBatteryInformationFromUpower(stdout)
    local battery = stdout:gsub("%%", "")
    local value = tonumber(battery)
    if value == nil then
        return
    end
    return value
end

-- return true if the battery is charging
-- pass in the result of checkBatteryOnlineScript
-- TODO: don't use a shell command - instead check file using lua
function isBatteryCharging(stdout)
    status = tonumber(stdout)
    return status == 1
end

local battery_script = [[
	sh -c "
	upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}'
"]]

local charger_script = [[
	sh -c '
	acpi_listen | grep --line-buffered ac_adapter
']]

return {
    getBatteryInformationFromUpower = getBatteryInformationFromUpower,
    upowerBatteryScript = battery_script,
    chargedScript = charger_script,
    checkBatteryOnlineScript = "cat /sys/class/power_supply/*/online",
    isBatteryCharging = isBatteryCharging
}
