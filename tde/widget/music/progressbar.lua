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
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi

local progressbar =
  wibox.widget {
  {
    id = "bar",
    max_value = 100,
    forced_height = dpi(3),
    forced_width = dpi(100),
    shape = gears.shape.rounded_bar,
    color = "#fdfdfd",
    widget = wibox.widget.progressbar,
    background_color = "#ffffff20"
  },
  layout = wibox.layout.stack
}

local timeStatus =
  wibox.widget {
  id = "statustime",
  font = "SFNS Display 10",
  align = "center",
  valign = "center",
  forced_height = dpi(10),
  widget = wibox.widget.textbox
}

local timeDuration =
  wibox.widget {
  id = "durationtime",
  font = "SFNS Display 10",
  align = "center",
  valign = "center",
  forced_height = dpi(10),
  widget = wibox.widget.textbox
}

-- Update time progress every 5 seconds
local updateTime =
  gears.timer {
  timeout = 5,
  autostart = true,
  callback = function()
    local cmd = "playerctl position --format '{{ duration(position) }}'"
    awful.spawn.easy_async_with_shell(
      cmd,
      function(stdout)
        if stdout ~= nil then
          timeStatus.text = tostring(stdout)
        else
          timeStatus.text = tostring("00:00")
        end
        collectgarbage("collect")
      end
    )
  end
}
-- Update time once on startup
local updateTime =
  gears.timer {
  timeout = 1,
  autostart = true,
  single_shot = true,
  callback = function()
    local cmd = "playerctl position --format '{{ duration(position) }}'"
    awful.spawn.easy_async_with_shell(
      cmd,
      function(stdout)
        if stdout ~= nil then
          timeStatus.text = tostring(stdout)
        else
          timeStatus.text = tostring("00:00")
        end
        collectgarbage("collect")
      end
    )
  end
}

-- Update time duration on song change
local updateTimeDuration =
  gears.timer {
  timeout = 5,
  autostart = true,
  callback = function()
    local cmd = "playerctl position --format '{{ duration(mpris:length) }}'"
    awful.spawn.easy_async_with_shell(
      cmd,
      function(stdout)
        if stdout ~= nil then
          timeDuration.text = tostring(stdout)
        else
          timeDuration.text = tostring("00:00")
        end
        collectgarbage("collect")
      end
    )
  end
}

-- Update time once duration on startup
local updateTimeDuration =
  gears.timer {
  timeout = 1,
  autostart = true,
  single_shot = true,
  callback = function()
    local cmd = "playerctl position --format '{{ duration(mpris:length) }}'"
    awful.spawn.easy_async_with_shell(
      cmd,
      function(stdout)
        if stdout ~= nil then
          timeDuration.text = tostring(stdout)
        else
          timeDuration.text = tostring("00:00")
        end
        collectgarbage("collect")
      end
    )
  end
}

-- Get the progress percentage of music
local updateBar =
  gears.timer {
  timeout = 5,
  autostart = true,
  callback = function()
    -- TODO find the progress in the song
    local cmd = ""
    awful.spawn.easy_async_with_shell(
      cmd,
      function(stdout)
        if stdout ~= nil then
          progressbar.bar:set_value(tonumber(stdout))
        else
          progressbar.bar:set_value(0)
        end
      end
    )
  end
}

-- Get the progress percentage of music on startup
local updateBar =
  gears.timer {
  timeout = 1,
  single_shot = true,
  autostart = true,
  callback = function()
    -- TODO find the progress in the song
    local cmd = ""
    awful.spawn.easy_async_with_shell(
      cmd,
      function(stdout)
        if stdout ~= nil then
          progressbar.bar:set_value(tonumber(stdout))
        else
          progressbar.bar:set_value(0)
        end
      end
    )
  end
}

local musicBar =
  wibox.widget {
  wibox.container.margin(progressbar, dpi(15), dpi(15), dpi(10), dpi(0)),
  layout = wibox.layout.align.vertical,
  {
    layout = wibox.layout.align.horizontal,
    {
      wibox.container.margin(timeStatus, dpi(15), dpi(0), dpi(2)),
      layout = wibox.layout.fixed.horizontal
    },
    nil,
    {
      wibox.container.margin(timeDuration, dpi(0), dpi(15), dpi(2)),
      layout = wibox.layout.fixed.horizontal
    }
  }
}

return musicBar
