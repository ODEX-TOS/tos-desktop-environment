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
-- Create a new scrollbox widget
--
-- Useful when you want the internal widget to scroll
--
--    -- make a widget scrollable
--    local scrollbox = lib-widget.scrollbox(lib-widget.imagebox("file.png"))
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.scrollbox
-- @supermodule wibox.container.margin
---------------------------------------------------------------------------

local wibox = require("wibox")

--- Create a new scrollable widget
-- @tparam widget scrollable The widget that we make scrollable
-- @treturn widget The scrollbox widget
-- @staticfct separator
-- @usage -- This will create a scrollbox out of the internal widget
-- -- make a widget scrollable
-- local scrollbox = lib-widget.scrollbox(lib-widget.imagebox("file.png"))
return function(scrollable)
    local offset = 0
    local max_scroll = 90000 -- if no max scrolling is present we set it to the max

    local widget
    local size = 20

    for s in screen do
        if ((s.geometry.height / 50) > size) then
            size = (s.geometry.height / 50)
        end
    end

    widget = wibox.container.margin(scrollable)

    --- Reset the scrollbox to its initial state
    -- @staticfct reset
    -- @usage -- This will reset the scroll state
    -- -- reset the scrollbox as it was initially
    -- scrollbox.reset()
    widget.reset = function()
        -- reset the internal state
        offset = 0

        -- move the widget back to its original position
        widget.top = 0
    end

    widget:buttons(
        awful.util.table.join(
            awful.button(
                {},
                4,
                function(_)
                    if ((offset + size) > 0) then
                        offset = 0
                    else
                        offset = offset + size
                    end
                    widget.top = offset
                end
            ),
            awful.button(
                {},
                5,
                function(_)
                    if (offset - 20 < -max_scroll) then
                        offset = -max_scroll
                    else
                        offset = offset - size
                    end
                    widget.top = offset
                end
            )
        )
    )
    return widget
end
