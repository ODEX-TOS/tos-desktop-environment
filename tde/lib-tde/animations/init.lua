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
local gears = require("gears")
local hardware = require("lib-tde.hardware-check")
local tween = require("lib-tde.animations.tween")

local freq = 1 / hardware.getDisplayFrequency()

local function createAnimObject(duration, subject, target, easing, end_callback, delay, widget, tween_callback)
    assert(type(duration) == "number", "The duration should be specified in seconds")
    assert(duration >= 0, "your duration can't be lower than 0 seconds")

    widget = widget and widget or subject
    -- check if animation is running
    if widget.anim then
        widget:emit_signal("interrupt", widget)
    end
    -- create timer at display freq
    widget.timer = gears.timer({timeout = freq})
    -- create self-destructing animation-stop callback function
    cback = function(callback_widget)
        if callback_widget.timer and callback_widget.timer.started then
            callback_widget.timer:stop()
        end
        callback_widget:disconnect_signal("interrupt", cback)
    end
    -- create tween
    local twob = tween.new(duration, subject, target, easing)
    -- create timeout signal
    widget.timer:connect_signal(
        "timeout",
        function()
            local complete = twob:update(freq)
            if tween_callback == nil then
                widget:emit_signal("widget::redraw_needed")
            else
                tween_callback()
            end
            if complete then
                widget.timer:stop()
                cback(widget)
                widget.anim = false
                if end_callback then
                    end_callback()
                end
            end
        end
    )
    -- start animation
    widget:connect_signal("interrupt", cback)
    widget.anim = true
    if delay ~= nil then
        gears.timer {
            autostart = true,
            single_shot = true,
            timeout = delay,
            callback = function()
                widget.timer:start()
            end
        }
    else
        widget.timer:start()
    end
end

return {
    createAnimObject = createAnimObject
}
