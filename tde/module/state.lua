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
-- This makes certain data persistent

local signals = require("lib-tde.signals")
local serialize = require("lib-tde.serialize")
local filehandle = require("lib-tde.file")
local mouse = require("lib-tde.mouse")
local volume = require("lib-tde.volume")

local file = os.getenv("HOME") .. "/.cache/tde/settings_state.json"

local function load()
    local table = {
        volume = 50,
        volume_muted = false,
        brightness = 100,
        mouse = {},
        do_not_disturb = false,
        oled_mode = false
    }
    if not filehandle.exists(file) then
        return table
    end
    local result = serialize.deserialize_from_file(file)
    -- in case someone modified the state object and some properties are faulty or errored outputs
    result.volume = result.volume or table.volume
    result.volume_muted = result.volume_muted or table.volume_muted
    result.brightness = result.brightness or table.brightness
    result.mouse = result.mouse or table.mouse
    result.do_not_disturb = result.do_not_disturb or table.do_not_disturb
    result.oled_mode = result.oled_mode or table.oled_mode
    return result
end

local function save(table)
    print("Updating state into: " .. file)
    serialize.serialize_to_file(file, table)
end

local function setup_state(state)
    -- set volume mute state
    volume.set_muted_state(state.volume_muted)

    -- set the volume
    print("Setting volume: " .. state.volume)
    volume.set_volume(state.volume or 0)
    signals.emit_volume_update()

    -- set the brightness
    if (_G.oled) then
        awful.spawn("brightness -s " .. math.max(state.brightness, 5) .. " -F") -- toggle pixel values
    else
        awful.spawn("brightness -s 100 -F") -- reset pixel values
        awful.spawn("brightness -s " .. math.max(state.brightness, 5))
    end

    signals.emit_brightness(math.max(state.brightness, 5))
    signals.emit_do_not_disturb(state.do_not_disturb or false)
    signals.emit_oled_mode(state.oled_mode or false)
    -- execute xrandr script
    awesome.connect_signal(
        "startup",
        function()
            awful.spawn.easy_async(
                "sh -c 'which autorandr && autorandr --load tde'",
                function()
                end
            )
            signals.connect_refresh_screen(
                function()
                    -- update our wallpaper
                    awful.spawn("sh -c 'tos theme set $(tos theme active)'")
                    --awful.spawn("sh -c 'which autorandr && autorandr --load tde'")
                end
            )
        end
    )
    -- find all mouse peripheral that are currently attached to the machine
    if state.mouse then
        local devices = mouse.getInputDevices()
        for _, device in ipairs(devices) do
            -- if they exist then set their properties
            if state.mouse[device.name] ~= nil then
                mouse.setAcceleration(device.id, state.mouse[device.name].accel or 0)
                mouse.setMouseSpeed(device.id, state.mouse[device.name].speed or 1)
                mouse.setNaturalScrolling(device.id, state.mouse[device.name].natural_scroll or false)
            end
        end
    end
end

-- load the initial state
-- luacheck: ignore 121
save_state = load()
setup_state(save_state)

-- xinput id's are not persistent across reboots
-- thus we map the xinput id to the device name, which is always the same
-- in case our state doesn't have the id yet we create it
local function get_mouse_state_id(id)
    local devices = mouse.getInputDevices()
    -- find the name in the device range
    local name = nil
    for _, device in ipairs(devices) do
        if device.id == id then
            name = device.name
        end
    end
    if save_state.mouse == nil then
        save_state.mouse = {}
    end
    if name ~= nil and save_state.mouse[name] == nil then
        save_state.mouse[name] = {
            accel = 0,
            speed = 1,
            natural_scroll = false
        }
    end
    return name
end

-- listen for events and store the state on those events

signals.connect_volume(
    function(value)
        save_state.volume = value
        save(save_state)
    end
)

signals.connect_volume_is_muted(
    function(is_muted)
        save_state.volume_muted = is_muted
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
        awful.spawn("sh -c 'which autorandr && autorandr --save tde --force'")
        save(save_state)
    end
)

-- mouse related signals
signals.connect_mouse_speed(
    function(tbl)
        print("Saving mouse id: " .. tbl.id .. " to speed value: " .. tbl.speed)
        local id = get_mouse_state_id(tbl.id)
        if id ~= nil then
            save_state.mouse[id].speed = tbl.speed
            save(save_state)
        end
    end
)

signals.connect_mouse_acceleration(
    function(tbl)
        print("Saving mouse id: " .. tbl.id .. " to accel value: " .. tbl.speed)
        local id = get_mouse_state_id(tbl.id)
        if id ~= nil then
            save_state.mouse[id].accel = tbl.speed
            save(save_state)
        end
    end
)

signals.connect_do_not_disturb(
    function(bDoNotDisturb)
        print("Changed do not disturb: " .. tostring(bDoNotDisturb))
        save_state.do_not_disturb = bDoNotDisturb
        save(save_state)
    end
)

signals.connect_oled_mode(
    function(bIsOledMode)
        print("Changed oled mode to: " .. tostring(bIsOledMode))
        save_state.oled_mode = bIsOledMode
        save(save_state)
    end
)

signals.connect_mouse_natural_scrolling(
    function(tbl)
        print("Saving mouse id: " .. tbl.id .. " to natural scrolling state: " .. tostring(tbl.state))
        local id = get_mouse_state_id(tbl.id)
        if id ~= nil then
            save_state.mouse[id].natural_scroll = tbl.state
            save(save_state)
        end
    end
)
