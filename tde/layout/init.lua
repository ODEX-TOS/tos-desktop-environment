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
local bottom_panel = require("layout.bottom-panel")
local left_panel = require("layout.left-panel")
local right_panel = require("layout.right-panel")
local top_panel = require("layout.top-panel")

local signals = require("lib-tde.signals")

local hide = require("lib-widget.auto_hide")

local topBarDraw = general["top_bar_draw"] or "all"
local tagBarDraw = general["tag_bar_draw"] or "main"
local anchorTag = general["tag_bar_anchor"] or "bottom"

local function anchor(s)
  if anchorTag == "bottom" then
    -- Create the bottom bar
    s.bottom_panel = hide(bottom_panel(s))
  elseif anchorTag == "right" then
    s.bottom_panel = hide(right_panel(s))
  else
    s.bottom_panel = hide(left_panel(s, topBarDraw == "none"))
  end
end

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(
  function(s)
    if topBarDraw == "all" then
      -- Create the Top bar
      s.top_panel = hide(top_panel(s, false, false))
    elseif topBarDraw == "main" and s.index == 1 then
      -- Create the Top bar
      s.top_panel = hide(top_panel(s, false, false))
    else
      -- don't draw anything but render the left_panel
      s.top_panel = hide(top_panel(s, false, true))
    end

    if tagBarDraw == "all" then
      anchor(s)
    elseif tagBarDraw == "main" and s.index == 1 then
      anchor(s)
    end
  end
)

signals.connect_anchor_changed(function (new_anchor)
  if type(new_anchor) ~= "string" then
    return
  end
  general["tag_bar_anchor"] = new_anchor
  anchorTag = new_anchor

  for s in screen do
    -- disable the old widgets
    if s.bottom_panel ~= nil then
      s.bottom_panel.visible = false
      s.bottom_panel = nil
    end

    if tagBarDraw == "all" then
      anchor(s)
    elseif tagBarDraw == "main" and s.index == 1 then
      anchor(s)
    end

  end
end)

-- Hide bars when app go fullscreen
local function updateBarsVisibility()
  for s in screen do
    if s.selected_tag then
      local fullscreen = s.selected_tag.fullscreenMode
      -- Order matter here for shadow
      if s.top_panel then
        s.top_panel.visible = not fullscreen
      end
      if s.bottom_panel then
        s.bottom_panel.visible = not fullscreen
      end
    end
  end
end

_G.tag.connect_signal(
  "property::selected",
  function(_)
    updateBarsVisibility()
  end
)

_G.client.connect_signal(
  "property::fullscreen",
  function(c)
    if c.first_tag then
      c.first_tag.fullscreenMode = c.fullscreen
    end
    updateBarsVisibility()
  end
)

_G.client.connect_signal(
  "unmanage",
  function(c)
    if c.fullscreen then
      c.screen.selected_tag.fullscreenMode = false
      updateBarsVisibility()
    end
  end
)
