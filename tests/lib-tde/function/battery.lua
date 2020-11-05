local battery = require("tde.lib-tde.function.battery")

function test_lib_tde_battery()
    assert(battery)
    assert(type(battery) == "table")
end

function test_lib_tde_battery_exposior_path()
    assert(battery.getBatteryPath)
    assert(type(battery.getBatteryPath) == "function")
end

function test_lib_tde_battery_is_charging()
    assert(battery.isBatteryCharging)
    assert(type(battery.isBatteryCharging) == "function")
end

function test_lib_tde_battery_percentage()
    assert(battery.getBatteryPercentage)
    assert(type(battery.getBatteryPercentage) == "function")
end
