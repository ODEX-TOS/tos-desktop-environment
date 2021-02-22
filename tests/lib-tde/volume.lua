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

function test_api_lib_tde_volume_get_volume()
    assert(volume.get_volume, "Make sure the volume.get_volume api exists")
    assert(type(volume.get_volume) == "function", "Volume api is wrong, volume.get_volume should be a function")
end

function test_api_lib_tde_volume_set_volume()
    assert(volume.set_volume, "Make sure the volume.set_volume api exists")
    assert(type(volume.set_volume) == "function", "Volume api is wrong, volume.set_volume should be a function")
end

function test_api_lib_tde_volume_get_sinks()
    assert(volume.get_sinks, "Make sure the volume.get_sinks api exists")
    assert(type(volume.get_sinks) == "function", "Volume api is wrong, volume.get_sinks should be a function")
end

function test_api_lib_tde_volume_get_sources()
    assert(volume.get_sources, "Make sure the volume.get_sources api exists")
    assert(type(volume.get_sources) == "function", "Volume api is wrong, volume.get_sources should be a function")
end

function test_api_lib_tde_volume_set_default_sink()
    assert(volume.set_default_sink, "Make sure the volume.set_default_sink api exists")
    assert(type(volume.set_default_sink) == "function", "Volume api is wrong, volume.set_default_sink should be a function")
end

function test_api_lib_tde_volume_get_default_sink()
    assert(volume.get_default_sink, "Make sure the volume.get_default_sink api exists")
    assert(type(volume.get_default_sink) == "function", "Volume api is wrong, volume.get_default_sink should be a function")
end

function test_api_lib_tde_volume_set_default_source()
    assert(volume.set_default_source, "Make sure the volume.set_default_source api exists")
    assert(type(volume.set_default_source) == "function", "Volume api is wrong, volume.set_default_source should be a function")
end

function test_api_lib_tde_volume_get_default_source()
    assert(volume.get_default_source, "Make sure the volume.get_default_source api exists")
    assert(type(volume.get_default_source) == "function", "Volume api is wrong, volume.get_default_source should be a function")
end

function test_api_lib_tde_volume_reset_server()
    assert(volume.reset_server, "Make sure the volume.reset_server api exists")
    assert(type(volume.reset_server) == "function", "Volume api is wrong, volume.reset_server should be a function")
end

