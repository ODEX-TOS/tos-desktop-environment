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

local dpi = require("beautiful").xresources.apply_dpi

-- Music Title
local musicTitle =
  wibox.widget {
  {
    id = "title",
    font = "SFNS Display Bold 12",
    align = "center",
    valign = "bottom",
    ellipsize = "end",
    widget = wibox.widget.textbox
  },
  layout = wibox.layout.flex.horizontal
}
function getTitle()
  awful.spawn.easy_async_with_shell(
    "playerctl metadata xesam:title",
    function(stdout)
      if (stdout:match("%W")) then
        musicTitle.title:set_text(stdout)
        print("Music title: " .. stdout)
      else
        musicTitle.title:set_text("No active music player found.")
        print("No music found")
      end
    end
  )
end

-- Music Artist
local musicArtist =
  wibox.widget {
  {
    id = "artist",
    font = "SFNS Display 9",
    align = "center",
    valign = "top",
    widget = wibox.widget.textbox
  },
  layout = wibox.layout.flex.horizontal
}
function getArtist()
  awful.spawn.easy_async_with_shell(
    "playerctl metadata xesam:artist",
    function(stdout)
      if (stdout:match("%W")) then
        musicArtist.artist:set_text(stdout)
        print("Music artist: " .. stdout)
      else
        musicArtist.artist:set_text("Try and play some music :)")
      end
    end
  )
end

local musicInfo =
  wibox.widget {
  wibox.container.margin(musicTitle, dpi(15), dpi(15)),
  wibox.container.margin(musicArtist, dpi(15), dpi(15)),
  layout = wibox.layout.flex.vertical
}

return musicInfo
