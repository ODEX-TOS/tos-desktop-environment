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
local battery = require("tde.lib-tde.function.battery")

function Test_lib_tde_battery()
    assert(battery, "The battery api should exist")
    assert(type(battery) == "table", "The battery api should be in a list")
end

function Test_lib_tde_battery_exposior_path()
    assert(battery.getBatteryPath, "Finding the active battery should exist")
    assert(type(battery.getBatteryPath) == "function", "Finding the active battery should be a function")
end

function Test_lib_tde_battery_is_charging()
    assert(battery.isBatteryCharging, "Charging the battery should exist")
    assert(type(battery.isBatteryCharging) == "function", "Charging the battery should be a function")
end

function Test_lib_tde_battery_percentage()
    assert(battery.getBatteryPercentage, "Getting the battery percentage should exist")
    assert(type(battery.getBatteryPercentage) == "function", "Getting the battery percentage should be a function")
end

function Test_lib_tde_battery_degradation()
    assert(battery.getBatteryDegradation, "Getting the battery degradation should exist")
    assert(type(battery.getBatteryDegradation) == "function", "Getting the battery degradation should be a function")
end


function Test_battery_api_unit_tested()
    local amount = 4
    local result = tablelength(battery)
    assert(
        result == amount,
        "You didn't test all battery api endpoints, please add them then update the amount to: " .. result
    )
end
