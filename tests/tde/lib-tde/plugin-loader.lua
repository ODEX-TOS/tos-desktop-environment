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
-- the plugins table is used by plugin_loader to load plugins dynamically
-- We use a global plugin table to only load it once instead of each time plugin_loader is called

echo = print

local function create_plugin(name, section)
    return {
        __name = name,
        name = name,
        active = true,
        metadata = {
            type = section
        }
    }
end

function Test_loader()
    local plugin_loader = require("tde.lib-tde.plugin-loader")
    assert(plugin_loader, "Make sure that the plugin loader exists")
    print = echo
end

function Test_loader_section_test()
    _G.save_state.plugins = {}
    _G.save_state.plugins["mock-plugin"] = create_plugin("mock-plugin", "test")

    local plugin_loader = require("tde.lib-tde.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table", "The plugin loader should return a table of plugins")
    assert(#result == 0, "The plugin loader should return 0 plugins")
    print = echo
end

function Test_loader_section_mock_test()
    _G.save_state.plugins = {}
    _G.save_state.plugins["widget.mock-plugin"] = create_plugin("widget.mock-plugin", "test")

    local plugin_loader = require("tde.lib-tde.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table", "The plugin loader should return a table of plugins")
    assert(#result == 1, "The plugin loader should return 1 plugin")
    assert(result[1].plugin == require("widget.mock-plugin"), "The plugin loader should return 1 plugin")
    assert(result[1].__plugin_name == "mock_plugin", "The plugin loader should return 1 plugin")

    print = echo
end

function Test_loader_section_multi_plugin()
    _G.save_state.plugins = {}
    _G.save_state.plugins["widget.mock-plugin"] = create_plugin("widget.mock-plugin", "test")
    _G.save_state.plugins["widget.mock-plugin2"] = create_plugin("widget.mock-plugin", "test")
    _G.save_state.plugins["widget.mock-plugin3"] = create_plugin("widget.mock-plugin", "test")

    local plugin_loader = require("tde.lib-tde.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table", "The plugin loader should return a table of plugins")
    assert(#result == 3, "The plugin loader should return 3 plugins")

    local mock = require("widget.mock-plugin")
    assert(result[1].plugin == mock, "The first plugin in the table should be the mock plugin")
    assert(result[2].plugin == mock, "The second plugin in the table should be the mock plugin")
    assert(result[3].plugin == mock, "The third plugin in the table should be the mock plugin")

    print = echo
end

function Test_loader_section_multi_plugin2()
    _G.save_state.plugins = {}
    _G.save_state.plugins["widget.mock-plugin"] = create_plugin("widget.mock-plugin", "test")
    _G.save_state.plugins["widget.mock-plugin2"] = create_plugin("widget.mock-plugin", "test")
    _G.save_state.plugins["widget.mock-plugin3"] = create_plugin("widget.mock-plugin", "mock")

    local plugin_loader = require("tde.lib-tde.plugin-loader")
    local result = plugin_loader("test")
    local resultMock = plugin_loader("mock")

    assert(type(result) == "table", "The plugin loader should return a table of plugins")
    assert(#result == 2, "The plugin loader should return 1 plugin")

    assert(type(resultMock) == "table", "The plugin loader should return a table of plugins")
    assert(#resultMock == 1, "The plugin loader should return 1 plugin")

    local mock = require("widget.mock-plugin")
    assert(result[1].plugin == mock, "The first plugin in the table should be the mock plugin")
    assert(resultMock[1].plugin == mock, "The first plugin in the table should be the mock plugin")

    print = echo
end

function Test_loader_section_multi_multi_plugin()
    _G.save_state.plugins = {}
    _G.save_state.plugins["widget.mock-plugin"] = create_plugin("widget.mock-plugin", "test")
    _G.save_state.plugins["widget.mock-plugin2"] = create_plugin("widget.mock-plugin", "test")

    _G.save_state.plugins["widget.mock-plugin3"] = create_plugin("widget.mock-plugin", "mock")
    _G.save_state.plugins["widget.mock-plugin4"] = create_plugin("widget.mock-plugin", "mock")

    local plugin_loader = require("tde.lib-tde.plugin-loader")
    local result = plugin_loader("test")
    local resultMock = plugin_loader("mock")

    assert(type(result) == "table", "The plugin loader should return a table of plugins")
    assert(#result == 2, "The plugin loader should return 2 plugins")

    assert(type(resultMock) == "table", "The plugin loader should return a table of plugins")
    assert(#resultMock == 2, "The plugin loader should return 2 plugins")

    local mock = require("widget.mock-plugin")
    assert(result[1].plugin == mock, "The first plugin in the table should be the mock plugin")
    assert(result[2].plugin == mock, "The second plugin in the table should be the mock plugin")

    assert(resultMock[1].plugin == mock, "The first plugin in the table should be the mock plugin")
    assert(resultMock[2].plugin == mock, "The second plugin in the table should be the mock plugin")

    print = echo
end

function Test_loader_section_inconsistent_flow_state()
    _G.save_state.plugins = {}
    _G.save_state.plugins["widget.mock-plugin"] = create_plugin("widget.mock-plugin", "test")
    _G.save_state.plugins["widget.mock-plugin2"] = create_plugin("widget.mock-plugin", "test")
    _G.save_state.plugins["widget.mock-plugin3"] = create_plugin("widget.mock-plugin", "test")

    local plugin_loader = require("tde.lib-tde.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table", "The plugin loader should return a table of plugins")
    assert(#result == 3, "The plugin loader should return 3 plugins but got: " .. tostring(#result))

    local mock = require("widget.mock-plugin")
    assert(result[1].plugin == mock, "The first plugin in the table should be the mock plugin")
    assert(result[2].plugin == mock, "The second plugin in the table should be the mock plugin")
    assert(result[3].plugin == mock, "The third plugin in the table should be the mock plugin")
    assert(result[5] == nil, "The fifth plugin shouldn't exist")

    print = echo
end
