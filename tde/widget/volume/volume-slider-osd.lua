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
-- I decided to create another slider for the OSDs
-- So we can modify its behaviour without messing
-- the slider in the dashboard.
-- Excuse my messy code.

local wibox = require("wibox")
local mat_list_item = require("widget.material.list-item")
local mat_slider = require("widget.material.slider")
local mat_icon_button = require("widget.material.icon-button")
local icons = require("theme.icons")
local signal = require("lib-tde.signals")

local slider_osd =
  wibox.widget {
  read_only = false,
  widget = mat_slider
}

slider_osd:connect_signal(
  "property::value",
  function()
    signal.emit_volume(slider_osd.value)
  end
)

signal.connect_volume(
  function(value)
    local number = tonumber(value)
    if not (number == slider_osd.value) then
      slider_osd:set_value(number)
    end
  end
)

local icon =
  wibox.widget {
  image = icons.volume,
  widget = wibox.widget.imagebox
}

local button = mat_icon_button(icon)

button:connect_signal(
  "button::press",
  function()
    awful.spawn("amixer -D pulse set Master +1 toggle")
    signal.emit_volume_update()
  end
)

signal.connect_volume_is_muted(
  function(muted)
    if (muted) then
      icon.image = icons.muted
    else
      icon.image = icons.volume
    end
  end
)

local volume_setting_osd =
  wibox.widget {
  button,
  slider_osd,
  widget = mat_list_item
}

return volume_setting_osd
