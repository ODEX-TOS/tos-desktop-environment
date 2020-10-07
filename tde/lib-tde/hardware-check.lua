local fileHandle = require("lib-tde.file")

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
function battery()
    return fileHandle.dir_exists("/sys/class/power_supply/BAT0") or
        fileHandle.dir_exists("/sys/class/power_supply/BAT1")
end

function wifi()
    out, returnValue = osExecute("nmcli radio wifi")
    return out == "enabled" or out == "enabled\n"
end

function bluetooth()
    out, returnValue = osExecute("systemctl is-active bluetooth")
    -- only check if a bluetooth controller is found if the bluetooth service is active
    -- Otherwise the system will hang
    if returnValue == 0 then
        -- list all present controllers
        out2, returnValue2 = osExecute("bluetoothctl list")
        return returnValue2 == 0
    end
    return false
end

function ffmpeg()
    out, returnValue = osExecute("pacman -Q ffmpeg")
    return returnValue == 0
end

function sound()
    out, returnValue = osExecute("pactl info | grep 'Sink'")
    return returnValue == 0
end

return {
    hasBattery = battery,
    hasWifi = wifi,
    hasBluetooth = bluetooth,
    hasFFMPEG = ffmpeg,
    hasSound = sound
}
