local naughty = require("naughty")
local sleep = require("tde.lib-tde.function.common").sleep

originalPrint = print

print = function(str)
end

require("tde.rc")

sleep(1)

require("gears").timer.start_new(
    1,
    function()
        local title = "Integration Test"
        local message = "This integration test is used to validate notifications"
        naughty.notify({title = title, message = message, timeout = 0}):connect_signal(
            "destroyed",
            function()
                originalPrint("IT-test-result:true")
            end
        )
    end
)
