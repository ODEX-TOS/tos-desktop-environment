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
    widgetIconName = "toggled-off"
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
  else
    widgetIconName = "toggled-on"
    widget.icon:set_image(PATH_TO_ICONS .. widgetIconName .. ".svg")
  end
end

local function check_oled()
  awful.spawn.easy_async_with_shell(
    "cat ~/.cache/oled || touch ~/.cache/oled",
    function(stdout)
      checker = stdout:match("on")
      -- IF NOT NULL THEN OLED is ON
      -- IF NULL IT THEN WIFI IS OFF
      if (checker ~= nil) then
        mode = false
        update_icon()
      else
        mode = true
        update_icon()
      end
    end
  )
end

local function toggle_oled()
  if (mode == true) then
    _G.oled = true
    awful.spawn([[sh -c "echo on > ~/.cache/oled"]])
    awful.spawn("notify-send 'Using OLED brightness mode'")
    mode = false
    update_icon()
  else
    _G.oled = false
    awful.spawn([[sh -c "echo off > ~/.cache/oled"]])
    awful.spawn("notify-send 'Using Backlight brightness mode'")
    mode = true
    update_icon()
  end
end

check_oled()

local oled_button = clickable_container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7))) -- 4 is top and bottom margin
oled_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        toggle_oled()
      end
    )
  )
)

-- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
awful.tooltip(
  {
    objects = {oled_button},
    mode = "outside",
    align = "right",
    timer_function = function()
      if checker == nil then
        return "Backlight brightness mode is ON"
      else
        return "OLED brightness mode is ON"
      end
    end,
    preferred_positions = {"right", "left", "top", "bottom"}
  }
)

local settingsName =
  wibox.widget {
  text = "OLED brightness mode",
  font = "Iosevka Regular 10",
  align = "left",
  widget = wibox.widget.textbox
}

local content =
  wibox.widget {
  settingsName,
  oled_button,
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
--return oled_button
