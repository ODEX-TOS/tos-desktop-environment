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
local icons = require("theme.icons")

local dpi = require("beautiful").xresources.apply_dpi
local clickable_container = require("widget.material.clickable-container")

-- Load panel rules, it will create panel for each screen
require("widget.control-center.panel-rules")

local widget =
  wibox.widget {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local home_button = clickable_container(wibox.container.margin(widget, dpi(5), dpi(10), dpi(5), dpi(5)))

home_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        _G.screen.primary.left_panel:toggle()
      end
    )
  )
)

_G.screen.primary.left_panel:connect_signal(
  "opened",
  function()
    widget.icon:set_image(icons.close)
    _G.menuopened = true
  end
)

_G.screen.primary.left_panel:connect_signal(
  "closed",
  function()
    widget.icon:set_image(icons.settings)
    _G.menuopened = false
  end
)

widget.icon:set_image(icons.settings)

return home_button
