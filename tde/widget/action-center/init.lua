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
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local gap = 1

local mat_list_item = require("widget.material.list-item")

local barColor = beautiful.bg_modal
local wifibutton = require("widget.action-center.wifi-button")
local oledbutton = require("widget.action-center.oled-button")
local bluebutton = require("widget.action-center.bluetooth-button")
local comptonbutton = require("widget.action-center.compositor-button")
local comptonBackendbutton = require("widget.action-center.compositor-backend-button")

-- TODO: use the lib-widget based checkboxes

local widget =
  wibox.widget {
  spacing = gap,
  -- Wireless Connection
  wibox.widget {
    wibox.widget {
      wifibutton,
      bg = barColor,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 12)
      end,
      widget = wibox.container.background
    },
    widget = mat_list_item
  },
  -- Bluetooth Connection
  wibox.widget {
    wibox.widget {
      bluebutton,
      bg = barColor,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, 12)
      end,
      widget = wibox.container.background
    },
    widget = mat_list_item
  },
  -- OLED Toggle
  wibox.widget {
    wibox.widget {
      oledbutton,
      bg = barColor,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, 12)
      end,
      widget = wibox.container.background
    },
    widget = mat_list_item
  },
  -- Compositor Toggle
  wibox.widget {
    wibox.widget {
      comptonbutton,
      bg = barColor,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, 12)
      end,
      widget = wibox.container.background
    },
    widget = mat_list_item
  },
  -- Compositor Backend Toggle
  layout = wibox.layout.fixed.vertical,
  wibox.widget {
    wibox.widget {
      comptonBackendbutton,
      bg = barColor,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 12)
      end,
      widget = wibox.container.background
    },
    widget = mat_list_item
  }
}

return wibox.container.margin(widget, 0, 0, dpi(20), dpi(20))
