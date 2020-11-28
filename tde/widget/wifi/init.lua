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
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local config = require("config")
local theme = require("theme.icons.dark-light")
local filehandle = require("lib-tde.file")
local signals = require("lib-tde.signals")

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local PATH_TO_ICONS = "/etc/xdg/tde/widget/wifi/icons/"
local interface = "wlp2s01"

local connected = false
local essid = "N/A"

local widget =
  wibox.widget {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local widget_button = clickable_container(wibox.container.margin(widget, dpi(14), dpi(14), 7, 7)) -- default top bottom margin is 7
widget_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn("nm-connection-editor")
      end
    )
  )
)

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
awful.tooltip(
  {
    objects = {widget_button},
    mode = "outside",
    align = "right",
    timer_function = function()
      if connected then
        return i18n.translate("Connected to ") .. essid
      else
        return i18n.translate("Wireless network is disconnected")
      end
    end,
    preferred_positions = {"right", "left", "top", "bottom"},
    margin_leftright = dpi(8),
    margin_topbottom = dpi(8)
  }
)

local function grabText()
  if connected then
    awful.spawn.easy_async(
      "iw dev " .. interface .. " link",
      function(stdout)
        essid = stdout:match("SSID:(.-)\n")
        if (essid == nil) then
          essid = "N/A"
        end
        print("Network essid: " .. essid)
      end
    )
  end
end

gears.timer {
  timeout = config.network_poll,
  call_now = true,
  autostart = true,
  callback = function()
    local widgetIconName = "wifi-strength"
    local interface_res = filehandle.lines("/proc/net/wireless", nil, 3)[3]
    if interface_res == nil then
      connected = false
      signals.emit_wifi_status(false)
      widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. "-off" .. ".svg"))
      return
    end

    local interface_name, _, link = interface_res:match("(%w+):%s+(%d+)%s+(%d+)")

    interface = interface_name
    filehandle.overwrite("/tmp/interface.txt", interface_name)

    local wifi_strength = (tonumber(link) / 70) * 100
    if (wifi_strength ~= nil) then
      connected = true
      -- Update popup text
      local wifi_strength_rounded = math.floor(wifi_strength / 25 + 0.5)
      widgetIconName = widgetIconName .. "-" .. wifi_strength_rounded
      widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. ".svg"))
    else
      connected = false
      widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. "-off" .. ".svg"))
    end
    if (connected and (essid == "N/A" or essid == nil)) then
      grabText()
    end
    signals.emit_wifi_status(connected)
  end
}

widget:connect_signal(
  "mouse::enter",
  function()
    grabText()
  end
)

return widget_button
