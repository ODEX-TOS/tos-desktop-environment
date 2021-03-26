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
-- This module run a timer periodically, but has an initial delay before running.
--
-- Usually people use `gears.timer` however when starting the desktop environment every timer gets triggered at the same time.
-- This can result in peaks of cpu usage followed by times with no cpu usage.
-- This is fine for small programs, but if a program uses considerable cpu time this can cause "lag".
-- Delayed timer is used to "spread" the execution of async repeating code (for example polling).
-- This is how you use the api:
--
--    -- this will print hello every 5 seconds, after an initial delay of 10 seconds
--    -- It however by default calls the callback function on startup once
--    lib-tde.function.delayed-timer(5, function()
--        print("hello")
--    end, 10)
--
--    -- If you want to do the same as above but without the call when creating the time
--    lib-tde.function.delayed-timer(5, function()
--        print("hello")
--    end, 10, true)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.delayed-timer
---------------------------------------------------------------------------

local gears = require("gears")

--- Async callback trigger, that starts after x seconds
-- @tparam number timeout How long to wait until we call the callback again
-- @tparam function callback The callback function to call when the timeout happened
-- @tparam number delay How long to wait until we start the async timer
-- @tparam[opt] bool only_delay By default we call the callback on creation, when true we don't call the callback
-- @staticfct delayed-timer
-- @usage -- lib-tde.function.delayed-timer(1, function()
--      print("Callback")
-- end, 10, true)
return function(timeout, callback, delay, only_delay)
    local timer =
        gears.timer {
        timeout = timeout,
        call_now = true,
        callback = callback
    }

    gears.timer {
        timeout = delay,
        autostart = true,
        single_shot = true,
        callback = function()
            timer:start()
        end
    }

    -- run the callback when starting up
    -- this insures generated data
    if not only_delay then
        callback()
    end

    return timer
end
