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

local awful = require("awful")
local apps = require("configuration.apps")

local function run_once(cmd)
  local findme = cmd
  local firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace - 1)
  end
  print("Executing: " .. " " .. cmd)
  if findme == "sh" or findme == "bash" then
    awful.spawn.easy_async_with_shell(
      string.format("%s", cmd),
      function(stdout)
        print(stdout)
      end
    )
  else
    awful.spawn.easy_async_with_shell(
      string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd),
      function(stdout)
        print(stdout)
      end
    )
  end
end

for _, app in ipairs(apps.run_on_start_up) do
  run_once(app)
end
