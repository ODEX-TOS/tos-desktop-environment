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
local icons = require("theme.icons")
local menubar = require("menubar")

local function icon(item)
  return menubar.utils.lookup_icon(item)
end

local function getLayoutPerTag(number)
  local item = _G.save_state.tags[number].layout
  if item ~= nil then
    if item == "0" or item == "dwindle" then
      return awful.layout.suit.spiral.dwindle
    end
    if item == "1" or item == "floating" then
      return awful.layout.suit.floating
    end
    if item == "2" or item == "tile" then
      return awful.layout.suit.tile
    end
    if item == "3" or item == "fair" then
      return awful.layout.suit.fair
    end
    if item == "4" or item == "magnifier" then
      return awful.layout.suit.magnifier
    end
    if item == "5" or item == "max" then
      return awful.layout.suit.max
    end
    if item == "6" or item == "fairh" then
      return awful.layout.suit.fair.horizontal
    end
  else
    return awful.layout.suit.tile
  end
end

local function getGapPerTag(number)
  local gap = _G.save_state.tags[number].gap
  return gap or 4
end

local function getMasterCountPerTag(number)
  local master = _G.save_state.tags[number].master_count
  return master or 1
end

local function getMasterWidthPerTag(number)
  local master = _G.save_state.tags[number].master_width_factor
  local width_factor = master or 0.5

  -- clamp the number between 0 and 1
  -- 0 in this context means that the master consumes 0 pixels
  -- 1 means that the master consumes the entire screen
  if width_factor < 0 then
    width_factor = 0
  elseif width_factor > 1 then
    width_factor = 1
  end

  return width_factor
end

local tags = {
  {
    icon = icon("webbrowser-app") or icons.chrome,
    type = "chrome",
    defaultApp = "chrome",
    screen = 1,
    layout = getLayoutPerTag(1),
    master_count = getMasterCountPerTag(1),
    master_width_factor =  getMasterWidthPerTag(1)
  },
  {
    icon = icon("utilities-terminal") or icons.terminal,
    type = "terminal",
    defaultApp = "st",
    screen = 1,
    layout = getLayoutPerTag(2),
    master_count = getMasterCountPerTag(2),
    master_width_factor =  getMasterWidthPerTag(2)
  },
  {
    icon = icon("visual-studio-code-insiders") or icons.code,
    type = "code",
    defaultApp = "code-insiders",
    screen = 1,
    layout = getLayoutPerTag(3),
    master_count = getMasterCountPerTag(3),
    master_width_factor =  getMasterWidthPerTag(3)
  },
  {
    icon = icon("system-file-manager") or icons.folder,
    type = "files",
    defaultApp = "thunar",
    screen = 1,
    layout = getLayoutPerTag(4),
    master_count = getMasterCountPerTag(4),
    master_width_factor =  getMasterWidthPerTag(4)
  },
  {
    icon = icon("deepin-music") or icons.music,
    type = "music",
    defaultApp = "spotify",
    screen = 1,
    layout = getLayoutPerTag(5),
    master_count = getMasterCountPerTag(5),
    master_width_factor =  getMasterWidthPerTag(5)
  },
  {
    icon = icon("applications-games") or icons.game,
    type = "game",
    defaultApp = "",
    screen = 1,
    layout = getLayoutPerTag(6),
    master_count = getMasterCountPerTag(6),
    master_width_factor =  getMasterWidthPerTag(6)
  },
  {
    icon = icon("gimp") or icons.art,
    type = "art",
    defaultApp = "gimp",
    screen = 1,
    layout = getLayoutPerTag(7),
    master_count = getMasterCountPerTag(7),
    master_width_factor =  getMasterWidthPerTag(7)
  },
  {
    icon = icon("utilities-system-monitor") or icons.lab,
    type = "any",
    defaultApp = "",
    screen = 1,
    layout = getLayoutPerTag(8),
    master_count = getMasterCountPerTag(8),
    master_width_factor = getMasterWidthPerTag(8)
  }
}
tag.connect_signal(
  "request::default_layouts",
  function()
    awful.layout.append_default_layouts(
      {
        awful.layout.suit.tile,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.floating,
        awful.layout.suit.fair,
        awful.layout.suit.magnifier,
        awful.layout.suit.max,
        awful.layout.suit.fair.horizontal
      }
    )
  end
)

awful.screen.connect_for_each_screen(
  function(s)
    for i, tag in pairs(tags) do
      -- the last tag is reserved for the desktop
      tag.layout = getLayoutPerTag(i)
      tag.gap = getGapPerTag(i)
      tag.master_count = getMasterCountPerTag(i)
      tag.master_width_factor = getMasterWidthPerTag(i)

      awful.tag.add(
        i,
        {
          icon = tag.icon,
          icon_only = true,
          layout = tag.layout,
          master_width_factor = tag.master_width_factor,
          master_count = tag.master_count,
          gap_single_client = false,
          gap = tag.gap,
          screen = s,
          defaultApp = tag.defaultApp,
          selected = i == 1
        }
      )
    end
  end
)

_G.tag.connect_signal(
  "property::layout",
  function(t)
    t.gap = t.gap or 4
    t.master_count = getMasterCountPerTag(t.index)
    t.master_width_factor = getMasterWidthPerTag(t.index)
  end
)
