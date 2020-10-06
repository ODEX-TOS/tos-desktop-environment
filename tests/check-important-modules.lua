local exists = require("tde.lib-tde.file").exists

-- This file checks to make sure the most important files are intact
-- It ignores a lot of fancy feature files such as a lot of widgets

function test_configuration_mod_key_tde_layout_init_lua()
    assert(exists("tde/layout/init.lua"))
end

function test_configuration_mod_key_tde_layout_right_panel_action_bar_lua()
    assert(exists("tde/layout/right-panel/action-bar.lua"))
end

function test_configuration_mod_key_tde_layout_right_panel_init_lua()
    assert(exists("tde/layout/right-panel/init.lua"))
end

function test_configuration_mod_key_tde_layout_top_panel_lua()
    assert(exists("tde/layout/top-panel.lua"))
end

function test_configuration_mod_key_tde_layout_bottom_panel_action_bar_lua()
    assert(exists("tde/layout/bottom-panel/action-bar.lua"))
end

function test_configuration_mod_key_tde_layout_bottom_panel_init_lua()
    assert(exists("tde/layout/bottom-panel/init.lua"))
end

function test_configuration_mod_key_tde_layout_left_panel_action_bar_lua()
    assert(exists("tde/layout/left-panel/action-bar.lua"))
end

function test_configuration_mod_key_tde_layout_left_panel_init_lua()
    assert(exists("tde/layout/left-panel/init.lua"))
end

function test_configuration_mod_key_tde_rc_lua()
    assert(exists("tde/rc.lua"))
end

function test_configuration_mod_key_tde_lib_tde_xrandr_lua()
    assert(exists("tde/lib-tde/xrandr.lua"))
end

function test_configuration_mod_key_tde_lib_tde_sentry_init_lua()
    assert(exists("tde/lib-tde/sentry/init.lua"))
end

function test_configuration_mod_key_tde_lib_tde_file_lua()
    assert(exists("tde/lib-tde/file.lua"))
end

function test_configuration_mod_key_tde_lib_tde_plugin_loader_lua()
    assert(exists("tde/lib-tde/plugin-loader.lua"))
end

function test_configuration_mod_key_tde_lib_tde_sound_lua()
    assert(exists("tde/lib-tde/sound.lua"))
end

function test_configuration_mod_key_tde_lib_tde_errors_lua()
    assert(exists("tde/lib-tde/errors.lua"))
end

function test_configuration_mod_key_tde_lib_tde_hardware_check_lua()
    assert(exists("tde/lib-tde/hardware-check.lua"))
end

function test_configuration_mod_key_tde_lib_tde_logger_lua()
    assert(exists("tde/lib-tde/logger.lua"))
end

function test_configuration_mod_key_tde_lib_tde_luapath_lua()
    assert(exists("tde/lib-tde/luapath.lua"))
end

function test_configuration_mod_key_tde_parser_lua()
    assert(exists("tde/parser.lua"))
end

function test_configuration_mod_key_tde_module_menu_lua()
    assert(exists("tde/module/menu.lua"))
end

function test_configuration_mod_key_tde_module_plugin_module_lua()
    assert(exists("tde/module/plugin-module.lua"))
end

function test_configuration_mod_key_tde_module_exit_screen_lua()
    assert(exists("tde/module/exit-screen.lua"))
end

function test_configuration_mod_key_tde_module_notifications_lua()
    assert(exists("tde/module/notifications.lua"))
end

function test_configuration_mod_key_tde_module_battery_notifier_lua()
    assert(exists("tde/module/battery-notifier.lua"))
end

function test_configuration_mod_key_tde_module_auto_start_lua()
    assert(exists("tde/module/auto-start.lua"))
end

function test_configuration_mod_key_tde_module_titlebar_init_lua()
    assert(exists("tde/module/titlebar/init.lua"))
end

function test_configuration_mod_key_tde_module_decorate_client_lua()
    assert(exists("tde/module/decorate-client.lua"))
end

function test_configuration_mod_key_tde_configuration_apps_lua()
    assert(exists("tde/configuration/apps.lua"))
end

function test_configuration_mod_key_tde_configuration_tags_init_lua()
    assert(exists("tde/configuration/tags/init.lua"))
end

function test_configuration_mod_key_tde_configuration_keys_global_lua()
    assert(exists("tde/configuration/keys/global.lua"))
end

function test_configuration_mod_key_tde_configuration_client_rules_lua()
    assert(exists("tde/configuration/client/rules.lua"))
end

function test_configuration_mod_key_tde_configuration_client_keys_lua()
    assert(exists("tde/configuration/client/keys.lua"))
end

function test_configuration_mod_key_tde_theme_default_theme_lua()
    assert(exists("tde/theme/default-theme.lua"))
end

function test_configuration_mod_key_tde_theme_icons_dark_light_lua()
    assert(exists("tde/theme/icons/dark-light.lua"))
end

function test_configuration_mod_key_tde_widget_control_center_init_lua()
    assert(exists("tde/widget/control-center/init.lua"))
end

function test_configuration_mod_key_tde_widget_control_center_dashboard_quick_settings_lua()
    assert(exists("tde/widget/control-center/dashboard/quick-settings.lua"))
end

function test_configuration_mod_key_tde_widget_control_center_dashboard_hardware_monitor_lua()
    assert(exists("tde/widget/control-center/dashboard/hardware-monitor.lua"))
end

function test_configuration_mod_key_tde_widget_control_center_dashboard_action_center_lua()
    assert(exists("tde/widget/control-center/dashboard/action-center.lua"))
end

function test_configuration_mod_key_tde_widget_material_clickable_container_lua()
    assert(exists("tde/widget/material/clickable-container.lua"))
end

function test_configuration_mod_key_tde_widget_material_icon_lua()
    assert(exists("tde/widget/material/icon.lua"))
end

function test_configuration_mod_key_tde_widget_material_slider_lua()
    assert(exists("tde/widget/material/slider.lua"))
end

function test_configuration_mod_key_tde_widget_material_list_item_lua()
    assert(exists("tde/widget/material/list-item.lua"))
end

function test_configuration_mod_key_tde_widget_material_icon_button_lua()
    assert(exists("tde/widget/material/icon-button.lua"))
end

function test_configuration_mod_key_tde_widget_action_center_clickable_container_lua()
    assert(exists("tde/widget/action-center/clickable-container.lua"))
end

function test_configuration_mod_key_tde_widget_action_center_init_lua()
    assert(exists("tde/widget/action-center/init.lua"))
end

function test_configuration_mod_key_tde_widget_notification_center_panel_rules_lua()
    assert(exists("tde/widget/notification-center/panel-rules.lua"))
end

function test_configuration_mod_key_tde_widget_notification_center_init_lua()
    assert(exists("tde/widget/notification-center/init.lua"))
end

function test_configuration_mod_key_tde_widget_notification_center_right_panel_lua()
    assert(exists("tde/widget/notification-center/right-panel.lua"))
end

function test_configuration_mod_key_tde_widget_about_init_lua()
    assert(exists("tde/widget/about/init.lua"))
end

function test_configuration_mod_key_tde_widget_scrollbar_lua()
    assert(exists("tde/widget/scrollbar.lua"))
end

function test_configuration_mod_key_tde_widget_user_profile_init_lua()
    assert(exists("tde/widget/user-profile/init.lua"))
end

function test_configuration_mod_key_tde_widget_package_updater_init_lua()
    assert(exists("tde/widget/package-updater/init.lua"))
end

function test_configuration_mod_key_tde_widget_clickable_container_init_lua()
    assert(exists("tde/widget/clickable-container/init.lua"))
end

function test_configuration_mod_key_tde_tutorial_lua()
    assert(exists("tde/tutorial.lua"))
end
