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
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
local signals = require("lib-tde.signals")

local bottom_panel = function(s)
  local action_bar_width = dpi(45) -- 48

  local panel =
    wibox {
    screen = s,
    height = s.geometry.height,
    width = action_bar_width,
    type = "dock",
    x = s.geometry.x + s.geometry.width - action_bar_width,
    y = s.geometry.y + dpi(26),
    ontop = true,
    bg = beautiful.background.hue_800,
    fg = beautiful.fg_normal,
    visible = true
  }

  signals.connect_background_theme_changed(
    function(theme)
      panel.bg = theme.hue_800 .. beautiful.background_transparency
    end
  )

  screen.connect_signal(
    "removed",
    function(removed)
      if panel.screen == removed then
        panel.visible = false
        panel = nil
      end
    end
  )

  -- this is called when we need to update the screen
  signals.connect_refresh_screen(
    function()
      print("Refreshing right-panel")
      if panel == nil or panel == nil then
        return
      end
      panel.x = s.geometry.x + s.geometry.width - action_bar_width
      panel.y = s.geometry.y + dpi(26)
      panel.width = action_bar_width
      panel.height = s.geometry.height
    end
  )

  panel:struts(
    {
      right = action_bar_width
    }
  )

  panel:setup {
    layout = wibox.layout.align.vertical,
    require("layout.left-panel.action-bar")(s, action_bar_width)
  }
  return panel
end

return bottom_panel
