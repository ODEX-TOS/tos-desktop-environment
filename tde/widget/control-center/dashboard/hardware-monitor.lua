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

local mat_list_item = require("widget.material.list-item")

function build(screen)
  local hardwareTitle =
    wibox.widget {
    text = "Hardware monitor",
    font = "Iosevka Regular 10",
    align = "left",
    widget = wibox.widget.textbox
  }

  local barColor = beautiful.bg_modal
  local cpu = require("widget.cpu.cpu-meter")
  local ram = require("widget.ram.ram-meter")
  local temp = require("widget.temperature.temperature-meter")
  local drive = require("widget.harddrive.harddrive-meter")
  local network_up = require("widget.network.network-meter")(true, screen)
  local network_down = require("widget.network.network-meter")(false, screen)

  return wibox.widget {
    spacing = 1,
    wibox.widget {
      wibox.widget {
        hardwareTitle,
        bg = beautiful.bg_modal_title,
        layout = wibox.layout.flex.vertical
      },
      widget = mat_list_item
    },
    wibox.widget {
      wibox.widget {
        cpu,
        bg = barColor,
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 12)
        end,
        widget = wibox.container.background
      },
      widget = mat_list_item
    },
    wibox.widget {
      wibox.widget {
        ram,
        bg = barColor,
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, 12)
        end,
        widget = wibox.container.background
      },
      widget = mat_list_item
    },
    wibox.widget {
      wibox.widget {
        temp,
        bg = barColor,
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, 12)
        end,
        widget = wibox.container.background
      },
      widget = mat_list_item
    },
    wibox.widget {
      wibox.widget {
        drive,
        bg = barColor,
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, 12)
        end,
        widget = wibox.container.background
      },
      widget = mat_list_item
    },
    wibox.widget {
      wibox.widget {
        network_up,
        bg = barColor,
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, 12)
        end,
        widget = wibox.container.background
      },
      widget = mat_list_item
    },
    layout = wibox.layout.fixed.vertical,
    wibox.widget {
      wibox.widget {
        network_down,
        bg = barColor,
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 12)
        end,
        widget = wibox.container.background
      },
      widget = mat_list_item
    }
  }
end

return build
