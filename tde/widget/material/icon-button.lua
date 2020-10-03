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
local gears = require("gears")
local clickable_container = require("widget.material.clickable-container")
local dpi = require("beautiful").xresources.apply_dpi

function build(imagebox, args)
  -- return wibox.container.margin(container, 6, 6, 6, 6)
  return wibox.widget {
    wibox.widget {
      wibox.widget {
        imagebox,
        top = dpi(6),
        left = dpi(6),
        right = dpi(6),
        bottom = dpi(6),
        widget = wibox.container.margin
      },
      shape = gears.shape.circle,
      widget = clickable_container
    },
    top = dpi(6),
    left = dpi(6),
    right = dpi(6),
    bottom = dpi(6),
    widget = wibox.container.margin
  }
end

return build
