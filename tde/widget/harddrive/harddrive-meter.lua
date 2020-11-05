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
local mat_slider = require("widget.material.slider")
local mat_icon = require("widget.material.icon")
local icons = require("theme.icons")
local dpi = require("beautiful").xresources.apply_dpi
local config = require("config")
local gears = require("gears")
local signals = require("lib-tde.signals")
local filehandle = require("lib-tde.file")
local common = require("lib-tde.function.common")

local slider =
  wibox.widget {
  read_only = true,
  widget = mat_slider
}

gears.timer {
  timeout = config.harddisk_poll,
  call_now = true,
  autostart = true,
  callback = function()
    local lines = filehandle.lines("/proc/partitions")

    -- find all hardisk and their size
    local size = 0
    for _, line in ipairs(lines) do
      local nvmeSize, nvmdName = line:match(" %d* *%d* *(%d*) (nvme...)$")
      if nvmeSize ~= nil and nvmdName ~= nil then
        size = size + tonumber(nvmeSize)
      end

      local sataSize, sataName = line:match(" %d* *%d* *(%d*) (sd[a-z])$")
      if sataSize ~= nil and sataName ~= nil then
        size = size + tonumber(sataSize)
      end
    end

    signals.emit_disk_usage(10)
    signals.emit_disk_space(common.bytes_to_grandness(size, 1))

    collectgarbage("collect")
  end
}

local harddrive_meter =
  wibox.widget {
  wibox.widget {
    icon = icons.harddisk,
    size = dpi(24),
    widget = mat_icon
  },
  slider,
  widget = mat_list_item
}

return harddrive_meter
