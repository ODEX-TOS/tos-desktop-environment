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

local wibox = require("wibox")
local naughty = require("naughty")

local card = require("lib-widget.card")
local button = require("lib-widget.button")

local icons = require("theme.icons")

local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local mod = require("configuration.keys.mod")

local common = require("lib-tde.function.common")
local capitalize = common.capitalize
local split = common.split

local signals = require("lib-tde.signals")

local sort = require("lib-tde.sort.mergesort")

local input = require("keyboard.input")

local function is_unique(keybind, name)
    for key, _ in pairs(mod.keybindings) do
        if key ~= name and mod.get_str_from_shortcut(key) == keybind then
            return false, key
        end
    end

    return true
end

-- If the keybind has a #N code in it translate it to the effective keybind
local function to_text_keybind(keybind)
    local splitted = split(keybind, "+")
    local text = ""

    for i, v in ipairs(splitted) do
        local _
        if v:find("#") then
            _, v = tde._get_key_name(v)
        end

        text = text .. v

        if i < #splitted then
            text = text .. "+"
        end
    end

    return text
end

-- Convert the keybind to a numberical, liternal keyevent on the keyboard instead of the keysym
-- This way when changing keyboard layouts the state remains the same
local function to_save_state(keybind)
    local splitted = split(keybind, "+")

    -- In case we are running in awesome instead of tde
    if tde == nil or tde._get_key_code == nil then return keybind end

    local res = ""

    for index, value in ipairs(splitted) do
        local code = tde._get_key_code(value)
        if code then
            res = res .. "#" .. code
        else
            res = res .. value
        end

        if index < #splitted then
            res = res .. "+"
        end
    end

    return res
end

local keyboard_cache = {}

local function create_keyboard_widget(shortcut)

    if keyboard_cache[shortcut.shortcut] then
        return keyboard_cache[shortcut.shortcut].widget
    end

    local textbox = wibox.widget.textbox(to_text_keybind(shortcut.keybind))

    local function update_keybind(keybind)
        textbox.text = to_text_keybind(keybind)

        _G.save_state.keyboard_shortcuts[shortcut.shortcut] = to_save_state(keybind)
        signals.emit_save_keyboard_data(_G.save_state.keyboard_shortcuts)
    end

    local btn = button({
        body = textbox,
        callback = function()
            print("Stopping existing grabber")
            input.stop_grabbing()
            input.start_grabbing(function(keybind)
                -- Verify that it is unique
                local unique, name = is_unique(keybind, shortcut.shortcut)
                if not unique then
                    naughty.notify({
                        title = "Keyboard Shortcuts",
                        message = "Your keyboard shortcut already exists for '" .. name .. "'",
                        timeout = 5,
                        urgency = 'critical',
                        icon = icons.keyboard
                    })

                    update_keybind(shortcut.keybind)
                    return
                end

                update_keybind(keybind)
            end)
        end
    })

    local box = wibox.widget {
        wibox.widget.textbox(capitalize(shortcut.shortcut)),
        wibox.container.margin(btn, dpi(5), dpi(5), dpi(5), dpi(5)),
        forced_height = dpi(40),
        layout = wibox.layout.flex.horizontal
    }


    keyboard_cache[shortcut.shortcut] = {
        widget =  wibox.container.margin(box,  dpi(10), dpi(10), 0, 0),
        update_keybind = update_keybind
    }

    return keyboard_cache[shortcut.shortcut].widget
end

local function generate_keyboard_list(shortcuts, start_index, end_index)
    local widget = wibox.layout.fixed.vertical()

    for i = start_index, end_index do
        widget:add(create_keyboard_widget(shortcuts[i]))
    end

    return widget
end

local function create()
    local card_widget = card()


    local shortcut = {}
    for key, _ in pairs(mod.keybindings) do
        table.insert(shortcut, {
            shortcut = key,
            keybind = mod.get_str_from_shortcut(key)
        })
    end

    shortcut = sort(shortcut, function (smaller, bigger)
        return smaller.shortcut < bigger.shortcut
    end)

    local keyboard_middle = math.ceil(#shortcut/2)

    local resetbtn = button({
        body = "reset",
        callback = function()
            for key, bind in pairs(mod.keybindings) do
                if keyboard_cache[key] ~= nil then
                    keyboard_cache[key].update_keybind(bind)
                end
            end
        end
    })

    local keyboard_list = wibox.widget {
        generate_keyboard_list(shortcut, 1, keyboard_middle),
        generate_keyboard_list(shortcut, keyboard_middle + 1, #shortcut),
        spacing = dpi(10),
        layout = wibox.layout.flex.horizontal
    }

    card_widget.update_body(wibox.widget {
        keyboard_list,
        wibox.container.margin(resetbtn, dpi(10), dpi(10), dpi(10), dpi(10)),
        spacing = dpi(10),
        layout = wibox.layout.fixed.vertical
    })

    local view = wibox.container.margin(card_widget, dpi(10), dpi(10))

    view.stop_view = function()
        print("Leaving keyboard")
        input.stop_grabbing()

        if _G.root.elements.settings.visible then
            _G.root.elements.settings_grabber:start()
        end
    end

    return view
end

return {
    icon = icons.keyboard,
    name = i18n.translate("Keyboard Shortcuts"),
    -- the settings menu expects a wibox
    widget = create()
  }