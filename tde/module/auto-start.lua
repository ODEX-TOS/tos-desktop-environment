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
-- MODULE AUTO-START
-- Run all the apps listed in configuration/apps.lua as run_on_start_up only once when awesome start

local apps = require("configuration.apps")
local run_once = require("lib-tde.function.application_runner")
local delayed_timer = require("lib-tde.function.delayed-timer")

for _, app in ipairs(apps.run_on_start_up) do
  run_once(app)
end

-- TODO: remove this once the picom crash bug is fixed
if not (general["weak_hardware"] == "1") and (os.getenv("TDE_ENV") == "production" or os.getenv("TDE_ENV") == "staging") then
  delayed_timer(
    5,
    function()
      -- picom crashed, we have to restart it again
      if not awesome.composite_manager_running then
        awful.spawn(apps.run_on_start_up[1])
      end
      -- check the status of touchegg
      -- TODO: find a better solution for this
      awful.spawn([[sh -c 'test "$(pgrep touchegg | wc -l)" -lt 2 && touchegg']])
    end,
    5
  )
end
