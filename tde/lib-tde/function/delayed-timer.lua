local gears = require("gears")

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
