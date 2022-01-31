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
-- This module listens for events and stores then
-- This makes certain data persistent

local signals = require("lib-tde.signals")
local serialize = require("lib-tde.serialize")
local filehandle = require("lib-tde.file")
local mouse = require("lib-tde.mouse")
local volume = require("lib-tde.volume")
local major_version = require("lib-tde.function.common").major_version
local gears = require("gears")


local file = os.getenv("HOME") .. "/.cache/tde/settings_state.json"

local function gen_default_tag()
    return {
        master_width_factor = 0.5,
        master_count = 1,
        gap = 4,
        layout = "tile"
    }
end

local default_keyboard_layout = function()
    local keymap = filehandle.lines('/etc/vconsole.conf')

    local map = string.match(keymap[1], "KEYMAP=(.*)")
    return map or "us"
end

local function ensure_valid_dev_settings(state, disabled_dev_settings)
    if general["developer"] == "1" then
        state.developer.enabled = true
        return state
    end

    state.developer = disabled_dev_settings

    return state
end

-- Ensure that the path exists on which the plugins are installed, otherwise omit them
local function validate_plugins(plugins)
    if plugins == nil then
        return {}
    end

    local __file = require("lib-tde.file")
    local res = {}

    for key, plugin in pairs(plugins) do
        if plugin.path == "" or (__file.dir_exists(plugin.path) and __file.exists(plugin.path .. '/init.lua') and __file.exists(plugin.path .. '/metadata.json')) then
            res[key] = plugin
        end
    end

    return res
end

local function load()

    local fetch_default_layout = default_keyboard_layout()

    local table = {
        volume = 50,
        mic_volume = 50,
        volume_muted = false,
        brightness = 100,
        mouse = {},
        do_not_disturb = false,
        oled_mode = false,
        bluetooth = false,
        auto_hide = false,
        hardware_only_volume = false,
        hardware_only_volume_controls = {},
        last_version = major_version(),
        rounded_corner = 10,
        tags = {
            gen_default_tag(),
            gen_default_tag(),
            gen_default_tag(),
            gen_default_tag(),
            gen_default_tag(),
            gen_default_tag(),
            gen_default_tag(),
            gen_default_tag(),
        },
        keyboard = {
            active = fetch_default_layout,
            layouts = {fetch_default_layout}
        },
        -- settings that should only be changed by developers
        developer = {
            note = "ONLY DEVELOPERS SHOULD SAVE THESE SETTINGS",
            enabled = false,
            draw_debug = false,
            draw_debug_colors = false,
            paint_refresh = false,
        },
        theming = {
            custom_primary_theme = false,
            custom_background_theme = false,
            primary_theme = {

            },
            background_theme = {

            }
        },
        wallpaper = {
            default_image = "/usr/share/backgrounds/tos/default.jpg",
            cycle_mode = false,
            cycles = {}
        },
        vpn_data = {},
        plugins = {},
        display = {},
        -- See tde/configuration/keys/mod.lua for default keyboard shortcuts
        keyboard_shortcuts = {}
    }
    if not filehandle.exists(file) then
        return table
    end
    local result = serialize.deserialize_from_file(file) or {}
    -- in case someone modified the state object and some properties are faulty or errored outputs
    result.volume = result.volume or table.volume
    result.volume_muted = result.volume_muted or table.volume_muted
    result.mic_volume = result.mic_volume or table.mic_volume
    result.brightness = result.brightness or table.brightness
    result.mouse = result.mouse or table.mouse
    result.do_not_disturb = result.do_not_disturb or table.do_not_disturb
    result.oled_mode = result.oled_mode or table.oled_mode
    result.bluetooth = result.bluetooth or table.bluetooth
    result.auto_hide = result.auto_hide or table.auto_hide
    result.hardware_only_volume = result.hardware_only_volume or table.hardware_only_volume
    result.hardware_only_volume_controls = result.hardware_only_volume_controls or table.hardware_only_volume_controls
    result.tags = result.tags or table.tags
    result.rounded_corner = result.rounded_corner or table.rounded_corner
    result.wallpaper = result.wallpaper or table.wallpaper

    result.vpn_data = result.vpn_data or table.vpn_data
    result.plugins = validate_plugins(result.plugins)  or table.plugins
    result.display = result.display or table.display

    result.last_version = result.last_version or table.last_version

    result.keyboard = result.keyboard or table.keyboard

    result.keyboard_shortcuts = result.keyboard_shortcuts or table.keyboard_shortcuts

    result.developer = result.developer or table.developer
    result = ensure_valid_dev_settings(result, table.developer)

    result.theming = result.theming or table.theming

    -- For some reason we downgraded tos, in this case we should also trigger the news section
    -- We do this by making the last_version smaller
    if result.last_version > major_version() then
        result.last_version = major_version() - 0.1
    end

    -- always set the auto_hide true when using oled (To reduce burn in)
    if result.oled_mode then
        result.auto_hide = true
    end

    local weak = {}
    setmetatable(result, weak)
    weak.__mode = "k"

    return result
end

local function save(table)
    print("Updating state into: " .. file)
    if not IsreleaseMode then
        return
    end
    serialize.serialize_to_file(file, table)
end

local function setup_keymap(keyboard)
    local cmd = "setxkbmap '" .. keyboard.active .. "'"
    print("Setting keyboard layouts to: " .. keyboard.active)
    awful.spawn(cmd, false)
end

local function setup_state(state)
    -- set volume mute state
    volume.set_muted_state(state.volume_muted)

    -- set the volume
    print("Setting volume: " .. state.volume)
    volume.set_volume(state.volume or 0)

    volume.set_mic_volume(state.mic_volume or 0)

    -- set the brightness
    if (_G.oled) then
        awful.spawn("brightness -s " .. math.max(state.brightness, 5) .. " -F", false) -- toggle pixel values
    else
        awful.spawn("brightness -s 100 -F", false) -- reset pixel values
        awful.spawn("brightness -s " .. math.max(state.brightness, 5), false)
    end

    signals.emit_brightness(math.max(state.brightness, 5))
    signals.emit_do_not_disturb(state.do_not_disturb or false)
    signals.emit_oled_mode(state.oled_mode or false)


    setup_keymap(state.keyboard)

    -- execute xrandr script
    tde.connect_signal(
        "startup",
        function()
            awful.spawn.easy_async(
                "sh -c 'which autorandr && ( autorandr --load tde || true )'",
                function()
                end
            )
        end
    )

    -- update bluetooth status
    if state.bluetooth then
        awful.spawn.with_shell([[
            rfkill unblock bluetooth
            echo 'power on' | bluetoothctl
        ]])
    else
        awful.spawn.with_shell([[
            echo 'power off' | bluetoothctl
            rfkill block bluetooth
        ]])
    end


    -- find all mouse peripheral that are currently attached to the machine
    print("Fetching mouse peripherals")
    mouse.getInputDevices(function(devices)
        print("Fetched mouse peripherals")
        print(devices)

        for _, device in ipairs(devices) do
            -- if they exist then set their properties
            if state.mouse[device.name] ~= nil then
                mouse.setAcceleration(device.id, state.mouse[device.name].accel or 0)
                mouse.setMouseSpeed(device.id, state.mouse[device.name].speed or 1)
                mouse.setNaturalScrolling(device.id, state.mouse[device.name].natural_scroll or false)
            end
        end
    end)


    if state.developer.enabled then
        -- force a hierarcy redraw so that the draw settings are enforced
        tde.emit_signal("full_redraw")
    end
end

-- load the initial state
-- luacheck: ignore 121
save_state = load()

if IsreleaseMode then
    setup_state(save_state)
end

-- xinput id's are not persistent across reboots
-- thus we map the xinput id to the device name, which is always the same
-- in case our state doesn't have the id yet we create it
local function get_mouse_state_id(id, cb)
    mouse.getInputDevices(function(devices)
        -- find the name in the device range
        local name = nil
        for _, device in ipairs(devices) do
            if device.id == id then
                name = device.name
            end
        end
        if save_state.mouse == nil then
            save_state.mouse = {}
        end
        if name ~= nil and save_state.mouse[name] == nil then
            save_state.mouse[name] = {
                accel = 0,
                speed = 1,
                natural_scroll = false
            }
        end

        local weak = {}
        setmetatable(save_state.mouse, weak)
        weak.__mode = "k"

        cb(name)
    end)
end

local function gen_tag_list()
    local tag_list = {}

    local weak = {}
    setmetatable(tag_list, weak)
    weak.__mode = "k"

    for _, tag in ipairs(awful.screen.focused().tags) do
      table.insert(tag_list, {
        master_width_factor = tag.master_width_factor,
        master_count = tag.master_count,
        gap = tag.gap,
        layout = tag.layout.name or "tile"
      })
    end
    return tag_list
  end

-- listen for events and store the state on those events

signals.connect_volume(
    function(value)
        if save_state.volume == value then
            return
        end
        save_state.volume = value
        save(save_state)
    end
)

signals.connect_mic_volume(
    function(value)
        if save_state.mic_volume == value then
            return
        end
        save_state.mic_volume = value
        save(save_state)
    end
)

signals.connect_volume_is_muted(
    function(is_muted)
        if save_state.volume_muted == is_muted then
            return
        end
        save_state.volume_muted = is_muted
        save(save_state)
    end
)

local function find_port_in_list(list, port)
    for index, val in ipairs(list) do
        if val == port then
            return index
        end
    end

    return nil
end

signals.connect_volume_is_controlled_in_software(
    function(bIsControlledInSoftware, sink)

        if sink == nil or type(sink) ~= "table" then return end

        -- create it in case it doesn't exist yet
        if save_state.hardware_only_volume_controls[sink.name] == nil then
            save_state.hardware_only_volume_controls[sink.name] = {
                name = sink.name,
                ports = {sink.port},
                hardware_only_volume = not bIsControlledInSoftware
            }
        end

        local index = find_port_in_list(save_state.hardware_only_volume_controls[sink.name].ports, sink.port)
        if bIsControlledInSoftware then
            if index ~= nil then table.remove(save_state.hardware_only_volume_controls[sink.name].ports, index) end
        else
            if index == nil then table.insert(save_state.hardware_only_volume_controls[sink.name].ports, sink.port) end
        end

        save_state.hardware_only_volume_controls[sink.name].hardware_only_volume = not bIsControlledInSoftware

        -- TODO: Deprecate this legacy settings, we now control hardware based on the active source/port
        save_state.hardware_only_volume = not bIsControlledInSoftware
        save(save_state)
    end
)

signals.connect_brightness(
    function(value)
        if save_state.brightness == value then
            return
        end

        print("Brightness value: " .. value)
        save_state.brightness = value
        save(save_state)
    end
)

signals.connect_exit(
    function()
        print("Shutting down, grabbing last state")
        awful.spawn("sh -c 'which autorandr && autorandr --save tde --force'", false)
        save(save_state)
    end
)

-- mouse related signals
signals.connect_mouse_speed(
    function(tbl)
        print("Saving mouse id: " .. tbl.id .. " to speed value: " .. tbl.speed)
        get_mouse_state_id(tbl.id, function(id)
            if id ~= nil then
                save_state.mouse[id].speed = tbl.speed
                save(save_state)
            end
        end)
    end
)

signals.connect_mouse_acceleration(
    function(tbl)
        print("Saving mouse id: " .. tbl.id .. " to accel value: " .. tbl.speed)
        get_mouse_state_id(tbl.id, function(id)
            if id ~= nil then
                save_state.mouse[id].accel = tbl.speed
                save(save_state)
            end
        end)
    end
)

signals.connect_do_not_disturb(
    function(bDoNotDisturb)
        if save_state.do_not_disturb == bDoNotDisturb then
            return
        end
        print("Changed do not disturb: " .. tostring(bDoNotDisturb))
        save_state.do_not_disturb = bDoNotDisturb
        save(save_state)
    end
)

signals.connect_oled_mode(
    function(bIsOledMode)
        if save_state.oled_mode == bIsOledMode then
            return
        end
        print("Changed oled mode to: " .. tostring(bIsOledMode))
        save_state.oled_mode = bIsOledMode
        if bIsOledMode and not save_state.auto_hide then
            -- special edge case
            -- when oled mode is turned on we also want to enable auto hide mode
            signals.emit_auto_hide(true)
        end
        save(save_state)
    end
)

signals.connect_mouse_natural_scrolling(
    function(tbl)
        print("Saving mouse id: " .. tbl.id .. " to natural scrolling state: " .. tostring(tbl.state))
        get_mouse_state_id(tbl.id, function (id)
            if id ~= nil then
                save_state.mouse[id].natural_scroll = tbl.state
                save(save_state)
            end
        end)
    end
)

signals.connect_bluetooth_status(function (bIsEnabled)
    if save_state.bluetooth == bIsEnabled then
        return
    end
    save_state.bluetooth = bIsEnabled
    save(save_state)
end)

signals.connect_auto_hide(function (bIsEnabled)
    if save_state.auto_hide == bIsEnabled then
        return
    end
    save_state.auto_hide = bIsEnabled
    save(save_state)
end)

signals.connect_save_tag_state(function()
    local tags = gen_tag_list()

    if #tags >= 8 then
        save_state.tags = tags
        save(save_state)
    end
end)

signals.connect_showed_news(function()
    if save_state.last_version == major_version() then
        return
    end
    save_state.last_version = major_version()
    save(save_state)
end)

signals.connect_keyboard_layout_updated(function (layouts, active_layout)
    save_state.keyboard.active = active_layout
    save_state.keyboard.layouts = layouts

    save(save_state)
end)


signals.connect_save_developer_settings(function()
    save(save_state)
end)

signals.connect_save_theming_settings(function(bIsPrimaryGradient, bIsBackgroundGradient)
    local beautiful = require("beautiful")

    if bIsPrimaryGradient ~= nil then
        save_state.theming.custom_primary_theme = bIsPrimaryGradient
    end

    if bIsBackgroundGradient ~= nil then
        save_state.theming.custom_background_theme = bIsBackgroundGradient
    end

    save_state.theming.background_theme = beautiful.background
    save_state.theming.primary_theme = beautiful.primary

    save(save_state)
end)

signals.connect_change_rounded_corner_dpi(function(dpi)
    if type(dpi) ~= "number" then
        return
    end

    if dpi == _G.save_state.rounded_corner then
        return
    end

    _G.save_state.rounded_corner = dpi
    save(save_state)
end)


signals.connect_enable_wallpaper_changer(function(bIsCycles, cycles, default)
    _G.save_state.wallpaper.cycle_mode = bIsCycles
    _G.save_state.wallpaper.cycles = cycles or {}

    if default ~= nil then
        _G.save_state.wallpaper.default_image = default
    end

    if not bIsCycles then
        for s in screen do
            gears.wallpaper.maximized(_G.save_state.wallpaper.default_image, s)
        end
    end

    save(save_state)
end)

signals.connect_vpn_connection_data(function(vpn)

    save_state.vpn_data = vpn

    save(save_state)
end)

signals.connect_save_plugins(function(plugins)
    save_state.plugins = plugins

    save(save_state)
end)


signals.connect_save_display_settings(function(monitor_id, res, refresh)
    print(type(monitor_id))
    print(type(res))
    print(type(refresh))

    if type(monitor_id) ~= "string" or type(res) ~= "string" or (type(refresh) ~= "string" and type(refresh) ~= "number") then
        return
    end

    save_state.display[monitor_id] = {
        resolution = res,
        refresh_rate = refresh
    }

    save(save_state)
end)

signals.connect_save_keyboard_data(function(keys)
    save_state.keyboard_shortcuts = keys

    save(save_state)
end)
