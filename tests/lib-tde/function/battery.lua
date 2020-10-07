local battery = require("tde.lib-tde.function.battery")

function test_lib_tde_battery()
    assert(battery)
    assert(type(battery) == "table")
end

function test_lib_tde_battery_exposior_charged_script()
    assert(battery.chargedScript)
    assert(type(battery.chargedScript) == "string")
end

function test_lib_tde_battery_exposior_battery_online_script()
    assert(battery.checkBatteryOnlineScript)
    assert(type(battery.checkBatteryOnlineScript) == "string")
end

function test_lib_tde_battery_exposior_battery_upower_script()
    assert(battery.upowerBatteryScript)
    assert(type(battery.upowerBatteryScript) == "string")
end

function test_lib_tde_battery_is_charging()
    assert(battery.isBatteryCharging)
    assert(type(battery.isBatteryCharging) == "function")
    -- isBatteryCharging expects /sys/class/power_supply/*/online state
    assert(not battery.isBatteryCharging(nil))
    assert(not battery.isBatteryCharging(""))
    assert(not battery.isBatteryCharging("0"))
    assert(not battery.isBatteryCharging(123))
    assert(battery.isBatteryCharging("1"))
    assert(battery.isBatteryCharging("1\n"))
    assert(battery.isBatteryCharging("1\n\n"))
    assert(battery.isBatteryCharging("\n1\n"))
    assert(not battery.isBatteryCharging("\n2\n"))
    assert(not battery.isBatteryCharging("\na\n"))
    assert(not battery.isBatteryCharging("\n0\n"))
end
