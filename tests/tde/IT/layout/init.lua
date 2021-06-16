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
local hardware = require("tde.lib-tde.hardware-check")
local run_rc_config_in_xephyr = require("tests.tde.IT.functions").run_rc_config_in_xephyr

function Test_IT_run_application_startup()
    local config = os.getenv("PWD") .. "/tde/rc.lua"
    -- give it more time to start
    assert(run_rc_config_in_xephyr(config, 5))
end

function Test_IT_application_valid_syntax()
    assert(hardware.has_package_installed("tde"))
    -- check if the config contains syntax errors
    local _, ret = hardware.execute("tde -k --config " .. os.getenv("PWD") .. "/tde/rc.lua")
    assert(ret == 0)
end

function Test_IT_topbar_exists()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/toppanel.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_action_menu_exists()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/action-menu.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_notification_center_exists()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/notification-center.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_bottom_panel_exists()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/bottom-bar.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_tag_switching_works()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/tags-switch.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_compositor_exists()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/compositor.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

-- TODO: test tiling modes
function Test_IT_tiling_mode_working()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/tiling.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 5)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

-- TODO: test floating mode
function Test_IT_floating_mode_working()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/floating.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 5)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_notification_working()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/notifications.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 7)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_settings_app_exists_working()
    local config = os.getenv("PWD") .. "/tests/tde/IT/layout/rc/settings-app.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 5)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end
