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
local config = require("tde.config")

function test_config_package_timeout()
    assert(config.package_timeout)
    assert(type(config.package_timeout) == "number")
    assert(config.package_timeout > 1)
end

function test_config_battery_timeout()
    assert(config.battery_timeout)
    assert(type(config.battery_timeout) == "number")
    assert(config.battery_timeout > 10)
end

function test_config_player_reaction_time()
    assert(config.player_reaction_time)
    assert(type(config.player_reaction_time) == "number")
    assert(config.player_reaction_time < 0.1)
end

function test_config_player_update()
    assert(config.player_update)
    assert(type(config.player_update) == "number")
    assert(config.player_update > 1)
end

function test_config_network_poll()
    assert(config.network_poll)
    assert(type(config.network_poll) == "number")
    assert(config.network_poll > 1)
end

function test_config_bluetooth_poll()
    assert(config.bluetooth_poll)
    assert(type(config.bluetooth_poll) == "number")
    assert(config.bluetooth_poll > 1)
end

function test_config_temp_poll()
    assert(config.temp_poll)
    assert(type(config.temp_poll) == "number")
    assert(config.temp_poll > 1)
end

function test_config_ram_poll()
    assert(config.ram_poll)
    assert(type(config.ram_poll) == "number")
    assert(config.ram_poll > 1)
end

function test_config_weather_poll()
    assert(config.weather_poll)
    assert(type(config.weather_poll) == "number")
    assert(config.weather_poll > 60)
end

function test_config_cpu_poll()
    assert(config.cpu_poll)
    assert(type(config.cpu_poll) == "number")
    assert(config.cpu_poll > 1)
end

function test_about_tde_and_tos()
    assert(config.aboutText)
    assert(config.aboutText:find("TOS"))
    assert(config.aboutText:find("MIT License"))
    assert(config.aboutText:find("Tom Meyers") or config.aboutText:find("Meyers Tom"))
end
