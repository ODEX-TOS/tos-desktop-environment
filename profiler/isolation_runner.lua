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
local hardware = require("tde.lib-tde.hardware-check")

_G.DISPLAY_ID = 100

-- Takes as parameter a string called config
-- which is the rc.lua file that should be executed with awesomewm
-- it returns a tuple of type, assertion and boolean and stdout
-- the assertion is of type boolean and tells use if no crash occurred
-- the boolean tells us if we found IT-test-result:true in the output
-- this string should tell us if we encountered what we expect from the Integration Test
-- The last element is the stdout from awesomewm
local function run_rc_config_in_xephyr(config, _, _, _)
    local timeout = (tonumber(os.getenv("TOTAL_TIME")) + 1) or 10

    if os.getenv("MULTIPLIER") then
        timeout = timeout * tonumber(os.getenv("MULTIPLIER"))
    end
    -- make sure we have the correct dependencies before running the integration test
    assert(hardware.has_package_installed("xorg-server-xephyr"))
    assert(hardware.has_package_installed("awesome-tos"))
    assert(hardware.has_package_installed("bash"))

    -- we generate display values high enough to prevent collision from occurring
    _G.DISPLAY_ID = _G.DISPLAY_ID + 1
    -- we prevent collision between display that are not closed yet by always increasing the number for each Integration Test
    local DISPLAY = ":" .. _G.DISPLAY_ID

    -- this is the command to launch TDE
    local ENV =
        "XDG_CURRENT_DESKTOP=TDE TDE_ENV=develop DISPLAY=" ..
        DISPLAY ..
            " REALTIME='" ..
                os.getenv("REALTIME") ..
                    "' FUNCTIONS_AMOUNT='" ..
                        os.getenv("FUNCTIONS_AMOUNT") ..
                            "' OUTPUT='" .. os.getenv("OUTPUT") .. "' TOTAL_TIME='" .. os.getenv("TOTAL_TIME") .. "' "
    local launchCMD = "tde --config " .. config
    local xephyrCommand = "DISPLAY=:0 Xephyr -br -ac -reset -once -terminate -screen 700x700 " .. DISPLAY .. " &"
    local command =
        "timeout " ..
        tostring(timeout) .. " bash -c '(" .. xephyrCommand .. "); sleep 1; " .. ENV .. " " .. launchCMD .. "'"
    print(command)
    local out, ret = hardware.execute(command)
    -- timeout command return exit code 124 if the command had to be halted
    -- we give 10 seconds boot time to test crashes
    return ret == 124, out
end

return {
    run_rc_config_in_xephyr = run_rc_config_in_xephyr
}
