local execute = require("tde.lib-tde.hardware-check").execute
local sleep = require("tde.lib-tde.function.common").sleep
originalPrint = print
-- how long to wait until rofi has launched in seconds
local rofiLaunchWaitTime = 0.5

print = function(str)
end

require("tde.rc")

local hasLeftPanel = false
local panel = nil
for s in screen do
    if not (s.left_panel == nil) then
        hasLeftPanel = true
        panel = s.left_panel
    end
end

assert(panel)
originalPrint("Action menu / control center exists")

-- check if we opened the panel
panel:toggle()
local opened = panel.visible

originalPrint("Current action center is opened?" .. tostring(opened))

panel:toggle()
-- check if we closed the panel
local closed = not panel.visible

originalPrint("Current action center is closed?" .. tostring(closed))

-- check if rofi spawned
panel:toggle()
-- this should launch rofi
panel:run_rofi()
sleep(rofiLaunchWaitTime)
local _, ret = execute("kill $(pgrep rofi)")
local rofiSpawned = ret == 0

originalPrint("Rofi web is working?" .. tostring(rofiSpawned))

-- this should launch dpi rofi
panel:run_dpi()
sleep(rofiLaunchWaitTime)
local _, ret = execute("kill $(pgrep rofi)")
local rofiSpawned = rofiSpawned and ret == 0
originalPrint("Rofi dpi is working?" .. tostring(rofiSpawned))

-- this should launch wifi rofi
panel:run_wifi()
sleep(rofiLaunchWaitTime)
local _, ret = execute("kill $(pgrep rofi)")
local rofiSpawned = rofiSpawned and ret == 0
originalPrint("Rofi wifi is working?" .. tostring(rofiSpawned))

originalPrint("IT-test-result:" .. tostring(hasLeftPanel and opened and rofiSpawned and closed))

-- we have our results - speed up the tests
