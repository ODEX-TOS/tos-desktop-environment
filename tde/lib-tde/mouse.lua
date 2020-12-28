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
-- This module exposes an api to manipulate mouse events through libinput
--
-- Usefull functional for setting mouse acceleration, natural scrolling, mouse speed and more
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.mouse
-----------------

local execute = require("lib-tde.hardware-check").execute
local split = require("lib-tde.function.common").split
local signals = require("lib-tde.signals")

--- Returns a table of all mouse input devices ranging from trackpads, to mouses to trackpoints
-- @treturn table The table containing a field with the id and canonical name
-- @staticfct getInputDevices
-- @usage -- Returns for example {{"id": 11, "name": "HID-compliant Mouse Trust Gaming Mouse"}}
--    local devices = getInputDevices()
--    print("The first device is called: " .. devices[1].name .. " and has ID: " .. devices[1].id)
local function getInputDevices()
    local identifier = {"mouse", "trackpad", "trackpoint"}

    local names = execute("xinput --list --name-only")
    names = split(names, "\n")

    local ids = execute("xinput --list --id-only")
    ids = split(ids, "\n")

    local result = {}
    -- loop over all identifiers
    for index, id in ipairs(ids) do
        -- get the corresponding name and check if it is a mouse
        for _, match in ipairs(identifier) do
            -- if it is a mouse then add it to the list
            if string.find(names[index]:lower(), match) then
                table.insert(result, {
                    id = tonumber(id),
                    name = names[index]
                })
            end
        end
    end

    return result
end

--- Set the accellaration of a specific input device through xinput
-- @tparam number id the identifier of the mouse @see getInputDevices
-- @tparam number speed The accellaration speed of the mouse, 1.0 means no accellaration and anything above indicates faster speed than default as a multiplier
-- @staticfct setAccellaration
-- @usage -- Make the "HID-compliant Mouse Trust Gaming Mouse" accellarate by twice its normal speed
--    setAccellaration(11, 2)
local function setAccellaration(id, speed)
    if type(id) ~= "number" then
        return
    end
    if type(speed) ~= "number" then
        return
    end

    if speed > 1 then
        speed = 1
    elseif speed < 0 then
        speed = 0
    end

    local cmd = string.format("xinput set-prop %d 'libinput Accel Speed' %.1f", id, speed)
    print("Setting mouse accellaration speed: " .. cmd)
    execute(cmd)

    signals.emit_mouse_accellaration({
        id = id,
        speed = speed
    })
end

--- Set the accellaration of a specific input device through xinput
-- @tparam number id the identifier of the mouse @see getInputDevices
-- @tparam number speed The default speed of the mouse, 1.0 means standard libinput speed anything larger is faster, anything smaller is slower (minimum speed is 0.01)
-- @staticfct setMouseSpeed
-- @usage -- Make the "HID-compliant Mouse Trust Gaming Mouse" twice as slow as the default speed
--    setMouseSpeed(11, 0.5)
local function setMouseSpeed(id, speed)
    if type(id) ~= "number" then
        return
    end
    if type(speed) ~= "number" then
        return
    end

    if speed > 10 then
        speed = 10
    elseif speed < 0.05 then
        speed = 0.05
    end

    local cmd = string.format("xinput set-prop %d 'Coordinate Transformation Matrix' %.1f 0 0 0 %.1f 0 0 0 1", id, speed, speed)
    print("Setting mouse speed: " .. cmd)
    execute(cmd)

    signals.emit_mouse_speed({
        id = id,
        speed = speed
    })
end

--- Enable/Disable natural scrolling for the mouse
-- @tparam number id the identifier of the mouse @see getInputDevices
-- @tparam number bIsNaturalScrolling Enable or Disable natural scrolling for the mouse
-- @staticfct setNaturalScrolling
-- @usage -- Enable natural scrolling speed for "HID-compliant Mouse Trust Gaming Mouse"
--    setNaturalScrolling(11, true)
local function setNaturalScrolling(id, bIsNaturalScrolling)
    if type(id) ~= "number" then
        return
    end
    if type(bIsNaturalScrolling) ~= "boolean" then
        return
    end

    local naturalScrolling = 0
    if bIsNaturalScrolling then
        naturalScrolling = 1
    end

    local cmd = string.format("xinput set-prop %d 'libinput Natural Scrolling Enabled' %d", id, naturalScrolling)
    print("Setting mouse natural scrolling: " .. cmd)
    execute(cmd)

    signals.emit_mouse_natural_scrolling({
        id = id,
        state = bIsNaturalScrolling
    })
end

-- TODO: implement scrolling speed as well

return {
    getInputDevices = getInputDevices,
    setAccellaration = setAccellaration,
    setMouseSpeed = setMouseSpeed,
    setNaturalScrolling = setNaturalScrolling,
}