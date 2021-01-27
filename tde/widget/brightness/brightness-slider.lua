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
local slider = require("lib-widget.slider")
local mat_icon_button = require("widget.material.icon-button")
local icons = require("theme.icons")
local signals = require("lib-tde.signals")

local spawn = require("awful.spawn")

local brightness_slider =
  slider(
  5,
  100,
  1,
  5,
  function(value)
    if (_G.menuopened) then
      _G.brightness2.update(value)
    end
    if (_G.oled) then
      spawn("brightness -s " .. value .. " -F") -- toggle pixel values
    else
      spawn("brightness -s 100 -F") -- reset pixel values
      spawn("brightness -s " .. value)
    end
  end
)

_G.brightness1 = brightness_slider

local update = function()
  awful.spawn.easy_async_with_shell(
    [[grep -q on ~/.cache/oled && brightness -g -F || brightness -g]],
    function(stdout)
      local brightness = string.match(stdout, "(%d+)")
      signals.emit_brightness(tonumber(brightness))
    end
  )
end

awesome.connect_signal(
  "widget::brightness",
  function(_)
    update()
  end
)

-- The emit will come from the OSD
signals.connect_brightness(
  function(value)
    brightness_slider.update(value)
  end
)

local icon =
  wibox.widget {
  image = icons.brightness,
  widget = wibox.widget.imagebox
}

local button = mat_icon_button(icon)

local brightness_setting =
  wibox.widget {
  button,
  brightness_slider,
  widget = mat_list_item
}

return brightness_setting
