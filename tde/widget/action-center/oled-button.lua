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
local dpi = require("beautiful").xresources.apply_dpi
local checkbox = require("lib-widget.checkbox")
local mat_list_item = require("widget.material.list-item")
local signals = require("lib-tde.signals")

local mode

local function update_oled()
  if (mode == true) then
    _G.oled = true
    awful.spawn("notify-send 'Using OLED brightness mode'")
  else
    _G.oled = false
    awful.spawn("notify-send 'Using Backlight brightness mode'")
  end
  signals.emit_oled_mode(mode)
end

local oled_button =
  checkbox(
  mode,
  function(checked)
    mode = checked
    update_oled()
  end
)

signals.connect_oled_mode(
  function(new_mode)
    mode = new_mode
    oled_button.update(mode)
  end
)

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
awful.tooltip(
  {
    objects = {oled_button},
    mode = "outside",
    align = "right",
    timer_function = function()
      if mode == true then
        return i18n.translate("Backlight brightness mode is ON")
      else
        return i18n.translate("OLED brightness mode is ON")
      end
    end,
    preferred_positions = {"right", "left", "top", "bottom"}
  }
)

local settingsName =
  wibox.widget {
  text = i18n.translate("OLED brightness mode"),
  font = "Iosevka Regular 10",
  align = "left",
  widget = wibox.widget.textbox
}

local content =
  wibox.widget {
  settingsName,
  wibox.container.margin(oled_button, 0, 0, dpi(5), dpi(5)),
  bg = "#ffffff20",
  shape = gears.shape.rect,
  widget = wibox.container.background(settingsName),
  layout = wibox.layout.ratio.horizontal
}
content:set_ratio(1, .85)

local oledButton =
  wibox.widget {
  wibox.widget {
    content,
    widget = mat_list_item
  },
  layout = wibox.layout.fixed.vertical
}
return oledButton
