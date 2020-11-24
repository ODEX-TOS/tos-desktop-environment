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
local wibox = require("wibox")
local mat_list_item = require("widget.material.list-item")
local mat_slider = require("widget.material.progress_bar")
local mat_icon = require("widget.material.icon")
local icons = require("theme.icons")
local dpi = require("beautiful").xresources.apply_dpi
local config = require("config")
local file = require("lib-tde.file")
local signals = require("lib-tde.signals")
local gears = require("gears")
local delayed_timer = require("lib-tde.function.delayed-timer")
local slider =
  wibox.widget {
  read_only = true,
  widget = mat_slider
}

delayed_timer(
  config.ram_poll,
  function()
    local stdout = file.lines("/proc/meminfo", nil, 24)
    if #stdout < 3 then
      return
    end
    local total = string.gmatch(stdout[1], "%d+")()
    local free = string.gmatch(stdout[2], "%d+")()
    local buffer = string.gmatch(stdout[4], "%d+")()
    local cache = string.gmatch(stdout[5], "%d+")()
    local sReclaimable = string.gmatch(stdout[24], "%d+")()

    -- the used ram in kB
    local used = total - free - buffer - cache - sReclaimable

    -- the usage in percent
    local usage = (used / total) * 100
    slider:set_value(usage)
    signals.emit_ram_usage(usage)
    signals.emit_ram_total(total)
    print("Ram usage: " .. usage .. "%")
  end,
  config.ram_startup_delay
)

local ram_meter =
  wibox.widget {
  wibox.widget {
    icon = icons.memory,
    size = dpi(24),
    widget = mat_icon
  },
  slider,
  widget = mat_list_item
}

return ram_meter
