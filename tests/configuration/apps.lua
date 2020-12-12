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
    assert(apps.default.terminal)
end

function test_configuration_app_editor()
    assert(apps.default.editor)
end

function test_configuration_app_web_browser()
    assert(apps.default.web_browser)
end

function test_configuration_app_file_manager()
    assert(apps.default.file_manager)
end

function test_configuration_app_rofi()
    assert(apps.default.rofi)
end

function test_configuration_app_web()
    assert(apps.default.web)
end

function test_configuration_app_rofiappmenu()
    assert(apps.default.rofiappmenu)
end

function test_configuration_app_rofiemojimenu()
    assert(apps.default.rofiemojimenu)
end

function test_configuration_app_rofiwindowswitch()
    assert(apps.default.rofiwindowswitch)
end

function test_configuration_app_roficlipboard()
    assert(apps.default.roficlipboard)
end

function test_configuration_app_rofidpimenu()
    assert(apps.default.rofidpimenu)
end

function test_configuration_app_rofiwifimenu()
    assert(apps.default.rofiwifimenu)
end

function test_configuration_app_lock()
    assert(apps.default.lock)
end

function test_configuration_app_quake()
    assert(apps.default.quake)
end

function test_configuration_app_duplicate_screens()
    assert(apps.default.duplicate_screens)
end

function test_configuration_app_run_on_start_up()
    assert(type(apps.run_on_start_up) == "table")
    assert(#apps.run_on_start_up > 1)
    assert(type(apps.run_on_start_up[1]) == "string")
end

function test_configuration_app_bins()
    assert(type(apps.bins) == "table")
    assert(apps.bins.coverUpdate)
    assert(apps.bins.full_screenshot)
    assert(apps.bins.area_screenshot)
    assert(apps.bins.window_screenshot)
    assert(apps.bins.window_blank_screenshot)
end
