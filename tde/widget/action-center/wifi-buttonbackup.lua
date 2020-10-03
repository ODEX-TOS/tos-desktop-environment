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
local awful = require("awful")
local wibox = require("wibox")
local clickable_container = require("widget.action-center.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local watch = require("awful.widget.watch")

local PATH_TO_ICONS = "/etc/xdg/awesome/widget/action-center/icons/wifi/"
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
    widgetIconName = "wifi"
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
  else
    widgetIconName = "airplane-mode"
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
  end
end

local function check_wifi()
  awful.spawn.easy_async_with_shell(
    "nmcli general status",
    function(stdout)
      checker = stdout:match("disabled")
      -- IF NOT NULL THEN WIFI IS DISABLED
      -- IF NULL IT THEN WIFI IS ENABLED
      if (checker ~= nil) then
        mode = false
        --awful.spawn('notify-send checker~=NOTNULL disabled')
        update_icon()
      else
        mode = true
        --awful.spawn('notify-send checker==NULL enabled')
        update_icon()
      end
    end
  )
end

local function toggle_wifi()
  if (mode == true) then
    awful.spawn("nmcli r wifi off")
    awful.spawn("notify-send 'Airplane Mode Enabled'")
    mode = false
    update_icon()
  else
    awful.spawn("nmcli r wifi on")
    awful.spawn("notify-send 'Initializing WI-FI'")
    mode = true
    update_icon()
  end
end

check_wifi()

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

watch(
  "nmcli general status",
  5,
  function(_, stdout)
    -- Check if there  bluetooth
    checker = stdout:match("disabled") -- If 'Controller' string is detected on stdout
    local widgetIconName
    if (checker == nil) then
      widgetIconName = "wifi"
    else
      widgetIconName = "airplane-mode"
    end
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
    collectgarbage("collect")
  end,
  widget
)

return wifi_button
