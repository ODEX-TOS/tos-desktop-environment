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
local clickable_container = require("widget.action-center.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local mat_list_item = require("widget.material.list-item")
local signals = require("lib-tde.signals")

local PATH_TO_ICONS = "/etc/xdg/awesome/widget/action-center/icons/"
local checker
local mode

local widget =
  wibox.widget {
  {
    id = "icon",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local function update_icon()
  local widgetIconName
  if (mode == true) then
    widgetIconName = "toggled-on"
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
  else
    widgetIconName = "toggled-off"
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
  end
end

local function toggle_wifi()
  if (mode == true) then
    awful.spawn("nmcli r wifi off")
    awful.spawn("notify-send 'Airplane Mode Enabled'")
    signals.emit_wifi_status(false)
  else
    awful.spawn("nmcli r wifi on")
    awful.spawn("notify-send 'Initializing WI-FI'")
    signals.emit_wifi_status(true)
  end
end

local wifi_button = clickable_container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7))) -- 4 is top and bottom margin
wifi_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        toggle_wifi()
      end
    )
  )
)

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
awful.tooltip(
  {
    objects = {wifi_button},
    mode = "outside",
    align = "right",
    timer_function = function()
      if checker == nil then
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
    if active then
      mode = true
      widgetIconName = "toggled-on"
      update_icon()
    else
      mode = false
      widgetIconName = "toggled-off"
      update_icon()
    end
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
    collectgarbage("collect")
  end
)

local settingsName =
  wibox.widget {
  text = "Wireless Connection",
  font = "Iosevka Regular 10",
  align = "left",
  widget = wibox.widget.textbox
}

local content =
  wibox.widget {
  settingsName,
  wifi_button,
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
