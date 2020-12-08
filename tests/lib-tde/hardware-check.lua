local hardware = require("tde.lib-tde.hardware-check")

function test_hardware_check_packages()
    -- every tos system must have the pacman package installed
    assert(hardware.has_package_installed("pacman"))
    -- every tos system must have the filesystem package installed
    assert(hardware.has_package_installed("filesystem"))

    -- normally this package shouldn't exists (if for a magical reason it does exist then modify here)
    assert(not hardware.has_package_installed(""))
    assert(not hardware.has_package_installed("jdibqyudbuqyzuyduq"))
    assert(not hardware.has_package_installed(nil))
    assert(not hardware.has_package_installed(123))
end

function test_hardware_check_ip_valid_return()
    local split = require("tde.lib-tde.function.common").split
    local ip = hardware.getDefaultIP()
    assert(type(ip) == "string")
    assert(#split(ip, ".") == 4)
end

function test_hardware_check_api()
    assert(type(hardware.hasBattery) == "function")
    assert(type(hardware.hasWifi) == "function")
    assert(type(hardware.hasBluetooth) == "function")
    assert(type(hardware.hasFFMPEG) == "function")
    assert(type(hardware.hasSound) == "function")
    assert(type(hardware.has_package_installed) == "function")
    assert(type(hardware.getDefaultIP) == "function")
    assert(type(hardware.getRamInfo) == "function")
    assert(type(hardware.getCpuInfo) == "function")
    assert(type(hardware.isWeakHardware) == "function")
    assert(type(hardware.getDisplayFrequency) == "function")
    assert(type(hardware.execute) == "function")
end
