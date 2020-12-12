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
local signal = require("lib-tde.signals")
local hardware = require("lib-tde.hardware-check")
local widget = require("desktop-widgets.widgets")
local config = require("desktop-widgets.config")

local cpu_value = 0

signal.connect_cpu_usage(
    function(value)
        cpu_value = value
    end
)

local function getCPUValue()
    return cpu_value
end

local function getRAMValue()
    local usage = hardware.getRamInfo()
    return usage
end

local width = mouse.screen.workarea.width
local height = mouse.screen.workarea.height

for _, element in ipairs(config) do
    local x = element.x * width
    local y = element.y * height
    local _width = element.width * width
    local _height = element.height * height
    if element.type == "chart" then
        if element.resource == "CPU" then
            widget.chart(x, y, _width, _height, element.title or "CPU Chart", getCPUValue, 5)
        else
            widget.chart(x, y, _width, _height, element.title or "RAM Chart", getRAMValue, 5)
        end
    else
        if element.resource == "CPU" then
            widget.radial(x, y, _width, _height, element.title or "CPU Widget", getCPUValue, 5)
        else
            widget.radial(x, y, _width, _height, element.title or "RAM Widget", getRAMValue, 5)
        end
    end
end
