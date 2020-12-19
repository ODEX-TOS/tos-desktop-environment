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
local config = require("parser")(os.getenv("HOME") .. "/.config/tos/tags.conf")
local menubar = require("menubar")

local function icon(item)
  return menubar.utils.lookup_icon(item)
end

local function getItem(item)
  return config[item] or nil
end

local function getLayoutPerTag(number)
  local screen = "tag_" .. number
  local item = getItem(screen)
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
    return awful.layout.suit.spiral.dwindle
  end
end

local function getGapPerTag(number)
  local gap = "tag_gap_" .. number
  return tonumber(getItem(gap)) or 4
end

local tags = {
  {
    icon = icon("webbrowser-app") or icons.chrome,
    type = "chrome",
    defaultApp = "chrome",
    screen = 1,
    layout = getLayoutPerTag(1)
  },
  {
    icon = icon("utilities-terminal") or icons.terminal,
    type = "terminal",
    defaultApp = "st",
    screen = 1,
    layout = getLayoutPerTag(2)
  },
  {
    icon = icon("visual-studio-code-insiders") or icons.code,
    type = "code",
    defaultApp = "code-insiders",
    screen = 1,
    layout = getLayoutPerTag(3)
  },
  --
  --[[ {
    icon = icons.social,
    type = 'social',
    defaultApp = 'station',
    screen = 1
  },]] {
    icon = icon("system-file-manager") or icons.folder,
    type = "files",
    defaultApp = "thunar",
    screen = 1,
    layout = getLayoutPerTag(4)
  },
  {
    icon = icon("deepin-music") or icons.music,
    type = "music",
    defaultApp = "spotify",
    screen = 1,
    layout = getLayoutPerTag(5)
  },
  {
    icon = icon("applications-games") or icons.game,
    type = "game",
    defaultApp = "",
    screen = 1,
    layout = getLayoutPerTag(6)
  },
  {
    icon = icon("gimp") or icons.art,
    type = "art",
    defaultApp = "gimp",
    screen = 1,
    layout = getLayoutPerTag(7)
  },
  {
    icon = icon("utilities-system-monitor") or icons.lab,
    type = "any",
    defaultApp = "",
    screen = 1,
    layout = getLayoutPerTag(8)
  }
}
tag.connect_signal(
  "request::default_layouts",
  function()
    awful.layout.append_default_layouts(
      {
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
      awful.tag.add(
        i,
        {
          icon = tag.icon,
          icon_only = true,
          layout = tag.layout,
          master_width_factor = 0.8,
          master_count = 2,
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
    local currentLayout = awful.tag.getproperty(t, "layout")
    if (currentLayout == awful.layout.suit.max) then
      t.gap = 0
    else
      t.gap = awful.tag.getproperty(t, "gap") or 4
    end
    t.master_count = 2
  end
)
