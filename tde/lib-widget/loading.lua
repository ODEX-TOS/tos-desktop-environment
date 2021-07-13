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
-- Create a loading widget
--
-- ![loading](../images/loading.png)
--
-- Useful to be displayed when another widget is still loading in
--
--    local loader = lib-widget.loading()
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.loading
-- @supermodule wibox.widget
---------------------------------------------------------------------------

local wibox = require("wibox")
local gears = require("gears")

local animate = require("lib-tde.animations").createAnimObject

local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local function animate_object(widget, animation_speed, height, callback)
    animation_speed = animation_speed / 2
    widget.top = height
    animate(
        animation_speed,
        widget,
        {top = -height},
        "inQuad",
        function ()
            animate(
                animation_speed,
                widget,
                {top = height},
                "inQuad",
                function ()
                    callback()
                end
            )
        end
    )
end

local function generate_loader_dot(offset, animation_speed, size)
    local widget = wibox.container.margin(wibox.widget {
        wibox.widget.base.empty_widget(),
        widget = wibox.container.background,
        shape = gears.shape.circle,
        bg = beautiful.primary.hue_600,
        forced_width = size,
        forced_height = size,
    }, 0,0,size,0)

    local should_animate = true

    local function callback_function()
        if not should_animate then
            return
        end
        -- start the animation
        animate_object(widget, animation_speed, size , function()
            if not should_animate then
                return
            end

            callback_function()
        end)
    end

    widget.start = function()
        should_animate = true
        gears.timer {
            timeout = offset,
            single_shot = true,
            autostart = true,
            callback = callback_function
        }
    end

    widget.stop = function()
        -- force stop the animation loop
        should_animate = false
    end

    widget.start()

    return widget
end

--- Create a new loader widget
-- @tparam[opt] number dots the amount of dots to animate
-- @treturn widget The loading widget
-- @staticfct loading
-- @usage -- This will create a loading widget
-- local loader = lib-widget.loading()
return function(dots)
    local animation_speed = 2
    dots = dots or 3
    local margin = dpi(5)
    local width = dpi(10)

    local _dots = {}

    for i = 1, dots, 1 do
        table.insert(_dots, generate_loader_dot(i / dots, animation_speed, width))
    end

    local widget = wibox.widget{
        layout = wibox.layout.fixed.horizontal,
        spacing = margin,
        forced_width = width * #_dots + margin * (#_dots - 1)
    }

    for _, dot in ipairs(_dots) do
        widget:add(dot)
    end

    --- Start the loading animation
    -- @staticfct loading.start
    -- @usage -- Start the animation
    -- loading.start()
    widget.start = function()
        for _, animator in ipairs(_dots) do
            animator.start()
        end
    end

    --- Stop the loading animation from playing
    -- @staticfct loading.stop
    -- @usage -- Stop the animation
    -- loading.stop()
    widget.stop = function()
        for _, animator in ipairs(_dots) do
            animator.stop()
        end
    end

    return widget
end
