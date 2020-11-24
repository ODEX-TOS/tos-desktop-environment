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
local mat_slider = require("widget.material.slider")
local mat_icon_button = require("widget.material.icon-button")
local icons = require("theme.icons")
local spawn = require("awful.spawn")
local signals = require("lib-tde.signals")

local sound = require("lib-tde.sound")

local slider =
  wibox.widget {
  read_only = false,
  widget = mat_slider
}
_G.volume1 = slider
slider:connect_signal(
  "property::value",
  function()
    spawn("amixer -D pulse sset Master " .. slider.value .. "%")
    -- Only play sound when beeing drawn, we also remove the OSD from the screen
    _G.volume2:set_value(slider.value)
    signals.emit_volume(slider.value)
    if (_G.menuopened) then
      _G.toggleVolOSD(false)
      sound()
    end
  end
)

local update = function()
  awful.spawn.easy_async_with_shell(
    "amixer -D pulse sget Master",
    function(stdout)
      local volume = string.match(stdout, "(%d?%d?%d)%%")
      getIconByOutput(stdout)
      slider:set_value(tonumber(volume))
    end
  )
end
-- The emit will come from the OSD
awesome.connect_signal(
  "widget::volume",
  function(value)
    update()
  end
)

-- The emit will come from the OSD
awesome.connect_signal(
  "widget::volume:update",
  function(value)
    slider:set_value(tonumber(value))
  end
)

local icon =
  wibox.widget {
  image = icons.volume,
  widget = wibox.widget.imagebox
}

local button = mat_icon_button(icon)
_G.volumeIcon1 = icon
function getIcon()
  local command = "amixer -D pulse sget Master"
  awful.spawn.easy_async_with_shell(
    command,
    function(out)
      getIconByOutput(out)
    end
  )
end

function getIconByOutput(out)
  muted = string.find(out, "off")
  if (muted ~= nil or muted == "off") then
    icon.image = icons.muted
    _G.volumeIcon2.image = icons.muted
  else
    icon.image = icons.volume
    _G.volumeIcon2.image = icons.volume
  end
end

getIcon() -- set the icon property to the current volume state
update()
function toggleIcon()
  local command = "amixer -D pulse set Master +1 toggle"
  awful.spawn.easy_async_with_shell(
    command,
    function(out)
      muted = string.find(out, "off")
      if (muted ~= nil or muted == "off") then
        icon.image = icons.muted
        _G.volumeIcon2.image = icons.muted
      else
        icon.image = icons.volume
        _G.volumeIcon2.image = icons.volume
      end
    end
  )
end

button:connect_signal("button::press", toggleIcon)

local volume_setting =
  wibox.widget {
  button,
  slider,
  widget = mat_list_item
}

return volume_setting
