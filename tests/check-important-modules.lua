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
local exists = require("tde.lib-tde.file").exists

-- This file checks to make sure the most important files are intact
-- It ignores a lot of fancy feature files such as a lot of widgets

function test_configuration_mod_key_tde_layout_init_lua()
    assert(exists("tde/layout/init.lua"), "Check that tde/layout/init.lua exists")
end

function test_configuration_mod_key_tde_layout_right_panel_action_bar_lua()
    assert(exists("tde/layout/right-panel/action-bar.lua"), "Check that tde/layout/right-panel/action-bar.lua exists")
end

function test_configuration_mod_key_tde_layout_right_panel_init_lua()
    assert(exists("tde/layout/right-panel/init.lua"), "Check that tde/layout/right-panel/init.lua exists")
end

function test_configuration_mod_key_tde_layout_top_panel_lua()
    assert(exists("tde/layout/top-panel.lua"), "Check that tde/layout/top-panel.lua exists")
end

function test_configuration_mod_key_tde_layout_bottom_panel_action_bar_lua()
    assert(exists("tde/layout/bottom-panel/action-bar.lua"), "Check that tde/layout/bottom-panel/action-bar.lua exists")
end

function test_configuration_mod_key_tde_layout_bottom_panel_init_lua()
    assert(exists("tde/layout/bottom-panel/init.lua"), "Check that tde/layout/bottom-panel/init.lua exists")
end

function test_configuration_mod_key_tde_layout_left_panel_action_bar_lua()
    assert(exists("tde/layout/left-panel/action-bar.lua"), "Check that tde/layout/left-panel/action-bar.lua exists")
end

function test_configuration_mod_key_tde_layout_left_panel_init_lua()
    assert(exists("tde/layout/left-panel/init.lua"), "Check that tde/layout/left-panel/init.lua exists")
end

function test_configuration_mod_key_tde_rc_lua()
    assert(exists("tde/rc.lua"), "Check that tde/rc.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_xrandr_lua()
    assert(exists("tde/lib-tde/xrandr.lua"), "Check that tde/lib-tde/xrandr.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_sentry_init_lua()
    assert(exists("tde/lib-tde/sentry/init.lua"), "Check that tde/lib-tde/sentry/init.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_file_lua()
    assert(exists("tde/lib-tde/file.lua"), "Check that tde/lib-tde/file.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_plugin_loader_lua()
    assert(exists("tde/lib-tde/plugin-loader.lua"), "Check that tde/lib-tde/plugin-loader.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_sound_lua()
    assert(exists("tde/lib-tde/sound.lua"), "Check that tde/lib-tde/sound.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_errors_lua()
    assert(exists("tde/lib-tde/errors.lua"), "Check that tde/lib-tde/errors.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_hardware_check_lua()
    assert(exists("tde/lib-tde/hardware-check.lua"), "Check that tde/lib-tde/hardware-check.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_logger_lua()
    assert(exists("tde/lib-tde/logger.lua"), "Check that tde/lib-tde/logger.lua exists")
end

function test_configuration_mod_key_tde_lib_tde_luapath_lua()
    assert(exists("tde/lib-tde/luapath.lua"), "Check that tde/lib-tde/luapath.lua exists")
end

function test_configuration_mod_key_tde_parser_lua()
    assert(exists("tde/parser.lua"), "Check that tde/parser.lua exists")
end

function test_configuration_mod_key_tde_module_menu_lua()
    assert(exists("tde/module/menu.lua"), "Check that tde/module/menu.lua exists")
end

function test_configuration_mod_key_tde_module_plugin_module_lua()
    assert(exists("tde/module/plugin-module.lua"), "Check that tde/module/plugin-module.lua exists")
end

function test_configuration_mod_key_tde_module_exit_screen_lua()
    assert(exists("tde/module/exit-screen.lua"), "Check that tde/module/exit-screen.lua exists")
end

function test_configuration_mod_key_tde_module_notifications_lua()
    assert(exists("tde/module/notifications.lua"), "Check that tde/module/notifications.lua exists")
end

function test_configuration_mod_key_tde_module_battery_notifier_lua()
    assert(exists("tde/module/battery-notifier.lua"), "Check that tde/module/battery-notifier.lua exists")
end

function test_configuration_mod_key_tde_module_auto_start_lua()
    assert(exists("tde/module/auto-start.lua"), "Check that tde/module/auto-start.lua exists")
end

function test_configuration_mod_key_tde_module_titlebar_init_lua()
    assert(exists("tde/module/titlebar/init.lua"), "Check that tde/module/titlebar/init.lua exists")
end

function test_configuration_mod_key_tde_configuration_apps_lua()
    assert(exists("tde/configuration/apps.lua"), "Check that tde/configuration/apps.lua exists")
end

function test_configuration_mod_key_tde_configuration_tags_init_lua()
    assert(exists("tde/configuration/tags/init.lua"), "Check that tde/configuration/tags/init.lua exists")
end

function test_configuration_mod_key_tde_configuration_keys_global_lua()
    assert(exists("tde/configuration/keys/global.lua"), "Check that tde/configuration/keys/global.lua exists")
end

function test_configuration_mod_key_tde_configuration_client_rules_lua()
    assert(exists("tde/configuration/client/rules.lua"), "Check that tde/configuration/client/rules.lua exists")
end

function test_configuration_mod_key_tde_configuration_client_keys_lua()
    assert(exists("tde/configuration/client/keys.lua"), "Check that tde/configuration/client/keys.lua exists")
end

function test_configuration_mod_key_tde_theme_default_theme_lua()
    assert(exists("tde/theme/default-theme.lua"), "Check that tde/theme/default-theme.lua exists")
end

function test_configuration_mod_key_tde_theme_icons_dark_light_lua()
    assert(exists("tde/theme/icons/dark-light.lua"), "Check that tde/theme/icons/dark-light.lua exists")
end

function test_configuration_mod_key_tde_widget_control_center_init_lua()
    assert(exists("tde/widget/control-center/init.lua"), "Check that tde/widget/control-center/init.lua exists")
end

function test_configuration_mod_key_tde_widget_control_center_dashboard_quick_settings_lua()
    assert(
        exists("tde/widget/control-center/dashboard/quick-settings.lua"),
        "Check that tde/widget/control-center/dashboard/quick-settings.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_control_center_dashboard_hardware_monitor_lua()
    assert(
        exists("tde/widget/control-center/dashboard/hardware-monitor.lua"),
        "Check that tde/widget/control-center/dashboard/hardware-monitor.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_control_center_dashboard_action_center_lua()
    assert(
        exists("tde/widget/control-center/dashboard/action-center.lua"),
        "Check that tde/widget/control-center/dashboard/action-center.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_material_clickable_container_lua()
    assert(
        exists("tde/widget/material/clickable-container.lua"),
        "Check that tde/widget/material/clickable-container.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_material_icon_lua()
    assert(exists("tde/widget/material/icon.lua"), "Check that tde/widget/material/icon.lua exists")
end

function test_configuration_mod_key_tde_widget_material_slider_lua()
    assert(exists("tde/widget/material/slider.lua"), "Check that tde/widget/material/slider.lua exists")
end

function test_configuration_mod_key_tde_widget_material_list_item_lua()
    assert(exists("tde/widget/material/list-item.lua"), "Check that tde/widget/material/list-item.lua exists")
end

function test_configuration_mod_key_tde_widget_material_icon_button_lua()
    assert(exists("tde/widget/material/icon-button.lua"), "Check that tde/widget/material/icon-button.lua exists")
end

function test_configuration_mod_key_tde_widget_action_center_clickable_container_lua()
    assert(
        exists("tde/widget/action-center/clickable-container.lua"),
        "Check that tde/widget/action-center/clickable-container.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_action_center_init_lua()
    assert(exists("tde/widget/action-center/init.lua"), "Check that tde/widget/action-center/init.lua exists")
end

function test_configuration_mod_key_tde_widget_notification_center_panel_rules_lua()
    assert(
        exists("tde/widget/notification-center/panel-rules.lua"),
        "Check that tde/widget/notification-center/panel-rules.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_notification_center_init_lua()
    assert(
        exists("tde/widget/notification-center/init.lua"),
        "Check that tde/widget/notification-center/init.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_notification_center_right_panel_lua()
    assert(
        exists("tde/widget/notification-center/right-panel.lua"),
        "Check that tde/widget/notification-center/right-panel.lua exists"
    )
end

function test_configuration_mod_key_tde_widget_about_init_lua()
    assert(exists("tde/widget/about/init.lua"), "Check that tde/widget/about/init.lua exists")
end

function test_configuration_mod_key_tde_widget_scrollbar_lua()
    assert(exists("tde/widget/scrollbar.lua"), "Check that tde/widget/scrollbar.lua exists")
end

function test_configuration_mod_key_tde_widget_user_profile_init_lua()
    assert(exists("tde/widget/user-profile/init.lua"), "Check that tde/widget/user-profile/init.lua exists")
end

function test_configuration_mod_key_tde_widget_package_updater_init_lua()
    assert(exists("tde/widget/package-updater/init.lua"), "Check that tde/widget/package-updater/init.lua exists")
end

function test_configuration_mod_key_tde_widget_clickable_container_init_lua()
    assert(
        exists("tde/widget/clickable-container/init.lua"),
        "Check that tde/widget/clickable-container/init.lua exists"
    )
end

function test_configuration_mod_key_tde_tutorial_lua()
    assert(exists("tde/tutorial.lua"), "Check that tde/tutorial.lua exists")
end
