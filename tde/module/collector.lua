local delayed_timer = require("lib-tde.function.delayed-timer")
local config = require("config")

delayed_timer(
    config.garbage_collection_cycle,
    function()
        collectgarbage("collect")
    end,
    config.garbage_collection_cycle
)
