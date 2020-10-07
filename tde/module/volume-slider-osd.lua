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

local vol_osd = require("widget.volume.volume-slider-osd")

awful.screen.connect_for_each_screen(
  function(s)
    -- Create the box

    local offsetx = dpi(56)
    local offsety = dpi(300)
    volumeOverlay =
      wibox(
      {
        visible = nil,
        ontop = true,
        type = "normal",
        height = offsety,
        width = dpi(48),
        bg = "#00000000",
        x = s.geometry.width - offsetx,
        y = (s.geometry.height / dpi(2)) - (offsety / dpi(2))
      }
    )
  end
)

-- Put its items in a shaped container
volumeOverlay:setup {
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
  callback = function()
    volumeOverlay.visible = false
  end
}

function toggleVolOSD(bool)
  if (not _G.menuopened) then
    -- don't perform the toggle off if it is already off
    if ((not bool) and (not volumeOverlay.visible)) then
      return
    end
    volumeOverlay.visible = bool
    if bool then
      hideOSD:again()
      if toggleBriOSD ~= nil then
        _G.toggleBriOSD(false)
      end
    else
      hideOSD:stop()
    end
  end
end

return volumeOverlay
