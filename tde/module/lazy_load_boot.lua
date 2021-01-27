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
-- menu takes a bit of time to load in.
-- because of this we put it in the back so the rest of the system can already behave
-- Look into awesome-freedesktop for more information

require("module.menu")

if not (general["disable_desktop"] == "1") then
    require("module.installer")
    require("module.desktop")
end

-- restore the last state
require("module.state")
require("tutorial")

require("module.dev-widget-update")

require("lib-tde.signals").connect_exit(
    function()
        -- stop current autorun.sh
        -- This is done because otherwise multiple instances would be running at the same time
        awful.spawn("pgrep -f /etc/xdg/tde/autorun.sh | xargs kill -9")
    end
)

local lockscreentime = general["screen_on_time"] or "120"
if general["screen_timeout"] == 1 or general["screen_timeout"] == nil then
    awful.spawn("/etc/xdg/tde/autorun.sh " .. lockscreentime)
else
    awful.spawn("/etc/xdg/tde/autorun.sh")
end

require("module.screen_changed")
