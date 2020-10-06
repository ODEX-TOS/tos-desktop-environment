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
-- I decided to create another slider for the OSDs
-- So we can modify its behaviour without messing
-- the slider in the dashboard.
-- Excuse my messy code.

local wibox = require("wibox")
local mat_list_item = require("widget.material.list-item")
local mat_slider = require("widget.material.slider")
local mat_icon_button = require("widget.material.icon-button")
local icons = require("theme.icons")
local spawn = require("awful.spawn")
local awful = require("awful")
local sound = require("lib-tde.sound")

local bootup = true

local slider_osd =
  wibox.widget {
  read_only = false,
  widget = mat_slider
}

local function single_shot_play()
  if bootup then
    bootup = false
  else
    sound()
  end
end

_G.volume2 = slider_osd
slider_osd:connect_signal(
  "property::value",
  function()
    if (not _G.menuopened) then
      spawn("amixer -D pulse sset Master " .. slider_osd.value .. "%")
      single_shot_play()
      awesome.emit_signal("widget::volume:update", slider_osd.value)
    end
  end
)

-- A hackish way for the OSD not to hide
-- when the user is dragging the slider
-- Slider or the handle does not have a
-- Signal that handles the 'on drag' event
-- So here we are.
slider_osd:connect_signal(
  "button::press",
  function()
    slider_osd:connect_signal(
      "property::value",
      function()
        _G.toggleVolOSD(true)
      end
    )
  end
)

function UpdateVolOSD()
  awful.spawn.easy_async_with_shell(
    "bash -c 'amixer -D pulse sget Master'",
    function(stdout)
      local mute = string.match(stdout, "%[(o%D%D?)%]")
      local volume = string.match(stdout, "(%d?%d?%d)%%")
      slider_osd:set_value(tonumber(volume))
    end
  )
end

local icon =
  wibox.widget {
  image = icons.volume,
  widget = wibox.widget.imagebox
}

local button = mat_icon_button(icon)

_G.volumeIcon2 = icon
button:connect_signal(
  "button::press",
  function()
    local command = "amixer -D pulse set Master +1 toggle"
    awful.spawn.easy_async_with_shell(
      command,
      function(out)
        muted = string.find(out, "off")
        if (muted ~= nil or muted == "off") then
          icon.image = icons.muted
          _G.volumeIcon1.image = icons.muted
        else
          icon.image = icons.volume
          _G.volumeIcon1.image = icons.volume
          sound()
        end
      end
    )
  end
)

local volume_setting_osd =
  wibox.widget {
  button,
  slider_osd,
  widget = mat_list_item
}

return volume_setting_osd
