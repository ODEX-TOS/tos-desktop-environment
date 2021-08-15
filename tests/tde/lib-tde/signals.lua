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
local signals = require("tde.lib-tde.signals")

function Test_emit_module_exit_screen_hide_exists()
    assert(signals.emit_module_exit_screen_hide, "Make sure the signal emit_module_exit_screen_hide exists")
    assert(
        type(signals.emit_module_exit_screen_hide) == "function",
        "Make sure emit_module_exit_screen_hide is a signal and a function"
    )
end

function Test_connect_module_exit_screen_hide_exists()
    assert(signals.connect_module_exit_screen_hide, "Make sure the signal connect_module_exit_screen_hide exists")
    assert(
        type(signals.connect_module_exit_screen_hide) == "function",
        "Make sure connect_module_exit_screen_hide is a signal and a function"
    )
end

function Test_emit_module_exit_screen_show_exists()
    assert(signals.emit_module_exit_screen_show, "Make sure the signal emit_module_exit_screen_show exists")
    assert(
        type(signals.emit_module_exit_screen_show) == "function",
        "Make sure emit_module_exit_screen_show is a signal and a function"
    )
end

function Test_connect_module_exit_screen_show_exists()
    assert(signals.connect_module_exit_screen_show, "Make sure the signal connect_module_exit_screen_show exists")
    assert(
        type(signals.connect_module_exit_screen_show) == "function",
        "Make sure connect_module_exit_screen_show is a signal and a function"
    )
end

function Test_emit_battery_exists()
    assert(signals.emit_battery, "Make sure the signal emit_battery exists")
    assert(type(signals.emit_battery) == "function", "Make sure emit_battery is a signal and a function")
end

function Test_connect_battery_exists()
    assert(signals.connect_battery, "Make sure the signal connect_battery exists")
    assert(type(signals.connect_battery) == "function", "Make sure connect_battery is a signal and a function")
end

function Test_emit_battery_charging_exists()
    assert(signals.emit_battery_charging, "Make sure the signal emit_battery_charging exists")
    assert(
        type(signals.emit_battery_charging) == "function",
        "Make sure emit_battery_charging is a signal and a function"
    )
end

function Test_connect_battery_charging_exists()
    assert(signals.connect_battery_charging, "Make sure the signal connect_battery_charging exists")
    assert(
        type(signals.connect_battery_charging) == "function",
        "Make sure connect_battery_charging is a signal and a function"
    )
end

function Test_emit_brightness_exists()
    assert(signals.emit_brightness, "Make sure the signal emit_brightness exists")
    assert(type(signals.emit_brightness) == "function", "Make sure emit_brightness is a signal and a function")
end

function Test_connect_brightness_exists()
    assert(signals.connect_brightness, "Make sure the signal connect_brightness exists")
    assert(type(signals.connect_brightness) == "function", "Make sure connect_brightness is a signal and a function")
end

function Test_emit_volume_exists()
    assert(signals.emit_volume, "Make sure the signal emit_volume exists")
    assert(type(signals.emit_volume) == "function", "Make sure emit_volume is a signal and a function")
end

function Test_connect_volume_exists()
    assert(signals.connect_volume, "Make sure the signal connect_volume exists")
    assert(type(signals.connect_volume) == "function", "Make sure connect_volume is a signal and a function")
end

function Test_connect_weather_exists()
    assert(signals.connect_weather, "Make sure the signal connect_weather exists")
    assert(type(signals.connect_weather) == "function", "Make sure connect_weather is a signal and a function")
end

function Test_emit_username_exists()
    assert(signals.emit_username, "Make sure the signal emit_username exists")
    assert(type(signals.emit_username) == "function", "Make sure emit_username is a signal and a function")
end

function Test_connect_username_exists()
    assert(signals.connect_username, "Make sure the signal connect_username exists")
    assert(type(signals.connect_username) == "function", "Make sure connect_username is a signal and a function")
end

function Test_emit_distro_exists()
    assert(signals.emit_distro, "Make sure the signal emit_distro exists")
    assert(type(signals.emit_distro) == "function", "Make sure emit_distro is a signal and a function")
end

function Test_connect_distro_exists()
    assert(signals.connect_distro, "Make sure the signal connect_distro exists")
    assert(type(signals.connect_distro) == "function", "Make sure connect_distro is a signal and a function")
end

function Test_emit_uptime_exists()
    assert(signals.emit_uptime, "Make sure the signal emit_uptime exists")
    assert(type(signals.emit_uptime) == "function", "Make sure emit_uptime is a signal and a function")
end

function Test_connect_uptime_exists()
    assert(signals.connect_uptime, "Make sure the signal connect_uptime exists")
    assert(type(signals.connect_uptime) == "function", "Make sure connect_uptime is a signal and a function")
end

function Test_emit_kernel_exists()
    assert(signals.emit_kernel, "Make sure the signal emit_kernel exists")
    assert(type(signals.emit_kernel) == "function", "Make sure emit_kernel is a signal and a function")
end

function Test_connect_kernel_exists()
    assert(signals.connect_kernel, "Make sure the signal connect_kernel exists")
    assert(type(signals.connect_kernel) == "function", "Make sure connect_kernel is a signal and a function")
end

function Test_emit_packages_to_update_exists()
    assert(signals.emit_packages_to_update, "Make sure the signal emit_packages_to_update exists")
    assert(
        type(signals.emit_packages_to_update) == "function",
        "Make sure emit_packages_to_update is a signal and a function"
    )
end

function Test_connect_packages_to_update_exists()
    assert(signals.connect_packages_to_update, "Make sure the signal connect_packages_to_update exists")
    assert(
        type(signals.connect_packages_to_update) == "function",
        "Make sure connect_packages_to_update is a signal and a function"
    )
end

function Test_emit_cpu_usage_exists()
    assert(signals.emit_cpu_usage, "Make sure the signal emit_cpu_usage exists")
    assert(type(signals.emit_cpu_usage) == "function", "Make sure emit_cpu_usage is a signal and a function")
end

function Test_connect_cpu_usage_exists()
    assert(signals.connect_cpu_usage, "Make sure the signal connect_cpu_usage exists")
    assert(type(signals.connect_cpu_usage) == "function", "Make sure connect_cpu_usage is a signal and a function")
end

function Test_emit_disk_usage_exists()
    assert(signals.emit_disk_usage, "Make sure the signal emit_disk_usage exists")
    assert(type(signals.emit_disk_usage) == "function", "Make sure emit_disk_usage is a signal and a function")
end

function Test_connect_disk_usage_exists()
    assert(signals.connect_disk_usage, "Make sure the signal connect_disk_usage exists")
    assert(type(signals.connect_disk_usage) == "function", "Make sure connect_disk_usage is a signal and a function")
end

function Test_emit_disk_space_exists()
    assert(signals.emit_disk_space, "Make sure the signal emit_disk_space exists")
    assert(type(signals.emit_disk_space) == "function", "Make sure emit_disk_space is a signal and a function")
end

function Test_connect_disk_space_exists()
    assert(signals.connect_disk_space, "Make sure the signal connect_disk_space exists")
    assert(type(signals.connect_disk_space) == "function", "Make sure connect_disk_space is a signal and a function")
end

function Test_emit_ram_usage_exists()
    assert(signals.emit_ram_usage, "Make sure the signal emit_ram_usage exists")
    assert(type(signals.emit_ram_usage) == "function", "Make sure emit_ram_usage is a signal and a function")
end

function Test_connect_ram_usage_exists()
    assert(signals.connect_ram_usage, "Make sure the signal connect_ram_usage exists")
    assert(type(signals.connect_ram_usage) == "function", "Make sure connect_ram_usage is a signal and a function")
end

function Test_emit_ram_total_exists()
    assert(signals.emit_ram_total, "Make sure the signal emit_ram_total exists")
    assert(type(signals.emit_ram_total) == "function", "Make sure emit_ram_total is a signal and a function")
end

function Test_connect_ram_total_exists()
    assert(signals.connect_ram_total, "Make sure the signal connect_ram_total exists")
    assert(type(signals.connect_ram_total) == "function", "Make sure connect_ram_total is a signal and a function")
end

function Test_emit_bluetooth_status_exists()
    assert(signals.emit_bluetooth_status, "Make sure the signal emit_bluetooth_status exists")
    assert(
        type(signals.emit_bluetooth_status) == "function",
        "Make sure emit_bluetooth_status is a signal and a function"
    )
end

function Test_connect_bluetooth_status_exists()
    assert(signals.connect_bluetooth_status, "Make sure the signal connect_bluetooth_status exists")
    assert(
        type(signals.connect_bluetooth_status) == "function",
        "Make sure connect_bluetooth_status is a signal and a function"
    )
end

function Test_emit_wifi_status_exists()
    assert(signals.emit_wifi_status, "Make sure the signal emit_wifi_status exists")
    assert(type(signals.emit_wifi_status) == "function", "Make sure emit_wifi_status is a signal and a function")
end

function Test_connect_wifi_status_exists()
    assert(signals.connect_wifi_status, "Make sure the signal connect_wifi_status exists")
    assert(type(signals.connect_wifi_status) == "function", "Make sure connect_wifi_status is a signal and a function")
end

function Test_connect_exit()
    assert(signals.connect_exit, "Make sure the signal connect_exit exists")
    assert(type(signals.connect_exit) == "function", "Make sure connect_exit is a signal and a function")
end

function Test_connect_mouse_speed()
    assert(signals.connect_mouse_speed, "Make sure the signal connect_mouse_speed exists")
    assert(type(signals.connect_mouse_speed) == "function", "Make sure connect_mouse_speed is a signal and a function")
end

function Test_emit_mouse_speed()
    assert(signals.emit_mouse_speed, "Make sure the signal emit_mouse_speed exists")
    assert(type(signals.emit_mouse_speed) == "function", "Make sure emit_mouse_speed is a signal and a function")
end

function Test_connect_mouse_accel()
    assert(signals.connect_mouse_acceleration, "Make sure the signal connect_mouse_acceleration exists")
    assert(
        type(signals.connect_mouse_acceleration) == "function",
        "Make sure connect_mouse_acceleration is a signal and a function"
    )
end

function Test_emit_mouse_accel()
    assert(signals.emit_mouse_acceleration, "Make sure the signal emit_mouse_acceleration exists")
    assert(
        type(signals.emit_mouse_acceleration) == "function",
        "Make sure emit_mouse_acceleration is a signal and a function"
    )
end

function Test_connect_mouse_natural_scrolling()
    assert(signals.connect_mouse_natural_scrolling, "Make sure the signal connect_mouse_natural_scrolling exists")
    assert(
        type(signals.connect_mouse_natural_scrolling) == "function",
        "Make sure connect_mouse_natural_scrolling is a signal and a function"
    )
end

function Test_emit_mouse_natural_scrolling()
    assert(signals.emit_mouse_natural_scrolling, "Make sure the signal emit_mouse_natural_scrolling exists")
    assert(
        type(signals.emit_mouse_natural_scrolling) == "function",
        "Make sure emit_mouse_natural_scrolling is a signal and a function"
    )
end

function Test_connect_refresh_screen()
    assert(signals.connect_refresh_screen, "Make sure the signal connect_refresh_screen exists")
    assert(
        type(signals.connect_refresh_screen) == "function",
        "Make sure connect_refresh_screen is a signal and a function"
    )
end

function Test_emit_refresh_screen()
    assert(signals.emit_refresh_screen, "Make sure the signal emit_refresh_screen exists")
    assert(type(signals.emit_refresh_screen) == "function", "Make sure emit_refresh_screen is a signal and a function")
end

function Test_connect_profile_picture()
    assert(signals.connect_profile_picture_changed, "Make sure the signal connect_profile_picture_changed exists")
    assert(
        type(signals.connect_profile_picture_changed) == "function",
        "Make sure connect_profile_picture_changed is a signal and a function"
    )
end

function Test_emit_profile_picture()
    assert(signals.emit_profile_picture_changed, "Make sure the signal emit_profile_picture_changed exists")
    assert(
        type(signals.emit_profile_picture_changed) == "function",
        "Make sure emit_profile_picture_changed is a signal and a function"
    )
end

function Test_connect_do_not_disturb()
    assert(signals.connect_do_not_disturb, "Make sure the signal connect_do_not_disturb exists")
    assert(
        type(signals.connect_do_not_disturb) == "function",
        "Make sure connect_do_not_disturb is a signal and a function"
    )
end

function Test_emit_do_not_disturb()
    assert(signals.emit_do_not_disturb, "Make sure the signal emit_do_not_disturb exists")
    assert(type(signals.emit_do_not_disturb) == "function", "Make sure emit_do_not_disturb is a signal and a function")
end

function Test_connect_primary_theme_changed()
    assert(signals.connect_primary_theme_changed, "Make sure the signal connect_primary_theme_changed exists")
    assert(
        type(signals.connect_primary_theme_changed) == "function",
        "Make sure connect_primary_theme_changed is a signal and a function"
    )
end

function Test_emit_primary_theme_changed()
    assert(signals.emit_primary_theme_changed, "Make sure the signal emit_primary_theme_changed exists")
    assert(
        type(signals.emit_primary_theme_changed) == "function",
        "Make sure emit_primary_theme_changed is a signal and a function"
    )
end

function Test_connect_background_theme_changed()
    assert(signals.connect_background_theme_changed, "Make sure the signal connect_background_theme_changed exists")
    assert(
        type(signals.connect_background_theme_changed) == "function",
        "Make sure connect_background_theme_changed is a signal and a function"
    )
end

function Test_emit_background_theme_changed()
    assert(signals.emit_background_theme_changed, "Make sure the signal emit_background_theme_changed exists")
    assert(
        type(signals.emit_background_theme_changed) == "function",
        "Make sure emit_background_theme_changed is a signal and a function"
    )
end

function Test_connect_olde_mode_changed()
    assert(signals.connect_oled_mode, "Make sure the signal connect_oled_mode exists")
    assert(type(signals.connect_oled_mode) == "function", "Make sure connect_oled_mode is a signal and a function")
end

function Test_emit_oled_mode_changed()
    assert(signals.emit_oled_mode, "Make sure the signal emit_oled_mode exists")
    assert(type(signals.emit_oled_mode) == "function", "Make sure emit_oled_mode is a signal and a function")
end


function Test_emit_request_kernel()
    assert(signals.emit_request_kernel, "Make sure the signal emit_request_kernel exists")
    assert(type(signals.emit_request_kernel) == "function", "Make sure emit_request_kernel is a signal and a function")
end

function Test_connect_request_kernel()
    assert(signals.connect_request_kernel, "Make sure the signal connect_request_kernel exists")
    assert(type(signals.connect_request_kernel) == "function", "Make sure connect_request_kernel is a signal and a function")
end


function Test_emit_request_distro()
    assert(signals.emit_request_distro, "Make sure the signal emit_request_distro exists")
    assert(type(signals.emit_request_distro) == "function", "Make sure emit_request_distro is a signal and a function")
end

function Test_connect_request_distro()
    assert(signals.connect_request_distro, "Make sure the signal connect_request_distro exists")
    assert(type(signals.connect_request_distro) == "function", "Make sure connect_request_distro is a signal and a function")
end

function Test_emit_request_cpu()
    assert(signals.emit_request_cpu, "Make sure the signal emit_request_cpu exists")
    assert(type(signals.emit_request_cpu) == "function", "Make sure emit_request_cpu is a signal and a function")
end

function Test_connect_request_cpu()
    assert(signals.connect_request_cpu, "Make sure the signal connect_request_cpu exists")
    assert(type(signals.connect_request_cpu) == "function", "Make sure connect_request_cpu is a signal and a function")
end

function Test_emit_request_ram()
    assert(signals.emit_request_ram, "Make sure the signal emit_request_ram exists")
    assert(type(signals.emit_request_ram) == "function", "Make sure emit_request_ram is a signal and a function")
end

function Test_connect_request_ram()
    assert(signals.connect_request_ram, "Make sure the signal connect_request_ram exists")
    assert(type(signals.connect_request_ram) == "function", "Make sure connect_request_ram is a signal and a function")
end

function Test_emit_request_disk()
    assert(signals.emit_request_disk, "Make sure the signal emit_request_disk exists")
    assert(type(signals.emit_request_disk) == "function", "Make sure emit_request_disk is a signal and a function")
end

function Test_connect_request_disk()
    assert(signals.connect_request_disk, "Make sure the signal connect_request_disk exists")
    assert(type(signals.connect_request_disk) == "function", "Make sure connect_request_disk is a signal and a function")
end


function Test_emit_request_user()
    assert(signals.emit_request_user, "Make sure the signal emit_request_user exists")
    assert(type(signals.emit_request_user) == "function", "Make sure emit_request_user is a signal and a function")
end

function Test_connect_request_user()
    assert(signals.connect_request_user, "Make sure the signal connect_request_user exists")
    assert(type(signals.connect_request_user) == "function", "Make sure connect_request_user is a signal and a function")
end


function Test_emit_request_profile_pic()
    assert(signals.emit_request_profile_pic, "Make sure the signal emit_request_profile_pic exists")
    assert(type(signals.emit_request_profile_pic) == "function", "Make sure emit_request_profile_pic is a signal and a function")
end

function Test_connect_request_profile_pic()
    assert(signals.connect_request_profile_pic, "Make sure the signal connect_request_profile_pic exists")
    assert(type(signals.connect_request_profile_pic) == "function", "Make sure connect_request_profile_pic is a signal and a function")
end


function Test_emit_request_uptime()
    assert(signals.emit_request_uptime, "Make sure the signal emit_request_uptime exists")
    assert(type(signals.emit_request_uptime) == "function", "Make sure emit_request_uptime is a signal and a function")
end

function Test_connect_request_uptime()
    assert(signals.connect_request_uptime, "Make sure the signal connect_request_uptime exists")
    assert(type(signals.connect_request_uptime) == "function", "Make sure connect_request_uptime is a signal and a function")
end

function Test_emit_save_tag_state()
    assert(signals.emit_save_tag_state, "Make sure the signal emit_save_tag_state exists")
    assert(type(signals.emit_save_tag_state) == "function", "Make sure emit_save_tag_state is a signal and a function")
end

function Test_connect_save_tag_state()
    assert(signals.connect_save_tag_state, "Make sure the signal connect_save_tag_state exists")
    assert(type(signals.connect_save_tag_state) == "function", "Make sure connect_save_tag_state is a signal and a function")
end

function Test_emit_mic_volume()
    assert(signals.emit_mic_volume, "Make sure the signal emit_mic_volume exists")
    assert(type(signals.emit_mic_volume) == "function", "Make sure emit_mic_volume is a signal and a function")
end

function Test_connect_mic_volume()
    assert(signals.connect_mic_volume, "Make sure the signal connect_mic_volume exists")
    assert(type(signals.connect_mic_volume) == "function", "Make sure connect_mic_volume is a signal and a function")
end

function Test_emit_showed_news()
    assert(signals.emit_showed_news, "Make sure the signal emit_showed_news exists")
    assert(type(signals.emit_showed_news) == "function", "Make sure emit_showed_news is a signal and a function")
end

function Test_connect_showed_news()
    assert(signals.connect_showed_news, "Make sure the signal connect_showed_news exists")
    assert(type(signals.connect_showed_news) == "function", "Make sure connect_showed_news is a signal and a function")
end

function Test_emit_volume_update()
    assert(signals.emit_volume_update, "Make sure the signal emit_volume_update exists")
    assert(type(signals.emit_volume_update) == "function", "Make sure emit_volume_update is a signal and a function")
end

function Test_connect_volume_update()
    assert(signals.connect_volume_update, "Make sure the signal connect_volume_update exists")
    assert(type(signals.connect_volume_update) == "function", "Make sure connect_volume_update is a signal and a function")
end

function Test_emit_volume_muted()
    assert(signals.emit_volume_is_muted, "Make sure the signal emit_volume_is_muted exists")
    assert(type(signals.emit_volume_is_muted) == "function", "Make sure emit_volume_is_muted is a signal and a function")
end

function Test_connect_volume_muted()
    assert(signals.connect_volume_is_muted, "Make sure the signal connect_volume_is_muted exists")
    assert(type(signals.connect_volume_is_muted) == "function", "Make sure connect_volume_is_muted is a signal and a function")
end

function Test_emit_volume_is_controlled_in_software()
    assert(signals.emit_volume_is_controlled_in_software, "Make sure the signal emit_volume_is_controlled_in_software exists")
    assert(type(signals.emit_volume_is_controlled_in_software) == "function", "Make sure emit_volume_is_controlled_in_software is a signal and a function")
end

function Test_connect_volume_is_controlled_in_software()
    assert(signals.connect_volume_is_controlled_in_software, "Make sure the signal connect_volume_is_controlled_in_software exists")
    assert(type(signals.connect_volume_is_controlled_in_software) == "function", "Make sure connect_volume_is_controlled_in_software is a signal and a function")
end

function Test_emit_keyboard_layout()
    assert(signals.emit_keyboard_layout, "Make sure the signal emit_keyboard_layout exists")
    assert(type(signals.emit_keyboard_layout) == "function", "Make sure emit_keyboard_layout is a signal and a function")
end

function Test_connect_keyboard_layout()
    assert(signals.connect_keyboard_layout, "Make sure the signal connect_keyboard_layout exists")
    assert(type(signals.connect_keyboard_layout) == "function", "Make sure connect_keyboard_layout is a signal and a function")
end

function Test_emit_keyboard_layout_updated()
    assert(signals.emit_keyboard_layout_updated, "Make sure the signal emit_keyboard_layout_updated exists")
    assert(type(signals.emit_keyboard_layout_updated) == "function", "Make sure emit_keyboard_layout_updated is a signal and a function")
end

function Test_connect_keyboard_layout_updated()
    assert(signals.connect_keyboard_layout_updated, "Make sure the signal connect_keyboard_layout_updated exists")
    assert(type(signals.connect_keyboard_layout_updated) == "function", "Make sure connect_keyboard_layout_updated is a signal and a function")
end


function Test_signals_api_unit_tested()
    local amount = 95
    local result = tablelength(signals)
    assert(
        result == amount,
        "You didn't test all signals api endpoints, please add them then update the amount to: " .. result
    )
end
