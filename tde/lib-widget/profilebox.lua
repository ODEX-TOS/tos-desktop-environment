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
-- Create a new profilebox (rounded image)
--
-- Usually used to show profile images
--
--    -- Set the picture in the profilebox with a size of 100
--    local picture = lib-widget.profilebox("file.png", dpi(100), function(button)
--     print("Clicked with button: " .. button)
--    end)
--
--    picture.update("file2.png")
--
-- ![profilebox](../images/profilebox.png)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.profilebox
-- @supermodule wibox.widget.base
---------------------------------------------------------------------------

local wibox = require("wibox")
local rounded = require("lib-tde.widget.rounded")
local theme = require("theme.icons.dark-light")

--- Create a slider widget
-- @tparam string picture The picture to set in the profilebox
-- @tparam number diameter The diameter of the profilebox
-- @tparam function clicked_callback A callback that gets triggered every time you click on the box
-- @tparam[opt] function tooltip_callback A function that gets called each time a you want to show some information
-- @treturn widget The profilebox widget
-- @staticfct profilebox
-- @usage -- This will create the content in hallo.txt to var=value
-- local picture = lib-widget.profilebox("file.png", dpi(100), function(button)
--     print("Clicked with button: " .. button)
-- end)
return function(picture, diameter, clicked_callback, tooltip_callback)
    local widget =
        wibox.widget {
        widget = wibox.widget.imagebox,
        shape = rounded(diameter),
        clip_shape = rounded(diameter),
        resize = true,
        forced_width = diameter,
        forced_height = diameter
    }

    widget:set_image(theme(picture))
    widget:connect_signal(
        "button::press",
        function(_, _, _, button)
            clicked_callback(button)
        end
    )
    if tooltip_callback ~= nil and type(tooltip_callback) == "function" then
        awful.tooltip {
            objects = {widget},
            timer_function = tooltip_callback
        }
    end

    --- Update the image of the profilebox
    -- @tparam string file The path to the new profilebox
    -- @staticfct profilebox.update
    -- @usage -- This change the picture to image.png
    -- slider.update("/path/to/a/new/image.png")
    widget.update = function(file)
        widget:set_image(theme(file))
    end
    return widget
end
