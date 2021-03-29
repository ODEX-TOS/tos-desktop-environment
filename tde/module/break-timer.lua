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
-- Load these libraries (if you haven't already)

local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local signals = require("lib-tde.signals")
local breakTimerFunctions = require("lib-tde.function.datetime")

_G.pause = {}
local breakTimer = require("widget.break-timer")

-- our timer is always running in the background until we stop it by pushing the disable button
local started = true
local breakOverlay
local breakbackdrop

awful.screen.connect_for_each_screen(
  function(s)
    breakOverlay =
      wibox(
      {
        visible = false,
        ontop = true,
        type = "normal",
        height = s.geometry.height,
        width = s.geometry.width,
        bg = beautiful.bg_modal,
        x = s.geometry.x,
        y = s.geometry.y
      }
    )

    screen.connect_signal(
      "removed",
      function(removed)
        if s == removed then
          breakOverlay.visible = false
          breakOverlay = nil
        end
      end
    )

    signals.connect_refresh_screen(
      function()
        print("Refreshing break timer screen")

        if not s.valid or breakOverlay == nil then
          return
        end

        -- the action center itself
        breakOverlay.x = s.geometry.x
        breakOverlay.y = s.geometry.y
        breakOverlay.width = s.geometry.width
        breakOverlay.height = s.geometry.height
      end
    )

    -- Put its items in a shaped container
    breakOverlay:setup {
      -- Container
      {
        breakTimer,
        layout = wibox.layout.fixed.vertical
      },
      -- The real background color
      bg = beautiful.background.hue_800,
      valign = "center",
      halign = "center",
      widget = wibox.container.place()
    }

    breakbackdrop =
      wibox {
      ontop = true,
      visible = false,
      screen = s,
      bg = "#000000aa",
      type = "dock",
      x = s.geometry.x,
      y = s.geometry.y,
      width = s.geometry.width,
      height = s.geometry.height - dpi(40)
    }
  end
)

_G.pause.stop = function()
  breakbackdrop.visible = false
  breakOverlay.visible = false
  _G.pause.stopSlider()
  print("Stopping break timer")
end

_G.pause.show = function(time)
  breakbackdrop.visible = true
  breakOverlay.visible = true
  _G.pause.start(time)
  gears.timer {
    timeout = time,
    single_shot = true,
    autostart = true,
    callback = function()
      -- stop the break after x seconds
      _G.pause.stop()
    end
  }
  print("Showing break timer")
end

-- this function returns tru if we should show the break timer.
-- The timer should not show up if we are in a fullscreen application (because we are focused, watching a movie or something else)
local function shouldShowTimer()
  local c = client.focus
  if c then
    if c.fullscreen or c.maximized then
      return false
    end
  end
  return true
end

local breakTriggerTimer =
  gears.timer {
  timeout = tonumber(general["break_timeout"]) or (60 * 60 * 1),
  autostart = true,
  callback = function()
    local time_start = general["break_time_start"] or "00:00"
    local time_end = general["break_time_end"] or "23:59"
    if breakTimerFunctions.current_time_inbetween(time_start, time_end) and shouldShowTimer() then
      _G.pause.show(tonumber(general["break_time"]) or (60 * 5))
    else
      print("Break triggered but outside of time contraints")
    end
  end
}

-- Disable the global timer
-- Thus no more breaks will be triggered
_G.pause.disable = function()
  print("Disabeling break timer")
  -- only stop the timer if it is still running
  if started then
    breakTriggerTimer:stop()
    started = false
  end
end

return breakOverlay
