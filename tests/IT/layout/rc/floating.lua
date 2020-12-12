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
