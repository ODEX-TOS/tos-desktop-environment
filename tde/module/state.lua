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
-- This module listens for events and stores then
-- This makes certain data persistant

local signals = require("lib-tde.signals")
local serialize = require("lib-tde.serialize")
local filehandle = require("lib-tde.file")

local file = os.getenv("HOME") .. "/.cache/tde/settings_state.json"

local function load()
    local table = {
        volume = 50,
        brightness = 100
    }
    if not filehandle.exists(file) then
        return table
    end
    return serialize.deserialize_from_file(file)
end

local function save(table)
    print("Updating state into: " .. file)
    serialize.serialize_to_file(file, table)
end

local function setup_state(state)
    -- set the volume
    print("Setting volume: " .. state.volume)
    awful.spawn("amixer -D pulse sset Master " .. tostring(state.volume or 0) .. "%")
    signals.emit_volume_update()

    -- set the brightness
    if (_G.oled) then
        awful.spawn("brightness -s " .. math.max(state.brightness, 5) .. " -F") -- toggle pixel values
    else
        awful.spawn("brightness -s 100 -F") -- reset pixel values
        awful.spawn("brightness -s " .. math.max(state.brightness, 5))
    end

    signals.emit_brightness(math.max(state.brightness, 5))

    -- execute xrandr script
    awful.spawn("which autorandr && autorandr --load tde")
end

-- load the initial state
local save_state = load()
setup_state(save_state)

-- listen for events and store the state on those events

signals.connect_volume(
    function(value)
        save_state.volume = value
        save(save_state)
    end
)

signals.connect_brightness(
    function(value)
        print("Brightness value: " .. value)
        save_state.brightness = value
        save(save_state)
    end
)

signals.connect_exit(
    function()
        print("Shutting down, grabbing last state")
        awful.spawn("which autorandr && autorandr --save tde --force")
        save(table)
    end
)
