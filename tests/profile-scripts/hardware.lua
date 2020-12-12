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

print("Display frequency: " .. hardware.getDisplayFrequency() .. " Hz")
print("IP address: " .. hardware.getDefaultIP())
print("CPU usage: " .. hardware.getCpuInfo() .. " %")
print("Ram usage: " .. hardware.getRamInfo() .. " %")
print("Has battery: " .. tostring(hardware.hasBattery()))
print("Has bluetooth: " .. tostring(hardware.hasBluetooth()))
print("Has ffpmeg installed: " .. tostring(hardware.hasFFMPEG()))
print("Has sound: " .. tostring(hardware.hasSound()))
print("Has wifi: " .. tostring(hardware.hasWifi()))
