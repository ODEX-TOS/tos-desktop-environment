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
local capi = {client = client}
local awful = require("awful")

local module = {}

local invert = {
  left = "right",
  right = "left",
  up = "down",
  down = "up"
}

local r_ajust = {
  left = function(c, d)
    return {x = c.x, width = c.width - d}
  end,
  right = function(c, d)
    return {width = c.width + d}
  end,
  up = function(c, d)
    return {y = c.y, height = c.height - d}
  end,
  down = function(c, d)
    return {height = c.height + d}
  end
}

function module.hide()
end

function module.display(_, _)
end

function module.resize(_, _, _, direction, is_swap, _)
  local c = capi.client.focus
  if not c then
    return true
  end

  local del = is_swap and -100 or 100
  direction = is_swap and invert[direction] or direction

  c:emit_signal("request::geometry", "mouse.resize", r_ajust[direction](c, del))

  return true
end

-- Always display the arrows when resizing
awful.mouse.resize.add_enter_callback(module.display, "mouse.resize")
awful.mouse.resize.add_leave_callback(module.hide, "mouse.resize")

return module
-- kate: space-indent on; indent-width 4; replace-tabs on;
