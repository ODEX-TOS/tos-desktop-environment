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
local dpi = require("beautiful").xresources.apply_dpi
local signals = require("lib-tde.signals")

local vol_osd = require("widget.brightness.brightness-slider-osd")

local brightnessOverlay

awful.screen.connect_for_each_screen(
  function(s)
    -- Create the box

    local offsetx = dpi(56)
    local offsety = dpi(300)
    brightnessOverlay =
      wibox(
      {
        visible = nil,
        ontop = true,
        type = "normal",
        height = offsety,
        width = dpi(48),
        bg = "#00000000",
        screen = s,
        x = s.geometry.x + s.geometry.width - offsetx,
        y = s.geometry.y + (s.geometry.height / dpi(2)) - (offsety / dpi(2))
      }
    )

    screen.connect_signal(
      "removed",
      function(removed)
        if s == removed then
          brightnessOverlay.visible = false
          brightnessOverlay.screen = awful.screen.focused()
        end
      end
    )

    signals.connect_refresh_screen(
      function()
        print("Refreshing brightness osd slider")

        if not s.valid or brightnessOverlay == nil then
          return
        end

        -- the action center itself
        brightnessOverlay.x = s.geometry.x + s.geometry.width - offsetx
        brightnessOverlay.y = s.geometry.y + (s.geometry.height / dpi(2)) - (offsety / dpi(2))
      end
    )
  end
)

-- TODO: make this code run per screen, then the toggle function should loop over all screens and toggle each slider

-- Put its items in a shaped container
brightnessOverlay:setup {
  -- Container
  {
    -- Items go here
    --wibox.widget.textbox("Hello!"),
    wibox.container.rotate(vol_osd, "east"),
    -- ...
    layout = wibox.layout.fixed.vertical
  },
  -- The real background color
  bg = "#000000" .. "66",
  -- The real, anti-aliased shape
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background()
}

local hideOSD =
  gears.timer {
  timeout = 5,
  autostart = true,
  single_shot = true,
  callback = function()
    if brightnessOverlay then
      brightnessOverlay.visible = false
    end
  end
}

local function toggleBriOSD(bool)
  if brightnessOverlay == nil then
    return
  end
  -- don't perform the toggle off if it is already off
  if ((not bool) and (not brightnessOverlay.visible)) then
    return
  end
  brightnessOverlay.visible = bool
  if bool then
    hideOSD:again()
    if _G.toggleVolOSD ~= nil then
      _G.toggleVolOSD(false)
    end
  else
    hideOSD:stop()
  end
end
if _G.toggleBriOSD == nil then
  _G.toggleBriOSD = toggleBriOSD
end

return brightnessOverlay
