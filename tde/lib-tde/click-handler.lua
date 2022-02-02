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
-- Override the mouse click pressed and release buttons to detect single click, double click short clicks and long clicks.
--
-- Useful you want to trigger multiple events based on how a user clicks
-- Such as in the settings app.
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.click-handler
---------------------------------------------------------------------------

local time = require("socket").gettime

--- Override the mouse click pressed and release buttons to detect single click, double click short clicks and long clicks.
-- @tparam[opt] function pressed_cb The callback to call when the mouse is pressed.
-- @tparam[opt] function release_cb The callback to call when the mouse is released.
-- @tparam[opt] function long_pressed_cb The callback to call when the mouse is long pressed (Longer than double_pressed_timeout).
-- @tparam[opt] function short_pressed_cb The callback to call when the mouse is short pressed (shorter than double_pressed_timeout).
-- @tparam[opt] function double_pressed_cb The callback to call when the mouse is clicked twice within double_pressed_timeout time.
-- @tparam[opt] number double_pressed_timeout The timeout in seconds to call the double_pressed_cb by default it is 0.5 seconds.
-- @treturn function,function The pressed and release functions to add to the mouse button events
-- @staticfct update_entry
-- @usage -- This will create the content in hallo.txt to var=value
-- lib-tde.click-handler(
-- pressed_cb = function() print("Pressed button") end,
-- double_pressed_cb = function() print("Double pressed button") end,
--)
return function(args)
    local _pressed_cb = args.pressed_cb or function() end
    local _released_cb = args.released_cb or function() end
    local _long_pressed_cb = args.long_pressed_cb or function() end
    local _short_pressed_cb = args.short_pressed_cb or function() end
    local _double_pressed_cb = args.double_pressed_cb or function() end
    local _double_pressed_timeout = args.double_pressed_timeout or 0.5

    local time_started = 0
    local double_press_time = 0
    local is_doing_double_press = false

    local function pressed_cb(x, y, button, modifiers)
        _pressed_cb(x, y, button, modifiers)

        if is_doing_double_press then
            is_doing_double_press = false
            double_press_time = time()
            local delta = double_press_time - time_started
            if delta < _double_pressed_timeout then
                _double_pressed_cb(x, y, button, modifiers)
            end
        end

        if is_doing_double_press == false then
            is_doing_double_press = true
        end

        time_started = time()
    end

    local function released_cb(x, y, button, modifiers)
        _released_cb(x, y, button, modifiers)

        if time() - time_started < _double_pressed_timeout then
            _short_pressed_cb(x, y, button, modifiers)
        else
            _long_pressed_cb(x, y, button, modifiers)
        end
    end

    return pressed_cb, released_cb
end