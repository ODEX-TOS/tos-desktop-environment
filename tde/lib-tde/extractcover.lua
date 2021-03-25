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
---------------------------------------------------------------------------
-- Extract album cover from song
--
-- This is a helper module to extract metadata from music.
-- It depends on the external package playerctl.
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.extractcover
---------------------------------------------------------------------------

-- Extract album cover from song
-- Will used by music/mpd widget
-- Depends ffmpeg or perl-image-exiftool, song with hard-coded album cover

local extract = {}
-- TODO: get image information from spotify

--- Creates a file in /tmp/cover.jpg asynchronously containing the cover image of the current song
-- @staticfct extractalbum
-- @usage -- This will return {1: "abc", 2: "def"}
-- lib-tde.extract_cover.extractalbum() -> returns nothing
local extract_cover = function()
  -- see https://github.com/altdesktop/playerctl/issues/172 for more info
  local extract_script =
    [[
    url=$(playerctl -p spotify metadata mpris:artUrl | sed "s/open\.spotify\.com/i.scdn.co/")
    if [ "$url" ]; then
      curl -fL "$url" -o /tmp/cover.jpg
    fi
  ]]

  awful.spawn.easy_async_with_shell(
    extract_script,
    function(stderr)
      print("Music image: " .. stderr)
    end,
    false
  )
end

extract.extractalbum = extract_cover

return extract
