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
local beautiful = require("beautiful")

local separator =
  wibox.widget {
  orientation = "vertical",
  forced_height = 16,
  opacity = 0.00,
  widget = wibox.widget.separator
}

local actionTitle =
  wibox.widget {
  text = "Action Center",
  font = "Iosevka Regular 10",
  align = "left",
  widget = wibox.widget.textbox
}

local actionWidget = require("widget.action-center")

return wibox.widget {
  spacing = 1,
  wibox.widget {
    wibox.widget {
      separator,
      actionTitle,
      bg = beautiful.bg_modal_title,
      layout = wibox.layout.fixed.vertical
    },
    widget = mat_list_item
  },
  layout = wibox.layout.fixed.vertical,
  {
    actionWidget,
    bg = beautiful.bg_modal,
    layout = wibox.layout.align.vertical
  }
}
