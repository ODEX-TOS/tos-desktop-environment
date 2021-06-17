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
local volume = require("lib-tde.volume")

local vol_slider =
  slider(
  0,
  100,
  1,
  0,
  function(value)
    signals.emit_volume(value)
  end
)

local icon =
  wibox.widget {
  image = icons.volume,
  widget = wibox.widget.imagebox
}

signals.connect_volume(
  function(value)
    local number = tonumber(value)
    if not (number == vol_slider.value) then
      vol_slider.update(number)
    end
  end
)

local button = mat_icon_button(icon)

local function toggleIcon()
  volume.toggle_master()
  signals.emit_volume_update()
end

signals.connect_volume_is_muted(
  function(muted)
    if (muted) then
      icon.image = icons.muted
    else
      icon.image = icons.volume
    end
  end
)

button:connect_signal("button::press", toggleIcon)

local volume_setting =
  wibox.widget {
  button,
  vol_slider,
  widget = mat_list_item
}

signals.emit_volume_update()

return volume_setting
