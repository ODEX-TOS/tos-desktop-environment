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

local action_status = false

-- Imagebox
local button_widget =
  wibox.widget {
  {
    id = "icon",
    image = PATH_TO_ICONS .. "toggled-off" .. ".svg",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

-- Update imagebox
local update_imagebox = function()
  if action_status then
    button_widget.icon:set_image(PATH_TO_ICONS .. "toggled-on" .. ".svg")
  else
    button_widget.icon:set_image(PATH_TO_ICONS .. "toggled-off" .. ".svg")
  end
end

-- Power on Commands
local power_on_cmd =
  [[
rfkill unblock bluetooth
echo 'power on' | bluetoothctl
notify-send 'Initializing bluetooth Service...'
]]

-- Power off Commands
local power_off_cmd =
  [[
echo 'power off' | bluetoothctl
rfkill block bluetooth
notify-send 'Bluetooth device disabled'
]]

local toggle_action = function()
  if action_status then
    action_status = false
    awful.spawn.easy_async_with_shell(
      power_off_cmd,
      function(stdout)
      end,
      false
    )
  else
    action_status = true
    awful.spawn.easy_async_with_shell(
      power_on_cmd,
      function(stdout)
      end,
      false
    )
  end

  -- Update imagebox
  update_imagebox()
end

-- Button
local widget_button = clickable_container(wibox.container.margin(button_widget, dpi(7), dpi(7), dpi(7), dpi(7)))
widget_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        toggle_action()
      end
    )
  )
)

-- Tootltip
awful.tooltip {
  objects = {widget_button},
  mode = "outside",
  align = "right",
  timer_function = function()
    if action_status == true then
      return i18n.translate("Bluetooth Enabled")
    else
      return i18n.translate("Bluetooth Disabled")
    end
  end,
  preferred_positions = {"right", "left", "top", "bottom"}
}

-- Status Checker
signals.connect_bluetooth_status(
  function(status)
    if status then
      action_status = true
      button_widget.icon:set_image(PATH_TO_ICONS .. "toggled-on" .. ".svg")
    else
      action_status = false
      button_widget.icon:set_image(PATH_TO_ICONS .. "toggled-off" .. ".svg")
    end
    collectgarbage("collect")
  end
)

-- Action Name
local action_name =
  wibox.widget {
  text = i18n.translate("Bluetooth Connection"),
  font = "SFNS Display 11",
  align = "left",
  widget = wibox.widget.textbox
}

local content =
  wibox.widget {
  action_name,
  widget_button,
  bg = "#ffffff20",
  shape = gears.shape.rect,
  widget = wibox.container.background(settingsName),
  layout = wibox.layout.ratio.horizontal
}
content:set_ratio(1, .85)

-- Wrapping
local action_widget =
  wibox.widget {
  wibox.widget {
    content,
    widget = mat_list_item
  },
  layout = wibox.layout.fixed.vertical
}

-- Return widget
return action_widget
