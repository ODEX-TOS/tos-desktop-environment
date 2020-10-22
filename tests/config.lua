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

function test_config_harddisk_poll()
    assert(config.hardisk_poll)
    assert(type(config.hardisk_poll) == "number")
    assert(config.hardisk_poll > 120)
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

function test_config_proc_poll()
    assert(config.proc_poll)
    assert(type(config.proc_poll) == "number")
    assert(config.proc_poll > 1)
end

function test_about_tde_and_tos()
    assert(config.aboutText)
    assert(config.aboutText:find("TOS"))
    assert(config.aboutText:find("MIT License"))
    assert(config.aboutText:find("Tom Meyers") or config.aboutText:find("Meyers Tom"))
end
