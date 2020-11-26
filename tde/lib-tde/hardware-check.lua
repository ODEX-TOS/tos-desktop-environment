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
-- An example is the build in screen recorder that depends on ffmpeg beeing installed.
--
--    lib-tde.hardware-check.has_package_installed("ffmpeg") -- returns True if ffmpeg is installed
--
-- Warning never try to use `lib-tde.hardware-check.execute` unless you known what you are doing.
-- execute runs on the main thread and can cause input from not beeing handled.
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
-- Extend the below functions depening if you need the perform another check on some widget
-- PS: Each function should return a boolean depending on if the hardware is available

--- Check to see if a battery exists on the hardware
-- @treturn bool True if a battery exists, false otherwise
-- @staticfct battery
-- @usage -- This True if it is a laptop
-- lib-tde.hardware-check.battery()
local function battery()
    return fileHandle.dir_exists("/sys/class/power_supply/BAT0") or
        fileHandle.dir_exists("/sys/class/power_supply/BAT1")
end

--- Check to see the hardware has a network card
-- @treturn bool True if a network card exists, false otherwise
-- @staticfct wifi
-- @usage -- This True if a network card exists
-- lib-tde.hardware-check.wifi()
local function wifi()
    local out, _ = osExecute("nmcli radio wifi")
    return out == "enabled" or out == "enabled\n"
end

--- Check to see the hardware has a network card with bluetooth support
-- @treturn bool True if a network card exists with bluetooth support, false otherwise
-- @staticfct bluetooth
-- @usage -- This True if a network card exists with bluetooth support
-- lib-tde.hardware-check.bluetooth()
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
    if name == "" or name == nil then
        return false
    end
    local _, returnValue = osExecute("pacman -Q " .. name)
    return returnValue == 0
end

--- Check to see if ffmpeg is installed
-- @treturn bool True if ffmpeg is installed, false otherwise
-- @staticfct ffmpeg
-- @usage -- This True if ffmpeg is installed (a video processor)
-- lib-tde.hardware-check.ffmpeg()
local function ffmpeg()
    return has_package_installed("ffmpeg")
end

--- Check to see the hardware has a sound card installed
-- @treturn bool True if a sound card exists, false otherwise
-- @staticfct sound
-- @usage -- This True if a sound card exists
-- lib-tde.hardware-check.sound()
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

return {
    hasBattery = battery,
    hasWifi = wifi,
    hasBluetooth = bluetooth,
    hasFFMPEG = ffmpeg,
    hasSound = sound,
    has_package_installed = has_package_installed,
    getDefaultIP = getDefaultIP,
    execute = osExecute
}
