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
local background = require("theme.config")["background"]
local file_exists = require("lib-tde.file").exists
local split = require("lib-tde.function.common").split

-- suffix the icon name with dark if light theme is enabled (icons have an inverted color compared with the background)
-- light theme is enabled if the background property is set to light in colors.conf
-- This function then checks to see if the new file exists otherwise we default to the normal icon
return function(icon, backgrnd)
  if backgrnd == nil then
    -- just return the normal icons if the default background is selected
    if not (background == "light") then
      return icon
    end
  else
    if not (backgrnd == "light") then
      return icon
    end
  end
  -- otherwise check the dark variant of the svg files
  local splitted = split(icon, ".")

  if splitted[1] == nil or splitted[2] == nil then
    return icon
  end
  local light = splitted[1] .. ".dark." .. splitted[2]
  if file_exists(light) then
    return light
  end
  return icon
end
