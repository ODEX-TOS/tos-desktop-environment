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
local spawn = require("awful.spawn")
local signals = require("lib-tde.signals")

local slider_osd =
  slider({
  callback = function(value)
    if (_G.menuopened) then
      signals.emit_brightness(tonumber(value))
    end
    if (_G.oled) then
      spawn("brightness -s " .. math.max(value, 5) .. " -F") -- toggle pixel values
    else
      spawn("brightness -s 100 -F") -- reset pixel values
      spawn("brightness -s " .. math.max(value, 5))
    end
  end
})
_G.brightness2 = slider_osd

slider_osd:connect_signal(
  "button::press",
  function()
    slider_osd:connect_signal(
      "property::value",
      function()
        _G.toggleBriOSD(true)
      end
    )
  end
)

local function UpdateBrOSD()
  if (_G.oled) then
    awful.spawn.easy_async_with_shell(
      "brightness -g -F",
      function(stdout)
        local brightness = string.match(stdout, "(%d+)")
        slider_osd.update(tonumber(brightness))
        signals.emit_brightness(tonumber(brightness))
      end
    )
  else
    awful.spawn.easy_async_with_shell(
      "brightness -g",
      function(stdout)
        local brightness = string.match(stdout, "(%d+)")
        slider_osd.update(tonumber(brightness))
        signals.emit_brightness(tonumber(brightness))
      end
    )
  end
end

_G.UpdateBrOSD = UpdateBrOSD

local icon =
  wibox.widget {
  image = icons.brightness,
  widget = wibox.widget.imagebox
}

local button = mat_icon_button(icon)

local brightness_setting_osd =
  wibox.widget {
  button,
  slider_osd,
  widget = mat_list_item
}

return brightness_setting_osd
