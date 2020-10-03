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

local right_panel = require("widget.notification-center.right-panel")

-- Create a wibox for each screen connected
awful.screen.connect_for_each_screen(
  function(s)
    if s.index == 1 then
      -- Create the right_panel
      s.right_panel = right_panel(s)
    end
  end
)

-- Hide panel when clients go fullscreen
showAgain = false
function updateRightBarsVisibility()
  for s in screen do
    if s.selected_tag then
      local fullscreen = s.selected_tag.fullscreenMode
      if s.right_panel then
        if fullscreen and s.right_panel.visible then
          _G.screen.primary.right_panel:toggle()
          showAgain = true
        elseif not fullscreen and not s.right_panel.visible and showAgain then
          _G.screen.primary.right_panel:toggle()
          showAgain = false
        end
      end
    end
  end
end

_G.tag.connect_signal(
  "property::selected",
  function(t)
    updateRightBarsVisibility()
  end
)

_G.client.connect_signal(
  "property::fullscreen",
  function(c)
    if c.first_tag then
      c.first_tag.fullscreenMode = c.fullscreen
    end
    updateRightBarsVisibility()
  end
)

_G.client.connect_signal(
  "unmanage",
  function(c)
    if c.fullscreen then
      c.screen.selected_tag.fullscreenMode = false
      updateRightBarsVisibility()
    end
  end
)
