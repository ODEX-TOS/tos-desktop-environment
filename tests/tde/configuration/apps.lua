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
local apps = require("tde.configuration.apps")

function test_configuration_app_terminal()
    assert(apps.default.terminal, "Make sure apps.default.terminal exists")
end

function test_configuration_app_editor()
    assert(apps.default.editor, "Make sure apps.default.editor exists")
end

function test_configuration_app_web_browser()
    assert(apps.default.web_browser, "Make sure apps.default.web_browser exists")
end

function test_configuration_app_file_manager()
    assert(apps.default.file_manager, "Make sure apps.default.file_manager exists")
end

function test_configuration_app_rofi()
    assert(apps.default.rofi, "Make sure apps.default.rofi exists")
end

function test_configuration_app_web()
    assert(apps.default.web, "Make sure apps.default.web exists")
end

function test_configuration_app_rofiappmenu()
    assert(apps.default.rofiappmenu, "Make sure apps.default.rofiappmenu exists")
end

function test_configuration_app_rofiemojimenu()
    assert(apps.default.rofiemojimenu, "Make sure apps.default.rofiemojimenu exists")
end

function test_configuration_app_rofiwindowswitch()
    assert(apps.default.rofiwindowswitch, "Make sure apps.default.rofiwindowswitch exists")
end

function test_configuration_app_roficlipboard()
    assert(apps.default.roficlipboard, "Make sure apps.default.roficlipboard exists")
end

function test_configuration_app_rofidpimenu()
    assert(apps.default.rofidpimenu, "Make sure apps.default.rofidpimenu exists")
end

function test_configuration_app_rofiwifimenu()
    assert(apps.default.rofiwifimenu, "Make sure apps.default.rofiwifimenu exists")
end

function test_configuration_app_lock()
    assert(apps.default.lock, "Make sure apps.default.lock exists")
end

function test_configuration_app_quake()
    assert(apps.default.quake, "Make sure apps.default.quake exists")
end

function test_configuration_app_duplicate_screens()
    assert(apps.default.duplicate_screens, "Make sure apps.default.duplicate_screens exists")
end

function test_configuration_app_run_on_start_up()
    assert(type(apps.run_on_start_up) == "table", "apps.run_on_start_up should be a table of strings")
    assert(#apps.run_on_start_up > 1, "Starup apps during boot should be bigger than 1")
    assert(type(apps.run_on_start_up[1]) == "string", "The type of startup apps should be strings (commands)")
end

function test_configuration_app_bins()
    assert(type(apps.bins) == "function", "apps.bins should be a function")
    assert(type(apps.bins()) == "table", "apps.bins() should be a return a table")

    assert(apps.bins().coverUpdate, "Make sure apps.bins.coverUpdate exists")
    assert(apps.bins().full_screenshot, "Make sure apps.bins.full_screenshot exists")
    assert(apps.bins().full_blank_screenshot, "Make sure apps.bins.full_blank_screenshot exists")
    assert(apps.bins().area_screenshot, "Make sure apps.bins.area_screenshot exists")
    assert(apps.bins().area_blank_screenshot, "Make sure apps.bins.area_blank_screenshot exists")
    assert(apps.bins().window_screenshot, "Make sure apps.bins.window_screenshot exists")
    assert(apps.bins().window_blank_screenshot, "Make sure apps.bins.window_blank_screenshot exists")
end

function test_apps_api_unit_tested()
    local amount_default = 15
    local result_default = tablelength(apps.default)
    assert(
        result_default == amount_default,
        "You didn't test all app api endpoints, please add them then update the amount to: " .. result_default
    )

    local amount_startup = 3
    local result_startup = tablelength(apps.run_on_start_up)
    assert(
        result_startup == amount_startup,
        "You didn't test all app api endpoints, please add them then update the amount to: " .. result_startup
    )

    local amount_bin = 7
    local result_bin = tablelength(apps.bins())
    assert(
        result_bin == amount_bin,
        "You didn't test all app api endpoints, please add them then update the amount to: " .. result_bin
    )
end
