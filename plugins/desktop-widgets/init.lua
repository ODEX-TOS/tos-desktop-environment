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
