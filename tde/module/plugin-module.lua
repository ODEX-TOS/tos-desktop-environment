-- This module loads in backend plugins found under .config/tde/*/.init.lua

-- we don't need to do anything since the plugin loader automatically requires said plugins
local gears = require("gears")

gears.timer {
    autostart = true,
    timeout = 5,
    single_shot = true,
    callback = function()
        require("lib-tde.plugin-loader")("module")
    end
}
