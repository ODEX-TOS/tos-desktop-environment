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
--- Maximized and fullscreen layouts module for awful
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @module awful.layout
---------------------------------------------------------------------------

-- Grab environment we need
local pairs = pairs

local max = {}

--- The max layout layoutbox icon.
-- @beautiful beautiful.layout_max
-- @param surface
-- @see gears.surface

--- The fullscreen layout layoutbox icon.
-- @beautiful beautiful.layout_fullscreen
-- @param surface
-- @see gears.surface

local function fmax(p, fs)
    -- Fullscreen?
    local area
    if fs then
        area = p.geometry
    else
        area = p.workarea
    end
    local focused_client = client.focus
    for _, c in pairs(p.clients) do
        local g = {
            x = area.x,
            y = area.y,
            width = area.width,
            height = area.height
        }
        p.geometries[c] = g
    end
end

--- Maximized layout.
-- @clientlayout awful.layout.suit.max.name
max.name = "max"
function max.arrange(p)
    return fmax(p, false)
end
function max.skip_gap(nclients, t) -- luacheck: no unused args
    return true
end

return max

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
