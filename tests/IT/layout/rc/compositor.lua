local awful = require("awful")
local execute = require("tde.lib-tde.hardware-check").execute

originalPrint = print

print = function(str)
end

require("tde.rc")

local picom = require("tde.configuration.apps").run_on_start_up[1]

awful.spawn(picom)

-- give picom time to start
local _, ret = execute("sleep 1; pgrep picom")
local running = ret == 0
originalPrint("Compositor is running? " .. tostring(running))

originalPrint("IT-test-result:" .. tostring(running))
