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
local gears = require("gears")
local signals = require("lib-tde.signals")
local filehandle = require("lib-tde.file")
local common = require("lib-tde.function.common")
local delayed_timer = require("lib-tde.function.delayed-timer")

local slider =
  wibox.widget {
  read_only = true,
  widget = mat_slider
}

delayed_timer(
  config.harddisk_poll,
  function()
    local statvfs = require "posix.sys.statvfs".statvfs
    local res = statvfs("/")
    local usage = (res.f_bfree / res.f_blocks) * 100

    -- by default f_blocks is in 512 byte chunks
    local block_size = res.f_frsize or 512
    local size_in_bytes = res.f_blocks * block_size

    print("Hard drive size: " .. size_in_bytes .. "b")
    print("Hard drive usage: " .. usage .. "%")

    slider:set_value(usage)

    signals.emit_disk_usage(usage)
    signals.emit_disk_space(common.bytes_to_grandness(size_in_bytes))

    collectgarbage("collect")
  end,
  config.harddisk_startup_delay
)

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
