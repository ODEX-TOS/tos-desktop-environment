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
-- Create a new slider widget
--
-- Useful when you to get the user to input a range of numbers
--
--    -- A slider between 0 and 10 with increments of 0.05, the default value is 5 and a callback function each time the value is updated
--    local slider = lib-widget.slider(0, 10, 0.05, 5, function(value)
--         print("Updated slider value to: " .. value)
--    end)
--
--   slider:set_value(8)
--
-- ![slider](../images/slider.png)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.slider
-- @supermodule wibox.widget.slider
---------------------------------------------------------------------------

local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local signals = require("lib-tde.signals")
local dpi = beautiful.xresources.apply_dpi

local theme = beautiful.primary
local background_theme = beautiful.background

--- Create a slider widget
-- @tparam number min The lowest possible value for the slider
-- @tparam number max The highest possible value for the slider
-- @tparam number increment How much should one step increase the slider
-- @tparam number default_value To what value do we need to set the slider to initially
-- @tparam function callback A callback that gets triggered every time the value change_focus
-- @tparam[opt] function tooltip_callback A function that gets called each time a you want to show some information
-- @treturn widget The slider widget
-- @staticfct slider
-- @usage -- This will create the content in hallo.txt to var=value
-- -- A slider between 0 and 10 with increments of 0.05, the default value is 5 and a callback function each time the value is updated
-- local slider = lib-widget.slider(0, 10, 0.05, 5, function(value)
--      print("Updated slider value to: " .. value)
-- end)
return function(min, max, increment, default_value, callback, tooltip_callback)
    local step_size = 1 / increment

    local widget = wibox.widget.slider()
    widget.bar_shape = function(c, w, h)
        gears.shape.rounded_rect(c, w, h, dpi(30) / 2)
    end
    widget.bar_height = dpi(30)
    widget.bar_color = background_theme.hue_700 .. beautiful.background_transparency
    widget.bar_active_color = theme.hue_500
    widget.handle_shape = gears.shape.circle
    widget.handle_width = dpi(35)
    widget.handle_color = theme.hue_500
    widget.handle_border_width = 1
    widget.handle_border_color = "#00000012"
    widget.minimum = min * step_size
    widget.maximum = max * step_size

    -- set the initial value
    widget:set_value(default_value * step_size)

    widget:connect_signal(
        "property::value",
        function()
            local value = widget.value / step_size
            callback(value)
        end
    )

    --- Update the value of the slider
    -- @tparam number value The new numerical value of the slider
    -- @staticfct slider.update
    -- @usage -- This will set the value of the slider to 8.5
    -- slider.update(8.5)
    widget.update = function(value)
        widget:set_value(value * step_size)
    end

    if tooltip_callback ~= nil and type(tooltip_callback) == "function" then
        awful.tooltip {
            objects = {widget},
            timer_function = tooltip_callback
        }
    end

    signals.connect_primary_theme_changed(
        function(new_theme)
            theme = new_theme
            widget.bar_active_color = new_theme.hue_500
            widget.handle_color = new_theme.hue_500
        end
    )

    signals.connect_background_theme_changed(
        function(new_theme)
            background_theme = new_theme
            widget.bar_color = new_theme.hue_700 .. beautiful.background_transparency
        end
    )

    return widget
end
