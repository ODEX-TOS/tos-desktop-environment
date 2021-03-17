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
-- This is an example of a little bit more complex widgets
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local theme = require("theme.icons.dark-light")

local beautiful = require("beautiful")

local PATH_TO_ICONS = os.getenv("HOME") .. "/.config/tde/hello-world-widget/icons/"

-- generate the icon widget
local hello_icon_widget =
  wibox.widget {
  {
    id = "icon",
    image = theme(PATH_TO_ICONS .. "world" .. ".svg"),
    resize = true,
    forced_height = dpi(45),
    forced_width = dpi(45),
    widget = wibox.widget.imagebox
  },
  layout = wibox.layout.fixed.horizontal
}

-- generate a text widget that acts like the header
local hello_header =
  wibox.widget {
  text = "Hello, World!",
  font = "SFNS Display Regular 14",
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox
}

-- generate a text widget that acts like a subtitle
local hello_subtitle =
  wibox.widget {
  text = "Good to see you",
  font = "SFNS Display Regular 16",
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

-- the entire widget that will be included
return wibox.widget {
  expand = "none",
  layout = wibox.layout.fixed.vertical,
  {
    -- this section colors the header bar in a different color that the body of the widget
    -- it also gives the header rounded corners
    wibox.widget {
      wibox.container.margin(hello_header, dpi(10), dpi(10), dpi(10), dpi(10)),
      bg = beautiful.bg_modal_title,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 6)
      end,
      widget = wibox.container.background
    },
    layout = wibox.layout.fixed.vertical
  },
  -- Body of the widget (icon + text)
  {
    {
      expand = "none",
      layout = wibox.layout.fixed.horizontal,
      {
        wibox.widget {
          hello_icon_widget,
          margins = dpi(4),
          widget = wibox.container.margin
        },
        margins = dpi(5),
        widget = wibox.container.margin
      },
      {
        {
          layout = wibox.layout.fixed.vertical,
          hello_subtitle
        },
        margins = dpi(4),
        widget = wibox.container.margin
      }
    },
    -- round the bottom of the widget as well
    bg = beautiful.bg_modal,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 6)
    end,
    widget = wibox.container.background
  }
}
