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
local awful = require('awful')
local naughty = require('naughty')

local find_widget_in_wibox = function(wb, widget)
    local function find_widget_in_hierarchy(h, _widget)
        if h:get_widget() == _widget then return h end
        local result

        for _, ch in ipairs(h:get_children()) do
            result = result or find_widget_in_hierarchy(ch, _widget)
        end
        return result
    end
    local h = wb._drawable._widget_hierarchy
    return h and find_widget_in_hierarchy(h, widget)
end

local focused = awful.screen.focused()
local h = find_widget_in_wibox(focused.top_panel, focused.music)
local _, _, _, height = h:get_matrix_to_device():transform_rectangle(0, 0,
                                                                         h:get_size())

naughty.notification({message = tostring(height)})
