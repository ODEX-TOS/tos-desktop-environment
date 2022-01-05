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
-- Perform queries on the hardware to validate certain components from existing.
--
-- Each piece of hardware is different and supports different components.
-- For example a laptop vs desktop, usually a laptop has a battery whilst a desktop doesn't.
-- You can query this api to discover certain components that should exist.
--
--    lib-tde.hardware-check.battery() -- returns True if a battery exists
--    lib-tde.hardware-check.wifi() -- returns True if wifi is supported
--    lib-tde.hardware-check.bluetooth() -- returns True if bluetooth is supported
--    lib-tde.hardware-check.sound() -- returns True if sound is working
--
-- You can also use this module to verify if the environment is configured correctly.
-- For example you can have hard dependencies on some software to get a plugin working.
-- An example is the build in screen recorder that depends on ffmpeg being installed.
--
--    lib-tde.hardware-check.has_package_installed("ffmpeg") -- returns True if ffmpeg is installed
--
-- Warning never try to use `lib-tde.hardware-check.execute` unless you known what you are doing.
-- execute runs on the main thread and can cause input from not being handled.
-- Which introduces lag to the system.
-- Here is an example that locks the desktop for 2 seconds (where you can't do anything).
--
--    lib-tde.hardware-check.execute("sleep 2") -- block the main thread for 2 seconds
--
-- This module is constantly updated to support new queries and new possible dependencies.
-- PR's are always welcome :)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.hardware-check
---------------------------------------------------------------------------

local fileHandle = require("lib-tde.file")
local batteryHandle = require("lib-tde.function.battery")
local common = require('lib-tde.function.common')

local time = require("socket").gettime

local LOG_WARN = "\27[0;33m[ WARN "

--- Executes a shell command on the main thread, This is dangerous and should be avoided as it blocks input!!
-- @tparam cmd string The command to execute
-- @tparam[opt=stderr] stderr boolean Should return stderr output instead of stdout
-- @treturn tuple The first element is the standard output of the command (string), the second element is the exit code (number)
-- @staticfct execute
-- @usage -- This returns Tuple<"hello", 0>
-- lib-tde.hardware-check.execute("echo hello")
local function osExecute(cmd, stderr)
    print("Running synchronous shell code can dramatically slow down execution", LOG_WARN)
    print("The command being ran is:", LOG_WARN)
    print(tostring(cmd), LOG_WARN)
    print("Please use awful.spawn.easy_async(cmd, callback) instead", LOG_WARN)

    local start = time()
    local handle
    if stderr == nil or stderr == false then
        handle = assert(io.popen(cmd, "r"))
    else
        handle = assert(io.popen('sh -c "' .. cmd .. ' 2>&1"', "r"))
    end
    local commandOutput = assert(handle:read("*a"))
    local returnTable = {handle:close()}
    local stop = time()

    if _G.tt == nil then
        _G.tt = 0
    end

    _G.tt = _G.tt + (stop - start)

    print(string.format("Your command blocked the main thread for: %f seconds", stop - start), LOG_WARN)
    print(string.format("Total time commands blocked the main thread for: %f seconds", _G.tt), LOG_WARN)

    return commandOutput, returnTable[3] -- rc[3] contains returnCode
end

-- These functions check if the hardware component exists
-- These are usually used to enable/disable certain widgets that are not needed on our system
-- Extend the below functions depending if you need the perform another check on some widget
-- PS: Each function should return a boolean depending on if the hardware is available

--- Check to see if a battery exists on the hardware
-- @treturn bool True if a battery exists, false otherwise
-- @staticfct hasBattery
-- @usage -- This True if it is a laptop
-- lib-tde.hardware-check.hasBattery()
local function battery()
    return batteryHandle.getBatteryPath() ~= nil
end

--- Check to see the hardware has a network card
-- @treturn bool True if an active wifi connection exists, false otherwise
-- @staticfct hasWifi
-- @usage -- This True if a network card with wifi exists and has an active connection
-- lib-tde.hardware-check.hasWifi()
local function wifi()
    return fileHandle.exists("/proc/net/wireless") and #fileHandle.lines("/proc/net/wireless") > 2
end

--- Check to see the hardware has a network card
-- @treturn bool True if a network card exists, false otherwise
-- @staticfct hasWifiCard
-- @usage -- This True if a network card with wifi exists
-- lib-tde.hardware-check.hasWifiCard()
local function wifiCard()
    return fileHandle.exists("/proc/net/wireless") and #fileHandle.lines("/proc/net/wireless") > 0
end

--- Check to see the hardware has a network card with bluetooth support
-- @tparam function callback The callback to trigger once we detect the bluetooth status
-- @treturn bool True if a network card exists with bluetooth support, false otherwise
-- @staticfct hasBluetooth
-- @usage -- This True if a network card exists with bluetooth support
-- lib-tde.hardware-check.hasBluetooth(function(bHasBluetooth) print(bHasBluetooth) end)
local function bluetooth(callback)
    awful.spawn.easy_async("systemctl is-active bluetooth", function (_, _, _, returnValue)
        -- only check if a bluetooth controller is found if the bluetooth service is active
        -- Otherwise the system will hang
        if returnValue == 0 then
            print(returnValue)
            -- list all present controllers
            awful.spawn.easy_async("bluetoothctl list" , function (_, _, _, returnValue2)
                print(returnValue2)
                callback(returnValue2 == 0)
            end)
        else
            callback(false)
        end
    end)
end

--- Check if a certain binary is in the PATH variable
-- @tparam cmd string the binary command
-- @treturn bool True if the command exists
-- @treturn string The full executable name
-- @staticfct is_in_path
-- @usage -- this returns /bin/bash
-- lib-tde.hardware-check.is_in_path("bash")
local function is_in_path(cmd)
    if fileHandle.exists(cmd) then
        return true, cmd
    end

    -- check all directories in the path variable and see if cmd exists there
    local dirs = common.split(os.getenv("PATH"), ":")
    for _, dir in ipairs(dirs) do
        local full_path = dir .. '/' .. cmd
        if fileHandle.exists(full_path) then
            return true, full_path
        end
    end

    -- the command was not found in any dir, so it doesn't exist
    return false, ""
end

--- Check if a certain piece of software is installed
-- @tparam name string The name of the software package
-- @tparam callback function  The function to call when we know if the package exists
-- @treturn bool True that piece of software is installed, false otherwise
-- @staticfct has_package_installed
-- @usage -- This True for TOS based systems
-- lib-tde.hardware-check.has_package_installed("linux-tos", function(bIsInstalled) print(bIsInstalled) end)
local function has_package_installed(name, callback)
    if name == "" or not (type(name) == "string") then
        return callback(false)
    end

    local in_path = is_in_path(name)
    if in_path then
        return callback(true)
    end

    -- it is not in our path, now we do a heavy operation
    awful.spawn.easy_async("pacman -Q " .. name, function (_,_,_, rc)
        callback(rc == 0)
    end)
end


--- Check to see if ffmpeg is installed
-- @tparam callback function  The function to call when we know if the package exists
-- @treturn bool True if ffmpeg is installed, false otherwise
-- @staticfct hasFFMPEG
-- @usage -- This True if ffmpeg is installed (a video processor)
-- lib-tde.hardware-check.hasFFMPEG(function(bIsInstalled) print(bIsInstalled) end)
local function ffmpeg(callback)
    has_package_installed("ffmpeg", callback)
end

--- Check to see the hardware has a sound card installed
-- @treturn bool True if a sound card exists, false otherwise
-- @staticfct hasSound
-- @usage -- This True if a sound card exists
-- lib-tde.hardware-check.hasSound()
local function sound()
    return fileHandle.exists("/proc/asound/cards") and #fileHandle.lines("/proc/asound/cards") > 1
end

--- Returns the ip address of the default route
-- @return string ipv4 address as a string
-- @staticfct getDefaultIP
-- @usage -- For example returns 192.168.1.12
-- lib-tde.hardware-check.getDefaultIP()
local function getDefaultIP()
    -- we create a socket to 0.0.0.1 as that ip is guaranteed to be in the default gateway
    -- however we never send a packet as that would leek user data
    -- and would't work in private networks
    local socket = require("socket").udp()
    socket:setpeername("0.0.0.1", 81)
    local ip = socket:getsockname() or "0.0.0.0"
    return ip
end

--- Returns general information about system ram
-- @treturn number, number The ram usage and ram total in KiloBytes
-- @staticfct getRamInfo
-- @usage -- For example, 50(%), 10000000(kB)
-- lib-tde.hardware-check.getRamInfo()
local function getRamInfo()
    local length = 24
    local stdout = fileHandle.lines("/proc/meminfo")
    if #stdout < length then
        return
    end
    local total = tonumber(string.gmatch(stdout[1], "%d+")())
    local free = tonumber(string.gmatch(stdout[2], "%d+")())
    local buffer = tonumber(string.gmatch(stdout[4], "%d+")())
    local cache = tonumber(string.gmatch(stdout[5], "%d+")())
    local sReclaimable = tonumber(string.gmatch(stdout[24], "%d+")())

    -- the used ram in kB
    local used = total - free - buffer - cache - sReclaimable

    -- the usage in percent
    local usage = (used / total) * 100
    return usage, total
end

--- Returns general information about the cpu
-- @treturn number, number, string, number The cpu core count, thread count, canonical name and frequency in MHz
-- @staticfct getCpuInfo
-- @usage -- For example, 8 (cores), 16 (threads), "AMD Ryzen 7 PRO 5800X", 3000(MHz)
-- lib-tde.hardware-check.getCpuInfo()
local function getCpuInfo()
    local stdout = fileHandle.lines("/proc/cpuinfo")

    local name = string.gmatch(stdout[5], ": (.*)$")()
    local frequency = string.gmatch(stdout[8], "%d+")()

    -- find all cpu's (some systems have multi cpu setups)
    local processors = {}
    for index, line in ipairs(stdout) do
        if string.find(line, "^processor[%s]+:") then
            table.insert(processors, index)
        end
    end

    local threads = #processors
    -- TODO: cores is calculated correctly for hardware with one cpu
    -- However, when using multiple cpu's it only shows the core count of the first
    local cores = tonumber(string.gmatch(stdout[13], "%d+")()) or threads
    return cores, threads, name, tonumber(frequency)
end

--- Returns if the hardware is to weak, e.g. little amount of ram, cpu etc
-- @return bool true if the hardware is below a certain threshold
-- @staticfct isWeakHardware
-- @usage -- If ram is below 1G or only one cpu core is present
-- lib-tde.hardware-check.isWeakHardware()
local function isWeakHardware()
    local _, ramtotal = getRamInfo()
    local _, threads = getCpuInfo()
    local minRamInKB = 1 * 1024 * 1024
    return (threads < 2) or (ramtotal < minRamInKB)
end

--- Returns The frequency of the display panel in Hertz, for example 60 Hz
-- @return number The frequency of the display in Hertz
-- @staticfct getDisplayFrequency
-- @usage -- Returns The frequency of the display panel in Hertz, for example 60 Hz
-- lib-tde.hardware-check.getDisplayFrequency()
local function getDisplayFrequency(callback)
    -- TODO: find a way using lgi.Gdk - Gdk::Monitor::get_refresh_rate
    awful.spawn.easy_async_with_shell("xrandr -q --current | awk '$2 ~ /[0-9/.]\\*/{print $2}' | tr -d '*' | tr -d '+' | sort -n | tail -n1", function(out, _, _, rc)
        -- In case nothing works return the default
        if not (rc == 0) then
            callback(60)
            return
        end

        -- make sure the number is in a valid range
        -- Current display don't exceed 1000 Hz so that should be a sane value
        local number = tonumber(out) or 60
        if number < 1 or number > 1000 then
            callback(60)
            return
        end
        callback(number)
    end)
end

--- Returns The amount of memory consumed by the desktop environment
-- @return number The total memory consumption
-- @return number The memory consumption inside of lua
-- @staticfct getTDEMemoryConsumption
-- @usage -- Returns The total memory consumption and consumption in lua (Heap + Stack)
-- local total, lua_mem = lib-tde.hardware-check.getTDEMemoryConsumption()
local function getTDEMemoryConsumption()
    local lua_mem = collectgarbage("count")
    local statm = fileHandle.lines('/proc/self/statm')[1] or ""
    local kbMem  = tonumber(common.split(statm, ' ')[2]) or 0

    -- we multiply by the page size of 4KB
    -- as statm returns the amount of pages
    return kbMem * 4, lua_mem
end

--- Returns the user id of the user running TDE
-- @return number The UID of the calling process
-- @staticfct getUID
-- @usage -- Returns the user ID (Usually 1000 for single user systems)
-- local uid = lib-tde.hardware-check.getUID()
local function getUID()
    return require("posix.unistd").getuid()
end

return {
    hasBattery = battery,
    hasWifi = wifi,
    hasWifiCard = wifiCard,
    hasBluetooth = bluetooth,
    hasFFMPEG = ffmpeg,
    hasSound = sound,
    has_package_installed = has_package_installed,
    getDefaultIP = getDefaultIP,
    getRamInfo = getRamInfo,
    getCpuInfo = getCpuInfo,
    isWeakHardware = isWeakHardware,
    getDisplayFrequency = getDisplayFrequency,
    getTDEMemoryConsumption = getTDEMemoryConsumption,
    execute = osExecute,
    getUID = getUID,
    is_in_path = is_in_path,
}
