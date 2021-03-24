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
-- Useful functional for setting volume active sinks, input/output etc
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdemod lib-tde.volume
-----------------
local hardware = require("lib-tde.hardware-check")
local execute = hardware.execute
local split = require("lib-tde.function.common").split

local err = "\27[0;31m[ ERROR "

local function _should_control_via_software()
    return not (general["disable_software_volume_control"] == "1")
end

local function _extract_pa_ctl_state(command, id, port, description, hasID)
    local res = split(execute("pactl list " .. command), "\n")
    local lastPort
    local lastSink
    local lastDescription
    local lastSinkId

    local result = {}

    if(hasID == nil) then
        hasID = true
    end

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
        if sinkId ~= nil and hasID then
            lastSinkId = sinkId
        end


        if lastSink ~= nil and lastDescription ~= nil and lastSinkId ~= nil then
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

        if lastPort ~= nil and lastSink ~= nil and lastDescription ~= nil and not hasID then
            table.insert(result, {
                name = lastDescription,
                sink = tonumber(lastSink) or 0,
                port = lastPort,
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

--- Increase the current volume level by 5%
-- @staticfct inc_volume
-- @usage -- Increase the current volume level
--    inc_volume()
local function inc_volume()
    if _should_control_via_software() then
        awful.spawn("amixer -D pulse sset Master 5%+")
    end
end

--- Decrease the current volume level by 5%
-- @staticfct dec_volume
-- @usage -- Decrease the current volume level
--    dec_volume()
local function dec_volume()
    if _should_control_via_software() then
        awful.spawn("amixer -D pulse sset Master 5%-")
    end
end

--- Toggle the current volume state between muted and unmuted on the master channel
-- @staticfct toggle_master
-- @usage -- Toggle the muted state
--    toggle_master()
local function toggle_master()
    if _should_control_via_software() then
        awful.spawn("amixer -D pulse set Master 1+ toggle")
    end
end

--- Set the muted state
-- @tparam boolean bIsMuted The state that we need to set (true if we need to mute the output)
-- @staticfct set_muted_state
-- @usage -- Set the master channel to mute
--   set_muted_state(true)
local function set_muted_state(bIsMuted)
    if _should_control_via_software() then
        if bIsMuted then
            awful.spawn("amixer -D pulse sset Master off")
        else
            awful.spawn("amixer -D pulse sset Master on")
        end
    else
        awful.spawn("amixer -D pulse sset Master on")
    end
end

--- Get the volume of an application asynchronously
-- @tparam number sink The sink property of the application
-- @tparam function callback A callback function to trigger when the volume data is gathered
-- @staticfct get_application_volume
-- @usage -- Get the volume of sink number 10
--    get_application_volume(10,function(percentage, muted)
--        print("Current volume level of application" .. sink.name ..": " .. tostring(percentage))
--    end)
local function get_application_volume(sink, callback)
   -- TODO: get the input state from pactl list
   awful.spawn.easy_async_with_shell(
       "pactl list sink-inputs",
       function (out)
           local splitted = split(out, "\n")
           local is_in_sink = false
           for _, value in ipairs(splitted) do
                if value:match("Sink Input #" .. tostring(sink)) ~= nil then
                    is_in_sink=true
                end

                if is_in_sink and value:match("Volume: .*$") ~= nil then
                    local volume = value:match("Volume: .* (%d+)%% / .*$")
                    callback(tonumber(volume) or 0)
                    return
                end
           end
       end
   )
end

--- Set the volume of an application in percentage
-- @tparam number sink The sink of a given application
-- @tparam number value The value of the volume in percentage
-- @staticfct set_volume
-- @usage -- Set the volume to max (of application with sink #75)
--    set_volume(75, 100)
local function set_application_volume(sink, value)
    execute("pactl set-sink-input-volume " .. tostring(sink) .. " " .. tostring(math.floor(value)) .. "%")
end

--- Set the volume in percentage
-- @tparam number value The value of the volume in percentage
-- @staticfct set_volume
-- @usage -- Set the volume to max
--    set_volume(100)
local function set_volume(value)
    if _should_control_via_software() then
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ " .. tostring(math.floor(value)) .. "%")
    else
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ 100%")
    end
end

--- Get a list of all audio sinks back (A sink is an audio player such as headphones, speakers or monitors)
-- @staticfct get_sinks
-- @usage -- Returns an iterable table containing all sinks
--    get_sinks() --  returns a list of sinks
local function get_sinks()
    return _extract_pa_ctl_state("sinks", "Sink #(.*)$", "Active Port: (.*)$", "Description: (.*)$")
end

--- Get a list of all applications that are currently playing audio
-- @staticfct get_applications
-- @usage -- Returns an iterable table containing all applications playing audio
--    get_applications() --  returns a list of application
local function get_applications()
    return _extract_pa_ctl_state("sink-inputs", "Sink Input #(.*)$", 'media.name = "(.*)"$', 'application.name = "(.*)"$', false)
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

--- Get a list of all audio sources back (A source is an audio recording device such as microphones)
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
    inc_volume = inc_volume,
    dec_volume = dec_volume,
    set_muted_state = set_muted_state,
    toggle_master = toggle_master,
    get_application_volume = get_application_volume,
    set_volume = set_volume,
    set_application_volume = set_application_volume,
    get_sinks = get_sinks,
    get_sources = get_sources,
    get_applications = get_applications,
    set_default_sink = set_default_sink,
    get_default_sink = get_default_sink,
    set_default_source = set_default_source,
    get_default_source = get_default_source,
    reset_server = reset_server
}