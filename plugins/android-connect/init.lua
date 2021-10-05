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

local command_exists = require("lib-tde.hardware-check").is_in_path
local daemon = require("lib-tde.daemonize").run
local naughty = require("naughty")

local path = require("lib-tde.plugin").path()

local _adb_exists = command_exists("adb")
local _auto_adb = command_exists("autoadb")
local _scrcpy_exists = command_exists("scrcpy")

-- optional to stream audio
local _sndcpy_exists = command_exists("sndcpy")


local function notify(msg)
    naughty.notification(
        {
            title = "Android",
            text = msg,
            timeout = 5,
            urgency = "critical",
            icon = path .. '/logo.svg'
        }
    )
end


if not _scrcpy_exists then
    notify(i18n.translate("Please install %s", "scrcpy"))
    return
end

if not _auto_adb then
    notify(i18n.translate("Please install %s", "autoadb"))
    return
end

if not _adb_exists then
    notify(i18n.translate("Please install %s", "adb"))
    return
end


-- We can run the android auto connection tool

daemon({"autoadb", "scrcpy", "--window-title", "TDE Android", "-S", '-f', "-s", "{}"}, {
    restart = true,
    kill_previous = true,
    kill_cmd = "sh -c 'killall %s && killall scrcpy'"
})

if _sndcpy_exists then
    daemon({"autoadb", "bash", "-c", "{ sleep 30 && yes '' ; } | sndcpy"}, {
        restart = true,
        max_restarts = 5,
        kill_previous = false,
        kill_cmd = "sh -c 'killall %s && killall sndcpy'"
    })
end