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
---------------------------------------------------------------------------
-- This module helps with running applications as defined in autostart.
--
-- Running software that guaranteed running only once can be troublesome.
-- For example you have written a shell script that launches a webserver.
-- We would only want to start the webserver once.
--
--    -- this will run the script
--    lib-tde.function.application_runner.run_once(os.getenv("HOME") .. "/launch-webserver.sh") -- returns true
--
--    -- this won't run the script
--    lib-tde.function.application_runner.run_once(os.getenv("HOME") .. "/launch-webserver.sh") -- returns false
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.function.application_runner
---------------------------------------------------------------------------

local ran_before = {}

--- run a shell command asynchronously and run it only the first time
-- @tparam string cmd The shell command to run
-- @treturn bool Returns true if the command ran
-- @staticfct run_once
-- @usage -- This will return true
-- lib-tde.function.application_runner.run_once("echo 'hello'")
local function run_once(cmd)
    if cmd == "" then
        return false
    end
    if not (type(cmd) == "string") then
        return false
    end
    if not (ran_before[cmd] == nil) then
        return false
    end
    ran_before[cmd] = true
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
    return true
end

return run_once
