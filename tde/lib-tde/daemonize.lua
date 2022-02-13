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
-- Daemonize a given process
--
-- This will run a process in the background (As the user that runs TDE) and guarantees that is is up and running
--
--    lib-tde.daemonize.run("picom", {restart = true, max_restarts=-1}) -- true to restart
--
-- @author Tom Meyers
-- @copyright 2021 Tom Meyers
-- @tdemod lib-tde.daemonize
---------------------------------------------------------------------------

local split = require("lib-tde.function.common").split
local hardware = require("lib-tde.hardware-check")

local LOG_ERROR = "\27[0;31m[ ERROR "


local function __run_cmd_in_background(cmd, start_cb, callback, should_kill, kill_cmd)
    print("Starting daemon process:")
    print(cmd)

    if should_kill then
        print("Killing")
        print(kill_cmd)
        awful.spawn.easy_async(kill_cmd, function()
            if start_cb ~= nil then start_cb() end
            awful.spawn.easy_async(cmd, callback)
        end)
        return
    end

    if start_cb ~= nil then start_cb() end
    awful.spawn.easy_async(cmd, callback)
end

local function get_command(cmd)
    if type(cmd) == "string" then
        return split(cmd, " ")[1] or ""
    elseif type(cmd) == "table" then
        return cmd[1] or ""
    end
    return ""
end

local function not_exists(cmd)
    local command = get_command(cmd)

    if command == "" or command == nil then
        return false
    end

    -- check if command exists in path
    return not hardware.is_in_path(command)
end

local function __run(cmd, restart, max_restarts, should_kill, kill_cmd, callback, start_cb)
    local restarts = 0

    if not_exists(cmd) then
        -- invalid command, aborting
        print("Is not a valid daemonizable process, doesn't exist:", LOG_ERROR)
        print(cmd, LOG_ERROR)
        return
    end

    local restart_callback
    restart_callback = function()

        if callback ~= nil and type(callback) == "function" then
            callback()
        end

        -- when the command is done, increment the restart counter
        restarts = restarts + 1
        if max_restarts > 0 and restarts > max_restarts then
            -- we reached the max_retry count
            print("We reached the max_retry count of: " .. tostring(max_restarts) .. " for process", LOG_ERROR)
            print(cmd, LOG_ERROR)
            return
        end

        if not restart then
            -- we shouldn't restart the process
            return
        end

        -- lets restart the process
        __run_cmd_in_background(cmd, start_cb, restart_callback, should_kill, kill_cmd)
    end

    __run_cmd_in_background(cmd, start_cb, restart_callback, should_kill, kill_cmd)
end

--- Add custom translations into the translation lookup table
-- @tparam table|string cmd The command to run as a daemon
-- @tparam[opt] bool args.restart If the process should restart after finishing execution
-- @tparam[opt] number args.max_restarts The amount of restarts until we stop trying to restart the program
-- @tparam[opt] number args.kill_previous Kill the previous running command if found using the kill_cmd variable
-- @tparam[opt] string args.kill_cmd The command used to kill the previous process %s will be replaced by the process name, default 'killall %s'
-- @tparam[opt] function args.start_cb A function to run before the process started/restarted
-- @tparam[opt] function args.callback A function to run after the process started/restarted
-- @staticfct run
-- @usage -- Run the program forever
-- daemonize.run("touchegg") -- runs the program called touchegg and restarts it forever
-- daemonize.run("picom", {restart = false}) -- Don't restart the compositor after a crash
-- daemonize.run("echo hello", {max_restarts = 10}) -- Run the echo hello program 10 times then stop
local function run(cmd, args)
    local restart = args.restart
    local kill_previous = args.kill_previous

    if restart == nil then
        restart = true
    end

    if kill_previous == nil then
        kill_previous = false
    end

    local max_restarts = args.max_restarts or -1 -- -1 means restart forever
    local kill_cmd = args.kill_cmd or "pkill '%s'"
    local command = get_command(cmd)

    local callback = args.callback
    local start_cb = args.start_cb

    __run(cmd, restart, max_restarts, kill_previous, string.format(kill_cmd, command), callback, start_cb)
end

return {
    run = run
}
