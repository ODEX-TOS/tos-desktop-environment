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
    assert(config.package_timeout, "Check that the config api is correct")
    assert(type(config.package_timeout) == "number", "The config type should be a number")
    assert(config.package_timeout > 1, "Expected the value to be less than 1")
end

function test_config_battery_timeout()
    assert(config.battery_timeout, "Check that the config api is correct")
    assert(type(config.battery_timeout) == "number", "The config type should be a number")
    assert(config.battery_timeout > 10, "Expected the value to be greater than 10")
end

function test_config_player_reaction_time()
    assert(config.player_reaction_time, "Check that the config api is correct")
    assert(type(config.player_reaction_time) == "number", "The config type should be a number")
    assert(config.player_reaction_time < 0.1, "Expected the value to be less than 0.1")
end

function test_config_player_update()
    assert(config.player_update, "Check that the config api is correct")
    assert(type(config.player_update) == "number", "The config type should be a number")
    assert(config.player_update >= 1, "Expected the value to be greater than 1")
end

function test_config_network_poll()
    assert(config.network_poll, "Check that the config api is correct")
    assert(type(config.network_poll) == "number", "The config type should be a number")
    assert(config.network_poll > 1, "Expected the value to be greater than 1")
end

function test_config_bluetooth_poll()
    assert(config.bluetooth_poll, "Check that the config api is correct")
    assert(type(config.bluetooth_poll) == "number", "The config type should be a number")
    assert(config.bluetooth_poll > 1, "Expected the value to be greater than 1")
end

function test_config_temp_poll()
    assert(config.temp_poll, "Check that the config api is correct")
    assert(type(config.temp_poll) == "number", "The config type should be a number")
    assert(config.temp_poll > 1, "Expected the value to be greater than 1")
end

function test_config_ram_poll()
    assert(config.ram_poll, "Check that the config api is correct")
    assert(type(config.ram_poll) == "number", "The config type should be a number")
    assert(config.ram_poll > 1, "Expected the value to be greater than 1")
end

function test_config_weather_poll()
    assert(config.weather_poll, "Check that the config api is correct")
    assert(type(config.weather_poll) == "number", "The config type should be a number")
    assert(config.weather_poll > 60, "Expected the value to be greater than 60")
end

function test_config_cpu_poll()
    assert(config.cpu_poll, "Check that the config api is correct")
    assert(type(config.cpu_poll) == "number", "The config type should be a number")
    assert(config.cpu_poll > 1, "Expected the value to be greater than 1")
end

function test_config_compton_file()
    assert(config.getComptonFile, "Check that the config api is correct")
    assert(type(config.getComptonFile) == "function", "The config type should be a function")
end

function test_config_colors_config()
    assert(config.colors_config, "Check that the config api is correct")
    assert(type(config.colors_config) == "string", "The config type should be a string")
end

function test_config_icons_config()
    assert(config.icons_config, "Check that the config api is correct")
    assert(type(config.icons_config) == "string", "The config type should be a string")
end

function test_config_garbage_cycle()
    assert(config.garbage_collection_cycle, "Check that the config api is correct")
    assert(type(config.garbage_collection_cycle) == "number", "The config type should be a number")
    assert(config.garbage_collection_cycle > 60, "garbage collection is very taxing on resources, don't call it ofter")
end

function test_about_tde_and_tos()
    assert(config.aboutText, "Make sure the about text exists")
    assert(config.aboutText:find("TDE"), "TDE must be mentioned in the about text: " .. config.aboutText)
    assert(
        config.aboutText:find("MIT License"),
        "The license must be mentioned in the about text: " .. config.aboutText
    )
    assert(
        config.aboutText:find("Tom Meyers") or config.aboutText:find("Meyers Tom"),
        "The main developer must be mentioned in the about text: " .. config.aboutText
    )
end

function test_config_api_unit_tested()
    local amount = 21
    local result = tablelength(config)
    assert(
        result == amount,
        "You didn't test all config options, please add them then update the amount to: " .. result
    )
end
