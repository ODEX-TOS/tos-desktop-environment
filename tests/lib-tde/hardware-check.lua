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
