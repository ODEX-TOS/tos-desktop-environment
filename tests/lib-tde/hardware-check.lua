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
    assert(hardware.has_package_installed("pacman"), "Package 'pacman' should be installed")
    -- every tos system must have the filesystem package installed
    assert(hardware.has_package_installed("filesystem"), "Package 'filesystem' should be installed")

    -- normally this package shouldn't exists (if for a magical reason it does exist then modify here)
    assert(not hardware.has_package_installed(""), "Empty packages should not exist")
    assert(not hardware.has_package_installed("jdibqyudbuqyzuyduq"), "'jdibqyudbuqyzuyduq' package should not exist")
    assert(not hardware.has_package_installed(nil), "Nil is an invalid package name")
    assert(not hardware.has_package_installed(123), "type number is not allowed as a package name, use string instead")
end

function test_hardware_check_ip_valid_return()
    local split = require("tde.lib-tde.function.common").split
    local ip = hardware.getDefaultIP()
    assert(type(ip) == "string", "Local Ip should be returned as a string")
    assert(#split(ip, ".") == 4, "The ip address is not formatted correctly")
end

function test_hardware_check_api()
    assert(type(hardware.hasBattery) == "function", "Make sure the hardware api has a hasBattery function")
    assert(type(hardware.hasWifi) == "function", "Make sure the hardware api has a hasWifi function")
    assert(type(hardware.hasBluetooth) == "function", "Make sure the hardware api has a hasBluetooth function")
    assert(type(hardware.hasFFMPEG) == "function", "Make sure the hardware api has a hasFFMPEG function")
    assert(type(hardware.hasSound) == "function", "Make sure the hardware api has a hasSound function")
    assert(
        type(hardware.has_package_installed) == "function",
        "Make sure the hardware api has a has_package_installed function"
    )
    assert(type(hardware.getDefaultIP) == "function", "Make sure the hardware api has a getDefaultIP function")
    assert(type(hardware.getRamInfo) == "function", "Make sure the hardware api has a getRamInfo function")
    assert(type(hardware.getCpuInfo) == "function", "Make sure the hardware api has a getCpuInfo function")
    assert(type(hardware.isWeakHardware) == "function", "Make sure the hardware api has a isWeakHardware function")
    assert(
        type(hardware.getDisplayFrequency) == "function",
        "Make sure the hardware api has a getDisplayFrequency function"
    )
    assert(type(hardware.execute) == "function", "Make sure the hardware api has a execute function")
end
