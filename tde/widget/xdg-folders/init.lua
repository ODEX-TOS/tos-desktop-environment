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
local dpi = require("beautiful").xresources.apply_dpi
local has_package_installed = require("lib-tde.hardware-check").has_package_installed
local seperator_widget = require("lib-widget.separator")

local separator_horizontal = wibox.container.margin(
  seperator_widget({
    height = dpi(1),
    orientation = "horizontal",
    opacity = 0.2
  }), 0, 0, dpi(10), dpi(10))

local separator_vertical =
  wibox.container.margin(
  wibox.widget {
    orientation = "vertical",
    forced_width = dpi(1),
    opacity = 0.20,
    widget = wibox.widget.separator
  },
  dpi(10),
  dpi(10),
  0,
  0
)

return function(position)
  if position == "left" then
    local _layout = wibox.widget {
      separator_horizontal,
      require("widget.xdg-folders.home"),
      require("widget.xdg-folders.documents"),
      require("widget.xdg-folders.downloads"),
      require("widget.xdg-folders.pictures"),
      layout = wibox.layout.fixed.vertical
    }

    has_package_installed("gvfs", function (installed)
      if installed then
        _layout:add(separator_horizontal)
        _layout:add(require("widget.xdg-folders.trash"))
      end
    end)

    local widget = wibox.widget {
      layout = wibox.layout.align.vertical,
      _layout
    }
    return widget
  end

  local _layout = wibox.widget {
    separator_vertical,
    require("widget.xdg-folders.home"),
    require("widget.xdg-folders.documents"),
    require("widget.xdg-folders.downloads"),
    require("widget.xdg-folders.pictures"),
    layout = wibox.layout.fixed.horizontal
  }

  has_package_installed("gvfs", function (installed)
    if installed then
      _layout:add(separator_vertical)
      _layout:add(require("widget.xdg-folders.trash"))
    end
  end)

  local widget = wibox.widget {
      layout = wibox.layout.align.horizontal,
      _layout
    }
  return widget
end
