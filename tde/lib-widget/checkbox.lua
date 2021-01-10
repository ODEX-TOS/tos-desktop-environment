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
-- Create a new checkbox widget
--
-- Usefull when you want to seperate widgets from eachother
--
--    -- checkbox that is 20 pixels high
--    local checkbox = lib-widget.checkbox(dpi(20))
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.checkbox
---------------------------------------------------------------------------
-- TODO: implement this files
-- TODO: refactor codebase to use this (settings app + left panel)

local wibox = require("wibox")

--- Create a new checkbox widget
-- @tparam number size The height of the checkbox
-- @treturn widget The checkbox widget
-- @staticfct checkbox
-- @usage -- This will create a checkbox that is 20 pixels high
-- -- checkbox that is 20 pixels high
-- local checkbox = lib-widget.checkbox(dpi(20))
return function(height)
    return wibox.widget {
        widget = wibox.widget.separator,
        forced_height = height
    }
end