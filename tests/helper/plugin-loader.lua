-- the plugins table is used by plugin_loader to load plugins dynamically
-- We use a global plugin table to only load it once instead of each time plugin_loader is called

echo = print

function test_loader()
    local plugin_loader = require("tde.helper.plugin-loader")
    assert(plugin_loader)
    print = echo
end

function test_loader_section_test()
    plugins = {
        test_1 = "mock-plugin"
    }
    local plugin_loader = require("tde.helper.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table")
    assert(#result == 0)
    print = echo
end

function test_loader_section_mock_test()
    plugins = {
        test_1 = "widget.mock-plugin"
    }
    local plugin_loader = require("tde.helper.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table")
    assert(#result == 1)
    assert(result[1] == require("widget.mock-plugin"))
    print = echo
end

function test_loader_section_multi_plugin()
    plugins = {
        test_1 = "widget.mock-plugin",
        test_2 = "widget.mock-plugin",
        test_3 = "widget.mock-plugin"
    }
    local plugin_loader = require("tde.helper.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table")
    assert(#result == 3)

    local mock = require("widget.mock-plugin")
    assert(result[1] == mock)
    assert(result[2] == mock)
    assert(result[3] == mock)

    print = echo
end

function test_loader_section_multi_plugin()
    plugins = {
        test_1 = "widget.mock-plugin",
        mock_1 = "widget.mock-plugin"
    }
    local plugin_loader = require("tde.helper.plugin-loader")
    local result = plugin_loader("test")
    local resultMock = plugin_loader("mock")

    assert(type(result) == "table")
    assert(#result == 1)

    assert(type(resultMock) == "table")
    assert(#resultMock == 1)

    local mock = require("widget.mock-plugin")
    assert(result[1] == mock)
    assert(resultMock[1] == mock)

    print = echo
end

function test_loader_section_multi_multi_plugin()
    plugins = {
        test_1 = "widget.mock-plugin",
        test_2 = "widget.mock-plugin",
        mock_1 = "widget.mock-plugin",
        mock_2 = "widget.mock-plugin"
    }

    local plugin_loader = require("tde.helper.plugin-loader")
    local result = plugin_loader("test")
    local resultMock = plugin_loader("mock")

    assert(type(result) == "table")
    assert(#result == 2)

    assert(type(resultMock) == "table")
    assert(#resultMock == 2)

    local mock = require("widget.mock-plugin")
    assert(result[1] == mock)
    assert(result[2] == mock)

    assert(resultMock[1] == mock)
    assert(resultMock[2] == mock)

    print = echo
end

function test_loader_section_inconsistent_flow_state()
    plugins = {
        test_1 = "widget.mock-plugin",
        test_2 = "widget.mock-plugin",
        test_3 = "widget.mock-plugin",
        test_5 = "widget.mock-plugin"
    }
    local plugin_loader = require("tde.helper.plugin-loader")
    local result = plugin_loader("test")
    assert(type(result) == "table")
    assert(#result == 3)

    local mock = require("widget.mock-plugin")
    assert(result[1] == mock)
    assert(result[2] == mock)
    assert(result[3] == mock)
    assert(result[5] == nil)
    assert(type(plugins["test_5"]) == "string")

    print = echo
end
