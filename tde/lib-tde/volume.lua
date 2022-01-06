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
local split = require("lib-tde.function.common").split
local signals = require("lib-tde.signals")

local err = "\27[0;31m[ ERROR "

-- The sink that is currently in use
local __active_sink = {name="", port=""}
local function _should_control_via_software()
    -- Check if we can find the sync in the hardware controls
    local _sink = _G.save_state.hardware_only_volume_controls[__active_sink.name]

    -- By default we control sound in software
    if _sink == nil then
        return true
    end

    print("Active sink")
    print(__active_sink)
    print("save state stored sink")
    print(_sink)

    -- Otherwise we check the user settings
    local ports = _sink.ports
    for _, port in ipairs(ports) do
        if port == __active_sink.port then
            _G.save_state.hardware_only_volume = _sink.hardware_only_volume
            return not _sink.hardware_only_volume
        end
    end

    _G.save_state.hardware_only_volume = false
    return true
end

local function _extract_pa_ctl_state(command, callback, id, port, description, hasID)
    awful.spawn.easy_async("pactl list " .. command, function (out)
        local res = split(out, "\n")
        local lastPort
        local lastSink
        local lastDescription
        local lastSinkId
        local a_ports = {}

        local result = {}
        local weak = {}
        weak.__mode = "k"
        setmetatable(result, weak)

        if (hasID == nil) then
            hasID = true
        end

        local function addTable()
            if lastSink == nil then
                return
            end

            local __res = {
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
                port = lastPort or "",
                --- The list of all ports this sink/source supports
                -- @property available_ports
                -- @param table
                available_ports = a_ports,
                --- The unique identifier for the sink
                -- @property id
                -- @param string
                id = lastSinkId
            }

            setmetatable(__res, weak)

            table.insert(result, __res)
            lastDescription = nil
            lastSink = nil
            lastPort = nil
            lastSinkId = nil
            a_ports = {}
        end

        -- we found the ports section
        -- now we loop until we found the next set_actions
        -- arr is the line delimited output of pactl list
        -- i is the index that the 'Ports:' section is found
        local function populate_ports(arr, i)
            i = i + 1
            while true do
                local line = arr[i]
                if line == nil then
                    break
                end

                local _port = line:match("%s*(.*): .* %(.*%)$")
                if _port ~= nil then
                    table.insert(a_ports, _port)
                else
                    break
                end
                i = i + 1
            end
        end

        for index, value in ipairs(res) do
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
                -- add the previous source/sink
                addTable()
                lastSink = sinkMatch
            end

            local sinkId = value:match("Name: (.*)$")
            if sinkId ~= nil and hasID then
                -- update to the new source/sink
                lastSinkId = sinkId
            end

            -- find all ports assigned to this source/sink
            local ports = value:match("Ports:$")
            if ports ~= nil then
                populate_ports(res, index)
            end


            if lastPort ~= nil and lastSink ~= nil and lastDescription ~= nil and not hasID then
                table.insert(result, {
                    name = lastDescription,
                    sink = tonumber(lastSink) or 0,
                    port = lastPort or "",
                    available_ports = a_ports
                })
                lastDescription = nil
                lastSink = nil
                lastPort = nil
                lastSinkId = nil
                a_ports = {}
            end
        end
        -- just in case we didn't update the last element
        addTable()
        callback(result)
    end)
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
        awful.spawn.easy_async("amixer -D pulse sset Master 5%+", function()
            signals.emit_volume_update()
        end)
    end
end

--- Decrease the current volume level by 5%
-- @staticfct dec_volume
-- @usage -- Decrease the current volume level
--    dec_volume()
local function dec_volume()
    if _should_control_via_software() then
        awful.spawn.easy_async("amixer -D pulse sset Master 5%-", function()
            signals.emit_volume_update()
        end)
    end
end

--- Toggle the current volume state between muted and unmuted on the master channel
-- @staticfct toggle_master
-- @usage -- Toggle the muted state
--    toggle_master()
local function toggle_master()
    if _should_control_via_software() then
        awful.spawn.easy_async("amixer -D pulse set Master 1+ toggle", function ()
            signals.emit_volume_update()
        end)
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
            awful.spawn("amixer -D pulse sset Master off", false)
        else
            awful.spawn("amixer -D pulse sset Master on", false)
        end
    else
        awful.spawn("amixer -D pulse sset Master on", false)
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
    awful.spawn("pactl set-sink-input-volume " .. tostring(sink) .. " " .. tostring(math.floor(value)) .. "%", false)
end

--- Set the volume in percentage
-- @tparam number value The value of the volume in percentage
-- @staticfct set_volume
-- @usage -- Set the volume to max
--    set_volume(100)
local function set_volume(value)
    if _should_control_via_software() then
        awful.spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ " .. tostring(math.floor(value)) .. "%", function ()
            signals.emit_volume_update()
        end)
    else
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ 100%", false)
    end
end

--- Get a list of all audio sinks back (A sink is an audio player such as headphones, speakers or monitors)
-- @tparam function callback The callback to call when the sinks have been fetched
-- @staticfct get_sinks
-- @usage -- Returns an iterable table containing all sinks
--    get_sinks() --  returns a list of sinks
local function get_sinks(callback)
    return _extract_pa_ctl_state("sinks", callback, "Sink #(.*)$", "Active Port: (.*)$", "Description: (.*)$")
end

--- Get a list of all applications that are currently playing audio
-- @tparam function callback The callback to call when the applications have been fetched
-- @staticfct get_applications
-- @usage -- Returns an iterable table containing all applications playing audio
--    get_applications() --  returns a list of application
local function get_applications(callback)
    return _extract_pa_ctl_state("sink-inputs", callback, "Sink Input #(.*)$", 'media.name = "(.*)"$', 'application.name = "(.*)"$', false)
end


--- Change the default sink (change the audio playback device)
-- @tparam number sink The sink property of our audio device
-- @staticfct set_default_sink
-- @usage -- Set our default sync to match the first device
--    set_default_sink(get_sinks()[1])
local function set_default_sink(sink)
    if not (type(sink.sink) == "number") then
        print("set_active_sink expects a number", err)
    end

    __active_sink = sink
    awful.spawn("pactl set-default-sink " .. sink.sink, false)
end


--- Return only the default sink
-- @tparam function callback The callback to call when the default sink have been fetched
-- @return table sink The currently active sink
-- @staticfct get_default_sink
-- @usage -- Get the default sink (the currently active audio device)
--    local sink = get_default_sink()
local function get_default_sink(callback)
    get_sinks(function(sinks)
        local sinkID

        -- find the sinkId of the default sync
        awful.spawn.easy_async("pactl info", function (out)
            out = split(out, "\n")
            for _, line in ipairs(out) do
                local match = line:match("Default Sink: (.*)")
                if match ~= nil then
                    sinkID = match
                end
            end

            -- loop over all sinks and find the default
            for _, sink in ipairs(sinks) do
                if sink.id == sinkID then
                    __active_sink = sink
                    callback(sink, sinks)
                    return
                end
            end
            callback({}, sinks)
        end)
    end)
end

--- Change the sink (change the audio playback device) port
-- @tparam number sink The sink property of our audio device
-- @tparam string port The Specific port to enable in the sink
-- @staticfct set_sink_port
-- @usage -- Set our sink to match the first device and the first port of the device
--    set_sink_port(get_sinks()[1], get_sinks()[1].ports[1])
local function set_sink_port(sink, port)
    if not (type(sink.sink) == "number") then
        print("set_default_sink_port expects a sink number", err)
    end
    if not (type(port) == "string") then
        print("set_default_sink_port expects a port string", err)
    end

    __active_sink = sink
    awful.spawn("pactl set-sink-port " .. sink.sink .. ' ' .. port, false)
end

--- Get a list of all audio sources back (A source is an audio recording device such as microphones)
-- @tparam function callback The callback to call when the sources have been fetched
-- @staticfct get_sources
-- @usage -- Returns an iterable table containing all sources
--    get_sources() --  returns a list of sources
local function get_sources(callback)
    return _extract_pa_ctl_state("sources", callback, "Source #(.*)$", "Active Port: (.*)$", "Description: (.*)$")
end

--- Change the default source (change the audio playback device)
-- @tparam number source The sink property of our audio device
-- @staticfct set_default_source
-- @usage -- Set our default source to match the first device
--    set_default_source(get_sources()[1])
local function set_default_source(source)
    if not (type(source.sink) == "number") then
        print("set_active_source expects a number", err)
    end
    awful.spawn("pactl set-default-source " .. source.sink, false)
end

--- Return only the default source
-- @tparam function callback The callback to call when the default source have been fetched
-- @return table source The currently active source
-- @staticfct get_default_source
-- @usage -- Get the default sink (the currently active microphone)
--    local source = get_default_source()
local function get_default_source(callback)
    -- get all the sinks
    get_sources(function(sources)
        local sourceID

        -- find the sinkId of the default sync
        awful.spawn.easy_async("pactl info", function (out)
            out = split(out, "\n")
            for _, line in ipairs(out) do
                local match = line:match("Default Source: (.*)")
                if match ~= nil then
                    sourceID = match
                end
            end

            -- loop over all sinks and find the default
            for _, source in ipairs(sources) do
                if source.id == sourceID then
                    callback(source, sources)
                    return
                end
            end
            callback({}, sources)
        end)
    end)
end

--- Change the source (change the audio input device) port
-- @tparam number source The source property of our audio device
-- @tparam string port The Specific port to enable in the source
-- @staticfct set_source_port
-- @usage -- Set our source to match the first device and the first port of the device
--    set_source_port(get_sources()[1], get_sources()[1].ports[1])
local function set_source_port(source, port)
    if not (type(source.sink) == "number") then
        print("set_default_source_port expects a source number", err)
    end
    if not (type(port) == "string") then
        print("set_default_source_port expects a port string", err)
    end
    awful.spawn("pactl set-source-port " .. source.sink .. ' ' .. port, false)
end


-- reset the pipewire server
local function _reset_pipewire()
    awful.spawn("systemctl --user restart pipewire", false)
end

-- reset the pulseaudio server
local function _reset_pulseaudio()
    awful.spawn("pulseaudio -k && pulseaudio --start", false)
end

--- Resets the active audio server (either pulseaudio or pipewire)
-- @staticfct reset_server
-- @usage -- Reset the entire audio server (temporarily breaks audio)
--    reset_server()
local function reset_server()
    hardware.has_package_installed("pipewire", function(bIsPipewire)
        if bIsPipewire then
            _reset_pipewire()
        else
            _reset_pulseaudio()
        end
        print("Resetting audio server")
    end)
end

--- Change the microphone state
-- @tparam boolean bIsMuted If the microphone is enabled or not
-- @staticfct set_mic_muted
-- @usage -- Turn off the microphone
--    set_mic_muted(true)
local function set_mic_muted(bIsMuted)
    if type(bIsMuted) ~= "boolean" then
        print("set_mic_muted expects a boolean", err)
        return
    end

    if bIsMuted then
        awful.spawn("amixer set Capture nocap", false)
    else
        awful.spawn("amixer set Capture cap", false)
    end
end

--- Change the microphone volume
-- @tparam number volume The volume of the microphone (between 0 and 100%)
-- @staticfct set_mic_volume
-- @usage -- Set the microphone volume to 100% (Max volume)
--    set_mic_volume(100)
local function set_mic_volume(volume)
    if type(volume) ~= "number" then
        print("set_mic_volume expects a number", err)
        return
    end

    if volume < 0 then
        volume = 0
    end
    if volume > 100 then
        volume = 100
    end
    -- unmute the mic
    set_mic_muted(false)

    local cmd = "amixer set Capture " .. tostring(math.floor(volume)) .. '%'
    print(cmd)

    awful.spawn(cmd, false)
end

--- Get the microphone volume asynchronously
-- @tparam function callback A callback function to trigger when the microphone volume is gathered
-- @staticfct get_mic_volume
-- @usage -- Get the microphone volume in percentage
--    get_mic_volume(function(percentage, muted)
--        print("Current microphone volume level: " .. tostring(percentage))
--    end)
local function get_mic_volume(callback)
    awful.spawn.easy_async_with_shell(
        "amixer get Capture",
        function(out)
            local muted = string.find(out, "off")
            local volume = tonumber(string.match(out, "(%d?%d?%d)%%")) or 0
            callback(volume, muted ~= nil or muted == "off")
        end
    )
end

get_default_sink(function(sink)
    __active_sink.name = sink.name
    __active_sink.port = sink.port
    _should_control_via_software()
end)

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
    set_sink_port = set_sink_port,
    set_source_port = set_source_port,
    set_mic_volume = set_mic_volume,
    get_mic_volume = get_mic_volume,
    set_mic_muted = set_mic_muted,
    reset_server = reset_server
}