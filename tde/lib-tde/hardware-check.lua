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

--- Executes a shell command on the main thread, This is dangerous and should be avoided as it blocks input!!
-- @tparam cmd string The command to execute
-- @treturn tuple<string, number> The first element is the standard output of the command (string), the second element is the exit code (number)
-- @staticfct execute
-- @usage -- This returns Tuple<"hello", 0>
-- lib-tde.hardware-check.execute("echo hello")
local function osExecute(cmd)
    local handle = assert(io.popen(cmd, "r"))
    local commandOutput = assert(handle:read("*a"))
    local returnTable = {handle:close()}
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
-- @treturn bool True if a network card exists, false otherwise
-- @staticfct hasWifi
-- @usage -- This True if a network card with wifi exists
-- lib-tde.hardware-check.hasWifi()
local function wifi()
    return fileHandle.exists("/proc/net/wireless")
end

--- Check to see the hardware has a network card with bluetooth support
-- @treturn bool True if a network card exists with bluetooth support, false otherwise
-- @staticfct hasBluetooth
-- @usage -- This True if a network card exists with bluetooth support
-- lib-tde.hardware-check.hasBluetooth()
local function bluetooth()
    local _, returnValue = osExecute("systemctl is-active bluetooth")
    -- only check if a bluetooth controller is found if the bluetooth service is active
    -- Otherwise the system will hang
    if returnValue == 0 then
        -- list all present controllers
        local _, returnValue2 = osExecute("bluetoothctl list")
        return returnValue2 == 0
    end
    return false
end

--- Check if a certain piece of software is installed
-- @tparam name string The name of the software package
-- @treturn bool True that piece of software is installed, false otherwise
-- @staticfct has_package_installed
-- @usage -- This True for TOS based systems
-- lib-tde.hardware-check.has_package_installed("linux-tos")
local function has_package_installed(name)
    if name == "" or not (type(name) == "string") then
        return false
    end
    local _, returnValue = osExecute("pacman -Q " .. name)
    return returnValue == 0
end

--- Check to see if ffmpeg is installed
-- @treturn bool True if ffmpeg is installed, false otherwise
-- @staticfct hasFfmpeg
-- @usage -- This True if ffmpeg is installed (a video processor)
-- lib-tde.hardware-check.hasFfmpeg()
local function ffmpeg()
    return has_package_installed("ffmpeg")
end

--- Check to see the hardware has a sound card installed
-- @treturn bool True if a sound card exists, false otherwise
-- @staticfct hasSound
-- @usage -- This True if a sound card exists
-- lib-tde.hardware-check.hasSound()
local function sound()
    local _, returnValue = osExecute("pactl info | grep 'Sink'")
    return returnValue == 0
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
local function getDisplayFrequency()
    local out, rc = osExecute("xrandr -q --current | grep -o '[0-9\\.]*\\*' | awk '{printf $1}' | tr -d '*'")
    -- In case nothing works return the default
    if not (rc == 0) then
        return 60
    end
    -- make sure the number is in a valid range
    -- Current display don't exceed 1000 Hz so that should be a sane value
    local number = tonumber(out) or 60
    if number < 1 or number > 1000 then
        return 60
    end
    return number
end

return {
    hasBattery = battery,
    hasWifi = wifi,
    hasBluetooth = bluetooth,
    hasFFMPEG = ffmpeg,
    hasSound = sound,
    has_package_installed = has_package_installed,
    getDefaultIP = getDefaultIP,
    getRamInfo = getRamInfo,
    getCpuInfo = getCpuInfo,
    isWeakHardware = isWeakHardware,
    getDisplayFrequency = getDisplayFrequency,
    execute = osExecute
}
