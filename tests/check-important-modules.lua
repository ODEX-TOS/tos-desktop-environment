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

local function merge_tables(table1, table2, finder)
    local result = {}
    for _, element in ipairs(table1) do
        if string.find(element, finder) then
            result[#result + 1] = element
        end
    end
    for _, element in ipairs(table2) do
        if string.find(element, finder) then
            result[#result + 1] = element
        end
    end
    return result
end

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

function test_configuration_mod_key_tde_module_titlebar_color_lua()
    assert(exists("tde/module/titlebar/colors.lua"), "Check that tde/module/titlebar/colors.lua exists")
end

function test_configuration_mod_key_tde_module_titlebar_shape_lua()
    assert(exists("tde/module/titlebar/shapes.lua"), "Check that tde/module/titlebar/shapes.lua exists")
end

function test_configuration_mod_key_tde_module_titlebar_table_lua()
    assert(exists("tde/module/titlebar/table.lua"), "Check that tde/module/titlebar/table.lua exists")
end

function test_configuration_mod_key_tde_module_screen_changed()
    assert(exists("tde/module/screen_changed.lua"), "Check that tde/module/screen_changed.lua exists")
end

function test_configuration_mod_key_tde_configuration_apps_lua()
    assert(exists("tde/configuration/apps.lua"), "Check that tde/configuration/apps.lua exists")
end

function test_configuration_mod_key_tde_configuration_tags_init_lua()
    assert(exists("tde/configuration/tags/init.lua"), "Check that tde/configuration/tags/init.lua exists")
end

function test_configuration_mod_key_tde_configuration_tags_single_maximized_lua()
    assert(
        exists("tde/configuration/tags/layouts/single-maximized.lua"),
        "Check that tde/configuration/tags/layouts/single-maximized.lua exists"
    )
end

function test_configuration_mod_key_tde_configuration_keys_global_lua()
    assert(exists("tde/configuration/keys/global.lua"), "Check that tde/configuration/keys/global.lua exists")
end

function test_configuration_mod_key_tde_configuration_keys_mod_lua()
    assert(exists("tde/configuration/keys/mod.lua"), "Check that tde/configuration/keys/mod.lua exists")
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

function test_configuration_client_buttons()
    assert(exists("tde/configuration/client/buttons.lua"), "Check that tde/configuration/client/buttons.lua exists")
end

function test_configuration_client_init()
    assert(exists("tde/configuration/client/init.lua"), "Check that tde/configuration/client/init.lua exists")
end

function test_collision_focus()
    assert(exists("tde/collision/focus.lua"), "Check that tde/collision/focus.lua exists")
end

function test_collision_init()
    assert(exists("tde/collision/init.lua"), "Check that tde/collision/init.lua exists")
end

function test_collision_layout()
    assert(exists("tde/collision/layout.lua"), "Check that tde/collision/layout.lua exists")
end

function test_collision_max()
    assert(exists("tde/collision/max.lua"), "Check that tde/collision/max.lua exists")
end

function test_collision_mouse()
    assert(exists("tde/collision/mouse.lua"), "Check that tde/collision/mouse.lua exists")
end

function test_collision_resize()
    assert(exists("tde/collision/resize.lua"), "Check that tde/collision/resize.lua exists")
end

function test_collision_screen()
    assert(exists("tde/collision/screen.lua"), "Check that tde/collision/screen.lua exists")
end

function test_collision_util()
    assert(exists("tde/collision/util.lua"), "Check that tde/collision/util.lua exists")
end

function test_module_application()
    assert(exists("tde/module/application-switch.lua"), "Check that tde/module/application-switch.lua exists")
end

function test_module_backdrop()
    assert(exists("tde/module/backdrop.lua"), "Check that tde/module/backdrop.lua exists")
end

function test_module_break_timer()
    assert(exists("tde/module/break-timer.lua"), "Check that tde/module/break-timer.lua exists")
end

function test_module_desktop()
    assert(exists("tde/module/desktop.lua"), "Check that tde/module/dekstop.lua exists")
end

function test_module_installer()
    assert(exists("tde/module/installer.lua"), "Check that tde/module/installer.lua exists")
end

function test_module_mousedrag()
    assert(exists("tde/module/mousedrag.lua"), "Check that tde/module/mousedrag.lua exists")
end

function test_module_quake_terminal()
    assert(exists("tde/module/quake-terminal.lua"), "Check that tde/module/quake-terminal.lua exists")
end

function test_module_settings()
    assert(exists("tde/module/settings.lua"), "Check that tde/module/settings.lua exists")
end

function test_module_state()
    assert(exists("tde/module/state.lua"), "Check that tde/module/state.lua exists")
end

function test_module_volume_manager()
    assert(exists("tde/module/volume_manager.lua"), "Check that tde/module/volume_manager.lua exists")
end

function test_module_volume_slider_osd()
    assert(exists("tde/module/volume-slider-osd.lua"), "Check that tde/module/volume-slider-osd.lua exists")
end

function test_module_init()
    local file = "tde/module/init.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_module_lazy_load()
    local file = "tde/module/lazy_load_boot.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_module_bootup_configuration()
    local file = "tde/module/bootup_configuration.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_global_var()
    local file = "tde/global_var.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_config_writer()
    local file = "tde/lib-tde/config-writer.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_errors()
    local file = "tde/lib-tde/errors.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_extractcover()
    local file = "tde/lib-tde/extractcover.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_file()
    local file = "tde/lib-tde/file.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_hardware_check()
    local file = "tde/lib-tde/hardware-check.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_i18n()
    local file = "tde/lib-tde/i18n.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_imagemagic()
    local file = "tde/lib-tde/imagemagic.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_init()
    local file = "tde/lib-tde/init.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_logger()
    local file = "tde/lib-tde/logger.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_luapath()
    local file = "tde/lib-tde/luapath.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_mappers()
    local file = "tde/lib-tde/mappers.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_mouse()
    local file = "tde/lib-tde/mouse.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_plugin_loader()
    local file = "tde/lib-tde/plugin-loader.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_serialize()
    local file = "tde/lib-tde/serialize.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_signals()
    local file = "tde/lib-tde/signals.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_sound()
    local file = "tde/lib-tde/sound.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_xrandr()
    local file = "tde/lib-tde/xrandr.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_datastructure_binary_tree()
    local file = "tde/lib-tde/datastructure/binary-tree.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_datastructure_hashmap()
    local file = "tde/lib-tde/datastructure/hashmap.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_datastructure_linked_list()
    local file = "tde/lib-tde/datastructure/linkedList.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_datastructure_queue()
    local file = "tde/lib-tde/datastructure/queue.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_datastructure_stack()
    local file = "tde/lib-tde/datastructure/stack.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_datastructure_set()
    local file = "tde/lib-tde/datastructure/set.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_function_application()
    local file = "tde/lib-tde/function/application_runner.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_function_battery()
    local file = "tde/lib-tde/function/battery.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_function_common()
    local file = "tde/lib-tde/function/common.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_function_datetime()
    local file = "tde/lib-tde/function/datetime.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_function_delayed_timer()
    local file = "tde/lib-tde/function/delayed-timer.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_function_init()
    local file = "tde/lib-tde/function/init.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_widget_rounded()
    local file = "tde/lib-tde/widget/rounded.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_volume()
    local file = "tde/lib-tde/volume.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_translations_nl()
    local file = "tde/lib-tde/translations/nl.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_lib_tde_translations_en()
    local file = "tde/lib-tde/translations/en.lua"
    assert(exists(file), "Check that " .. file .. " exists")
end

function test_that_all_important_files_are_tested()
    local amount = 98

    local filehandle = require("tde.lib-tde.file")
    local modules = filehandle.list_dir_full("tde/module")
    local configuration = filehandle.list_dir_full("tde/configuration")
    local layout = filehandle.list_dir_full("tde/layout")
    local collision = filehandle.list_dir_full("tde/collision")
    local settings = filehandle.list_dir_full("tde/settings")
    local theme = filehandle.list_dir_full("tde/theme")
    local lib_tde = filehandle.list_dir("tde/lib-tde")
    local lib_tde_datastruct = filehandle.list_dir("tde/lib-tde/datastructure")
    local lib_tde_functions = filehandle.list_dir("tde/lib-tde/function")
    local translations = filehandle.list_dir("tde/lib-tde/translations")
    local lib_tde_widget = filehandle.list_dir("tde/lib-tde/widget")

    local result = merge_tables(modules, configuration, "lua$")
    result = merge_tables(result, layout, "lua$")
    result = merge_tables(result, collision, "lua$")
    result = merge_tables(result, settings, "lua$")
    result = merge_tables(result, theme, "lua$")
    result = merge_tables(result, lib_tde, "lua$")
    result = merge_tables(result, lib_tde_datastruct, "lua$")
    result = merge_tables(result, lib_tde_functions, "lua$")
    result = merge_tables(result, translations, "lua$")
    result = merge_tables(result, lib_tde_widget, "lua$")

    assert(
        #result == amount,
        "Include test for the new files you added in module, configuration, layout, collision, settings or theme.\n If all these files have been added then update this function amount = " ..
            #result
    )
end
