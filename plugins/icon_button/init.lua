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
-- Require needed libraries

local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local dpi = require("beautiful").xresources.apply_dpi

-- a widget container that is clickable
local clickable_container = require("widget.material.clickable-container")

local theme = require("theme.icons.dark-light")
-- wrap the path to the icon in a theme() call
-- this will change the icon depending on the theme eg dark or light
local icon = theme(os.getenv("HOME") .. "/.config/tde/icon_button/" .. "icons/info.svg")

-- put the icon into a widget
local widget =
  wibox.widget {
  {
    id = "icon",
    image = icon,
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

-- convert the above widget into a button using clickable_container
local widget_button =
  clickable_container(
  --dpi(14) is used to take different screen sizes into consideration
  wibox.container.margin(widget, dpi(14), dpi(14), dpi(6), dpi(6))
)
widget_button:buttons(
  gears.table.join(
    awful.button(
      {},
      -- 1 denotes left mouse button
      1,
      nil,
      -- function that is ran when left mouse button is pressed
      function()
        print("Clicked button!")
      end
    )
  )
)

-- return the clickable widget to be used as the widget
return widget_button
