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
-- This module exposes an api to manipulate volume events through pulseaudio/pipewire
--
-- Usefull functional for setting volume active sinks, input/output etc
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.volume
-----------------
local hardware = require("lib-tde.hardware-check")
local execute = hardware.execute
local split = require("lib-tde.function.common").split

local err = "\27[0;31m[ ERROR "

local function _extract_pa_ctl_state(command, id, port, description)
    local res = split(execute("pactl list " .. command), "\n")
    local lastPort
    local lastSink
    local lastDescription
    local lastSinkId

    local result = {}

    for _, value in ipairs(res) do
        local descriptionMatch = value:match(description)
        if descriptionMatch ~= nil then
            lastDescription = descriptionMatch
        end

        local portMatch = value:match(port)
        if portMatch ~= nil then
            lastPort = portMatch
        end

        local sinkMatch = value:match(id)
        if sinkMatch ~= nil then
            lastSink = sinkMatch
        end

        local sinkId = value:match("Name: (.*)$")
        if sinkId ~= nil then
            lastSinkId = sinkId
        end


        if lastPort ~= nil and lastSink ~= nil and lastDescription ~= nil and lastSinkId ~= nil then
            table.insert(result, {
                --- The canonical name of the audio device
                -- @property name
                -- @param string
                name = lastDescription,
                --- the current sink/source number (used to set sink/source)
                -- @property sink
                -- @param number
                sink = tonumber(lastSink) or 0,
                --- The active port in the sink/source
                -- @property port
                -- @param string
                port = lastPort,
                --- The unique identifier for the sink
                -- @property id
                -- @param string
                id = lastSinkId
            })
            lastDescription = nil
            lastSink = nil
            lastPort = nil
            lastSinkId = nil
        end
    end
    return result
end

--- Get the volume asynchronously
-- @tparam function callback A callback function to trigger when the volume is gathered
-- @staticfct get_volume
-- @usage -- Get the volume in percentage
--    get_volume(function(percentage, muted)
--        print("Current volume level: " .. tostring(percentage))
--    end)
local function get_volume(callback)
    awful.spawn.easy_async_with_shell(
        "amixer -D pulse get Master",
        function(out)
            local muted = string.find(out, "off")
            local volume = tonumber(string.match(out, "(%d?%d?%d)%%")) or 0
            callback(volume, muted ~= nil or muted == "off")
        end
    )
end

--- Set the volume in percentage
-- @tparam number value The value of the volume in percentage
-- @staticfct set_volume
-- @usage -- Set the volume to max
--    set_volume(100)
local function set_volume(value)
    awful.spawn("amixer -D pulse sset Master " .. tostring(value) .. "%")
end

--- Get a list of all audio sinks back (A sink is an audio player such as headphones, speakers or monitors)
-- @staticfct get_sinks
-- @usage -- Returns an iterable table containing all sinks
--    get_sinks() --  returns a list of sinks
local function get_sinks()
    return _extract_pa_ctl_state("sinks", "Sink #(.*)$", "Active Port: (.*)$", "Description: (.*)$")
end

--- Change the default sink (change the audio playback device)
-- @tparam number sink The sink property of our audio device
-- @staticfct set_default_sink
-- @usage -- Set our default sync to match the first device
--    set_default_sink(get_sinks()[1].sink)
local function set_default_sink(sink)
    if not (type(sink) == "number") then
        print("set_active_sink expects a number", err)
    end
    execute("pactl set-default-sink " .. sink)
end


--- Return only the default sink
-- @return table sink The currently active sink
-- @staticfct get_default_sink
-- @usage -- Get the default sink (the currently active audio device)
--    local sink = get_default_sink()
local function get_default_sink()
    local sinkID

    -- get all the sinks
    local sinks = get_sinks()

    -- find the sinkId of the default sync
    local out = split(execute("pactl info"), "\n")
    for _, line in ipairs(out) do
        local match = line:match("Default Sink: (.*)")
        if match ~= nil then
            sinkID = match
        end
    end

    -- loop over all sinks and find the default
    for _, sink in ipairs(sinks) do
        if sink.id == sinkID then
            return sink
        end
    end
    return {}
end

--- Get a list of all audio sources back (A source is a audio recording device such as microphones)
-- @staticfct get_sources
-- @usage -- Returns an iterable table containing all sources
--    get_sources() --  returns a list of sources
local function get_sources()
    return _extract_pa_ctl_state("sources", "Source #(.*)$", "Active Port: (.*)$", "Description: (.*)$")
end

--- Change the default source (change the audio playback device)
-- @tparam number source The sink property of our audio device
-- @staticfct set_default_source
-- @usage -- Set our default source to match the first device
--    set_default_source(get_sources()[1].sink)
local function set_default_source(source)
    if not (type(source) == "number") then
        print("set_active_source expects a number", err)
    end
    execute("pactl set-default-source " .. source)
end

--- Return only the default source
-- @return table source The currently active source
-- @staticfct get_default_source
-- @usage -- Get the default sink (the currently active microphone)
--    local source = get_default_source()
local function get_default_source()
    local sourceID

    -- get all the sinks
    local sources = get_sources()

    -- find the sinkId of the default sync
    local out = split(execute("pactl info"), "\n")
    for _, line in ipairs(out) do
        local match = line:match("Default Source: (.*)")
        if match ~= nil then
            sourceID = match
        end
    end

    -- loop over all sinks and find the default
    for _, source in ipairs(sources) do
        if source.id == sourceID then
            return source
        end
    end
    return {}
end


-- reset the pipewire server
local function _reset_pipewire()
    awful.spawn("systemctl --user restart pipewire")
end

-- reset the pulseaudio server
local function _reset_pulseaudio()
    awful.spawn("pulseaudio -k && pulseaudio --start")
end

--- Resets the active audio server (either pulseaudio or pipewire)
-- @staticfct reset_server
-- @usage -- Reset the entire audio server (temporarily breaks audio)
--    reset_server()
local function reset_server()
    local bIsPipewire = hardware.has_package_installed("pipewire")
    if bIsPipewire then
        _reset_pipewire()
    else
        _reset_pulseaudio()
    end
    print("Resetting audio server")
end

return {
    get_volume = get_volume,
    set_volume = set_volume,
    get_sinks = get_sinks,
    get_sources = get_sources,
    set_default_sink = set_default_sink,
    get_default_sink = get_default_sink,
    set_default_source = set_default_source,
    get_default_source = get_default_source,
    reset_server = reset_server
}
