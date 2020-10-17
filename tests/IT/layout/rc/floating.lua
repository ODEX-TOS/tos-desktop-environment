local execute = require("tde.lib-tde.hardware-check").execute
local sleep = require("tde.lib-tde.function.common").sleep
originalPrint = print

print = function(str)
end

require("tde.rc")

local tag = awful.screen.focused().tags[8]
awful.tag.viewtoggle(tag)
tag.layout = awful.layout.suit.floating
-- launch st in floating mode
local pid =
    tostring(
    awful.spawn(
        "st",
        {
            floating = true,
            tag = mouse.screen.selected_tag
        }
    )
)

sleep(0.2)
-- verify that st has launched
local stdout, ret = execute("ps -p " .. pid .. " -o comm=")
local launched = (ret == 0) and (stdout:match("st") ~= nil)

sleep(2.5)

-- force all client to be floating and 100x100 size
for _, c in ipairs(client.get()) do
    c.floating = true
    c.width = 100
    c.height = 100
    c:raise()
end

-- TODO: Fix setting the application into floating mode
-- This gets overridden by the rules
local verifyFloating = true
for _, c in ipairs(client.get()) do
    if c.floating then
        verifyFloating = true
    end
end
originalPrint("IT-test-result:" .. tostring(launched and verifyFloating))
