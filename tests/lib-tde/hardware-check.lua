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
