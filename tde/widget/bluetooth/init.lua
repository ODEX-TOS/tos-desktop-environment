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
-------------------------------------------------
-- Bluetooth Widget for Awesome Window Manager
-- Shows the bluetooth status using the bluetoothctl command
-- Better with Blueman Manager
--------------

local watch = require("awful.widget.watch")
local wibox = require("wibox")
local clickable_container = require("widget.material.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local config = require("config")
local theme = require("theme.icons.dark-light")
local signals = require("lib-tde.signals")
-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local PATH_TO_ICONS = "/etc/xdg/awesome/widget/bluetooth/icons/"
local checker

local widget =
  wibox.widget {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local widget_button = clickable_container(wibox.container.margin(widget, dpi(8), dpi(8), dpi(8), dpi(8)))
widget_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        print("Opening blueman-manager")
        awful.spawn("blueman-manager")
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
      if checker ~= nil then
        return i18n.translate("Bluetooth is on")
      else
        return i18n.translate("Bluetooth is off")
      end
    end,
    preferred_positions = {"right", "left", "top", "bottom"}
  }
)

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery"):
--beautiful.tooltip_fg = beautiful.fg_normal
--beautiful.tooltip_bg = beautiful.bg_normal

watch(
  "bluetoothctl --monitor list",
  config.bluetooth_poll,
  function(_, stdout)
    -- Check if there  bluetooth
    checker = stdout:match("Controller") -- If 'Controller' string is detected on stdout
    local widgetIconName

    local status = (checker ~= nil)
    signals.emit_bluetooth_status(status)

    if status then
      widgetIconName = "bluetooth"
    else
      widgetIconName = "bluetooth-off"
    end
    widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. ".svg"))
    print("Polling bluetooth status")
    collectgarbage("collect")
  end,
  widget
)

return widget_button
