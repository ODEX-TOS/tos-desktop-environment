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
local signals = require("tde.lib-tde.signals")

function test_emit_module_exit_screen_hide_exists()
    assert(signals.emit_module_exit_screen_hide)
    assert(type(signals.emit_module_exit_screen_hide) == "function")
end

function test_connect_module_exit_screen_hide_exists()
    assert(signals.connect_module_exit_screen_hide)
    assert(type(signals.connect_module_exit_screen_hide) == "function")
end

function test_emit_module_exit_screen_show_exists()
    assert(signals.emit_module_exit_screen_show)
    assert(type(signals.emit_module_exit_screen_show) == "function")
end

function test_connect_module_exit_screen_show_exists()
    assert(signals.connect_module_exit_screen_show)
    assert(type(signals.connect_module_exit_screen_show) == "function")
end

function test_emit_battery_exists()
    assert(signals.emit_battery)
    assert(type(signals.emit_battery) == "function")
end

function test_connect_battery_exists()
    assert(signals.connect_battery)
    assert(type(signals.connect_battery) == "function")
end

function test_emit_battery_charging_exists()
    assert(signals.emit_battery_charging)
    assert(type(signals.emit_battery_charging) == "function")
end

function test_connect_battery_charging_exists()
    assert(signals.connect_battery_charging)
    assert(type(signals.connect_battery_charging) == "function")
end

function test_emit_brightness_exists()
    assert(signals.emit_brightness)
    assert(type(signals.emit_brightness) == "function")
end

function test_connect_brightness_exists()
    assert(signals.connect_brightness)
    assert(type(signals.connect_brightness) == "function")
end

function test_emit_volume_exists()
    assert(signals.emit_volume)
    assert(type(signals.emit_volume) == "function")
end

function test_connect_volume_exists()
    assert(signals.connect_volume)
    assert(type(signals.connect_volume) == "function")
end

function test_connect_weather_exists()
    assert(signals.connect_weather)
    assert(type(signals.connect_weather) == "function")
end

function test_emit_username_exists()
    assert(signals.emit_username)
    assert(type(signals.emit_username) == "function")
end

function test_connect_username_exists()
    assert(signals.connect_username)
    assert(type(signals.connect_username) == "function")
end

function test_emit_distro_exists()
    assert(signals.emit_distro)
    assert(type(signals.emit_distro) == "function")
end

function test_connect_distro_exists()
    assert(signals.connect_distro)
    assert(type(signals.connect_distro) == "function")
end

function test_emit_uptime_exists()
    assert(signals.emit_uptime)
    assert(type(signals.emit_uptime) == "function")
end

function test_connect_uptime_exists()
    assert(signals.connect_uptime)
    assert(type(signals.connect_uptime) == "function")
end

function test_emit_kernel_exists()
    assert(signals.emit_kernel)
    assert(type(signals.emit_kernel) == "function")
end

function test_connect_kernel_exists()
    assert(signals.connect_kernel)
    assert(type(signals.connect_kernel) == "function")
end

function test_emit_packages_to_update_exists()
    assert(signals.emit_packages_to_update)
    assert(type(signals.emit_packages_to_update) == "function")
end

function test_connect_packages_to_update_exists()
    assert(signals.connect_packages_to_update)
    assert(type(signals.connect_packages_to_update) == "function")
end

function test_emit_cpu_usage_exists()
    assert(signals.emit_cpu_usage)
    assert(type(signals.emit_cpu_usage) == "function")
end

function test_connect_cpu_usage_exists()
    assert(signals.connect_cpu_usage)
    assert(type(signals.connect_cpu_usage) == "function")
end

function test_emit_disk_usage_exists()
    assert(signals.emit_disk_usage)
    assert(type(signals.emit_disk_usage) == "function")
end

function test_connect_disk_usage_exists()
    assert(signals.connect_disk_usage)
    assert(type(signals.connect_disk_usage) == "function")
end

function test_emit_disk_space_exists()
    assert(signals.emit_disk_space)
    assert(type(signals.emit_disk_space) == "function")
end

function test_connect_disk_space_exists()
    assert(signals.connect_disk_space)
    assert(type(signals.connect_disk_space) == "function")
end

function test_emit_ram_usage_exists()
    assert(signals.emit_ram_usage)
    assert(type(signals.emit_ram_usage) == "function")
end

function test_connect_ram_usage_exists()
    assert(signals.connect_ram_usage)
    assert(type(signals.connect_ram_usage) == "function")
end

function test_emit_ram_total_exists()
    assert(signals.emit_ram_total)
    assert(type(signals.emit_ram_total) == "function")
end

function test_connect_ram_total_exists()
    assert(signals.connect_ram_total)
    assert(type(signals.connect_ram_total) == "function")
end

function test_emit_bluetooth_status_exists()
    assert(signals.emit_bluetooth_status)
    assert(type(signals.emit_bluetooth_status) == "function")
end

function test_connect_bluetooth_status_exists()
    assert(signals.connect_bluetooth_status)
    assert(type(signals.connect_bluetooth_status) == "function")
end

function test_emit_wifi_status_exists()
    assert(signals.emit_wifi_status)
    assert(type(signals.emit_wifi_status) == "function")
end

function test_connect_wifi_status_exists()
    assert(signals.connect_wifi_status)
    assert(type(signals.connect_wifi_status) == "function")
end
