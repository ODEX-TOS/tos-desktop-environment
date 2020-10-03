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
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local dpi = require("beautiful").xresources.apply_dpi
local clickable_container = require("widget.material.clickable-container")

local active_button = "#ffffff" .. "40"
local inactive_button = "#ffffff" .. "20"

local notif_text =
  wibox.widget {
  text = "Notifications",
  font = "SFNS Display Regular 12",
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox
}

local notif_button = clickable_container(wibox.container.margin(notif_text, dpi(0), dpi(0), dpi(7), dpi(7))) -- 4 is top and bottom margin

local wrap_notif =
  wibox.widget {
  notif_button,
  forced_width = dpi(140),
  bg = active_button,
  shape = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true, 6)
  end,
  widget = wibox.container.background
}

local widgets_text =
  wibox.widget {
  text = "Widgets",
  font = "SFNS Display Regular 12",
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox
}

local widgets_button = clickable_container(wibox.container.margin(widgets_text, dpi(0), dpi(0), dpi(7), dpi(7)))

local wrap_widget =
  wibox.widget {
  widgets_button,
  forced_width = dpi(140),
  bg = inactive_button,
  shape = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, 6)
  end,
  widget = wibox.container.background
}

local switcher =
  wibox.widget {
  expand = "none",
  layout = wibox.layout.fixed.horizontal,
  {
    wrap_notif,
    layout = wibox.layout.fixed.horizontal
  },
  {
    wrap_widget,
    layout = wibox.layout.fixed.horizontal
  }
}

function switch_mode(right_panel_mode)
  if right_panel_mode == "notif_mode" then
    -- Update button color
    wrap_notif.bg = active_button
    wrap_widget.bg = inactive_button
    -- Change panel content of right-panel.lua
    _G.screen.primary.right_panel:switch_mode(right_panel_mode)
  elseif right_panel_mode == "widgets_mode" then
    -- Update button color
    wrap_notif.bg = inactive_button
    wrap_widget.bg = active_button
    -- Change panel content of right-panel.lua
    _G.screen.primary.right_panel:switch_mode(right_panel_mode)
  end
end

notif_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        switch_mode("notif_mode")
      end
    )
  )
)

widgets_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        switch_mode("widgets_mode")
      end
    )
  )
)

return switcher
