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
local profile = require("profiler.profile")
local delayed_timer = require("lib-tde.function.delayed-timer")
local filehandle = require("lib-tde.file")

local originalPrint = print
print = function(_)
end
-- start profiling
if os.getenv("REALTIME") == "1" then
    profile.setclock(require("socket").gettime)
end
profile.start()
require("tde.rc")

delayed_timer(
    1000,
    function()
        originalPrint("Stopping profiler")
        profile.stop()
        local res = profile.report(tonumber(os.getenv("FUNCTIONS_AMOUNT")) or 1000)
        if not (os.getenv("OUTPUT") == "") then
            filehandle.overwrite(os.getenv("OUTPUT"), res)
        end
        originalPrint(res)
    end,
    tonumber(os.getenv("TOTAL_TIME")),
    true
)
