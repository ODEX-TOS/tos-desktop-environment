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
-- A togglable checkbox
--
--    -- checkbox that is 20 pixels high
--    local checkbox = lib-widget.checkbox(dpi(20))
--
-- ![checkbox](../images/checkbox.png)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.checkbox
-- @supermodule wibox.widget.checkbox
---------------------------------------------------------------------------
-- TODO: implement this files
-- TODO: refactor codebase to use this (settings app + left panel)

local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local signals = require("lib-tde.signals")
local dpi = beautiful.xresources.apply_dpi

local theme = beautiful.primary

--- Create a new checkbox widget
-- @tparam number size The height of the checkbox
-- @treturn widget The checkbox widget
-- @staticfct checkbox
-- @usage -- This will create a checkbox that is 20 pixels high
-- -- checkbox that is 20 pixels high
-- local checkbox = lib-widget.checkbox(dpi(20))
return function(checked, callback, size)
    local checkbox =
        wibox.widget {
        checked = checked,
        color = theme.hue_700,
        paddings = dpi(2),
        check_border_color = theme.hue_600,
        check_color = theme.hue_600,
        check_border_width = dpi(2),
        shape = gears.shape.circle,
        forced_height = size or dpi(20),
        widget = wibox.widget.checkbox
    }

    signals.connect_primary_theme_changed(
        function(new_theme)
            theme = new_theme
            checkbox.check_border_color = theme.hue_600
            checkbox.check_color = theme.hue_600
            checkbox.color = theme.hue_700
        end
    )

    checkbox:connect_signal(
        "button::press",
        function(_, _, _, button)
            if not (button == 1) then
                return
            end
            print("Pressed checkbox")
            checkbox.checked = not checkbox.checked
            callback(checkbox.checked or false)
        end
    )
    checkbox:connect_signal(
        "mouse::enter",
        function()
            if checkbox.checked then
                checkbox.check_color = theme.hue_700
            end
        end
    )
    checkbox:connect_signal(
        "mouse::leave",
        function()
            if checkbox.checked then
                checkbox.check_color = theme.hue_600
            end
        end
    )

    --- Update the checked state of the checkbox
    -- @staticfct update
    -- @usage -- Set the checkbox to 'true'
    -- checkbox.update(true)
    checkbox.update = function(new_checked)
        checkbox.checked = new_checked
    end

    return checkbox
end
