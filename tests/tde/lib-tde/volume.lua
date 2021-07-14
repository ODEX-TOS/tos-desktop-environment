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
local volume = require("tde.lib-tde.volume")

function Test_api_lib_tde_volume_get_volume()
    assert(volume.get_volume, "Make sure the volume.get_volume api exists")
    assert(type(volume.get_volume) == "function", "Volume api is wrong, volume.get_volume should be a function")
end

function Test_api_lib_tde_volume_get_application_volume()
    assert(volume.get_application_volume, "Make sure the volume.get_application_volume api exists")
    assert(type(volume.get_application_volume) == "function", "Volume api is wrong, volume.get_application_volume should be a function")
end

function Test_api_lib_tde_volume_set_volume()
    assert(volume.set_volume, "Make sure the volume.set_volume api exists")
    assert(type(volume.set_volume) == "function", "Volume api is wrong, volume.set_volume should be a function")
end

function Test_api_lib_tde_volume_set_application_volume()
    assert(volume.set_application_volume, "Make sure the volume.set_application_volume api exists")
    assert(type(volume.set_application_volume) == "function", "Volume api is wrong, volume.set_application_volume should be a function")
end

function Test_api_lib_tde_volume_get_sinks()
    assert(volume.get_sinks, "Make sure the volume.get_sinks api exists")
    assert(type(volume.get_sinks) == "function", "Volume api is wrong, volume.get_sinks should be a function")
end

function Test_api_lib_tde_volume_get_sources()
    assert(volume.get_sources, "Make sure the volume.get_sources api exists")
    assert(type(volume.get_sources) == "function", "Volume api is wrong, volume.get_sources should be a function")
end

function Test_api_lib_tde_volume_get_applications()
    assert(volume.get_applications, "Make sure the volume.get_applications api exists")
    assert(type(volume.get_applications) == "function", "Volume api is wrong, volume.get_applications should be a function")
end

function Test_api_lib_tde_volume_set_default_sink()
    assert(volume.set_default_sink, "Make sure the volume.set_default_sink api exists")
    assert(type(volume.set_default_sink) == "function", "Volume api is wrong, volume.set_default_sink should be a function")
end

function Test_api_lib_tde_volume_get_default_sink()
    assert(volume.get_default_sink, "Make sure the volume.get_default_sink api exists")
    assert(type(volume.get_default_sink) == "function", "Volume api is wrong, volume.get_default_sink should be a function")
end

function Test_api_lib_tde_volume_set_default_source()
    assert(volume.set_default_source, "Make sure the volume.set_default_source api exists")
    assert(type(volume.set_default_source) == "function", "Volume api is wrong, volume.set_default_source should be a function")
end

function Test_api_lib_tde_volume_get_default_source()
    assert(volume.get_default_source, "Make sure the volume.get_default_source api exists")
    assert(type(volume.get_default_source) == "function", "Volume api is wrong, volume.get_default_source should be a function")
end

function Test_api_lib_tde_volume_reset_server()
    assert(volume.reset_server, "Make sure the volume.reset_server api exists")
    assert(type(volume.reset_server) == "function", "Volume api is wrong, volume.reset_server should be a function")
end

function Test_api_lib_tde_volume_inc_volume()
    assert(volume.inc_volume, "Make sure the volume.inc_volume api exists")
    assert(type(volume.inc_volume) == "function", "Volume api is wrong, volume.inc_volume should be a function")
end

function Test_api_lib_tde_volume_dec_volume()
    assert(volume.dec_volume, "Make sure the volume.dec_volume api exists")
    assert(type(volume.dec_volume) == "function", "Volume api is wrong, volume.dec_volume should be a function")
end

function Test_api_lib_tde_volume_set_muted_state()
    assert(volume.set_muted_state, "Make sure the volume.set_muted_state api exists")
    assert(type(volume.set_muted_state) == "function", "Volume api is wrong, volume.set_muted_state should be a function")
end

function Test_api_lib_tde_volume_toggle_master()
    assert(volume.toggle_master, "Make sure the volume.toggle_master api exists")
    assert(type(volume.toggle_master) == "function", "Volume api is wrong, volume.toggle_master should be a function")
end

function Test_api_lib_tde_volume_set_sink_port()
    assert(volume.set_sink_port, "Make sure the volume.set_sink_port api exists")
    assert(type(volume.set_sink_port) == "function", "Volume api is wrong, volume.set_sink_port should be a function")
end

function Test_api_lib_tde_volume_set_source_port()
    assert(volume.set_source_port, "Make sure the volume.set_source_port api exists")
    assert(type(volume.set_source_port) == "function", "Volume api is wrong, volume.set_source_port should be a function")
end

function Test_api_lib_tde_volume_set_mic_volume()
    assert(volume.set_mic_volume, "Make sure the volume.set_mic_volume api exists")
    assert(type(volume.set_mic_volume) == "function", "Volume api is wrong, volume.set_mic_volume should be a function")
end

function Test_api_lib_tde_volume_get_mic_volume()
    assert(volume.get_mic_volume, "Make sure the volume.get_mic_volume api exists")
    assert(type(volume.get_mic_volume) == "function", "Volume api is wrong, volume.get_mic_volume should be a function")
end

function Test_api_lib_tde_volume_set_mic_muted()
    assert(volume.set_mic_muted, "Make sure the volume.set_mic_muted api exists")
    assert(type(volume.set_mic_muted) == "function", "Volume api is wrong, volume.set_mic_muted should be a function")
end


function Test_api_lib_tde_volume_all_functions_tested()
    local amount = 21
    local length = tablelength(volume)
    assert(length == amount, "You didn't write unit tests for all api functions, tested: " .. tostring(amount) .. " but there are: " .. tostring(length) .. " api functions")
end

