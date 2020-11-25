local hardware = require("tde.lib-tde.hardware-check")
local run_rc_config_in_xephyr = require("tests.IT.functions").run_rc_config_in_xephyr

function Test_IT_run_application_startup()
    local config = os.getenv("PWD") .. "/tde/rc.lua"
    -- give it more time to start
    assert(run_rc_config_in_xephyr(config, 5))
end

function Test_IT_application_valid_syntax()
    assert(hardware.has_package_installed("awesome-tos"))
    -- check if the config contains syntax errors
    local _, ret = hardware.execute("awesome -k --config " .. os.getenv("PWD") .. "/tde/rc.lua")
    assert(ret == 0)
end

function Test_IT_topbar_exists()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/toppanel.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_action_menu_exists()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/action-menu.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_notification_center_exists()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/notification-center.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_bottom_panel_exists()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/bottom-bar.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_tag_switching_works()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/tags-switch.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_compositor_exists()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/compositor.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

-- TODO: test tiling modes
function Test_IT_tiling_mode_working()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/tiling.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 5)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

-- TODO: test floating mode
function Test_IT_floating_mode_working()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/floating.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 5)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_notification_working()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/notifications.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 7)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end

function Test_IT_settings_app_exists_working()
    local config = os.getenv("PWD") .. "/tests/IT/layout/rc/settings-app.lua"
    local assertion, match, stdout = run_rc_config_in_xephyr(config, 5)
    assert(assertion)
    print(stdout)
    print(tostring(match))
    assert(match)
end
