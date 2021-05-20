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
-- functions to help with rounding widgets.
--
-- This package contains simple function to round your widgets.
--
--     wibox.widget {
--        text = "hello",
--        shape = lib-tde.widget.rounded(),
--        widget = wibox.widget.textbox,
--     }
--
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.widget.rounded
-- @supermodule gears.object
---------------------------------------------------------------------------

local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

--- Round the corners of a wibox, as a cairo surface shape
-- @tparam[opt] number size the size in pixels (best to wrap around a dpi call)
-- @staticfct rounded
-- @usage -- rounds the corners by 10 (based on the user dpi)
-- lib-tde.widgets.rounded(dpi(10))
return function(size)
  if size == nil then
    size = dpi(10)
  end
  return function(c, w, h)
    gears.shape.rounded_rect(c, w, h, size)
  end
end
