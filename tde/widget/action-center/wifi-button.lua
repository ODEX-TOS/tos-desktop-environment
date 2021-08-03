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
local mat_list_item = require("widget.material.list-item")
local signals = require("lib-tde.signals")
local checkbox = require("lib-widget.checkbox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local mode

local function update_wifi()
  if (mode == false) then
    awful.spawn("nmcli r wifi off", false)
    awful.spawn("notify-send 'Airplane Mode Enabled'", false)
    signals.emit_wifi_status(false)
  else
    awful.spawn("nmcli r wifi on", false)
    awful.spawn("notify-send 'Initializing WI-FI'", false)
    signals.emit_wifi_status(true)
  end
end

local wifi_button =
  checkbox(
  mode,
  function(checked)
    mode = checked
    update_wifi()
  end
)

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
awful.tooltip(
  {
    objects = {wifi_button},
    mode = "outside",
    align = "right",
    timer_function = function()
      if mode then
        return "WI-FI is ON"
      else
        return "Airplane Mode"
      end
    end,
    preferred_positions = {"right", "left", "top", "bottom"}
  }
)

signals.connect_wifi_status(
  function(active)
    mode = active
    wifi_button.update(active)
  end
)

local settingsName =
  wibox.widget {
  text = i18n.translate("Wireless Connection"),
  font = "Iosevka Regular 10",
  align = "left",
  widget = wibox.widget.textbox
}

local content =
  wibox.widget {
  settingsName,
  wibox.container.margin(wifi_button, 0, 0, dpi(5), dpi(5)),
  bg = "#ffffff20",
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background(settingsName),
  layout = wibox.layout.ratio.horizontal
}
content:set_ratio(1, .85)

local wifiButton =
  wibox.widget {
  wibox.widget {
    content,
    widget = mat_list_item
  },
  layout = wibox.layout.fixed.vertical
}
return wifiButton
--return wifi_button
