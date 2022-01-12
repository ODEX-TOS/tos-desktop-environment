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
local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require('widget.material.clickable-container')
local widget_dir = '/etc/xdg/tde/widget/blur-toggle/'
local widget_icon_dir = widget_dir .. 'icons/'
local signals = require('lib-tde.signals')

local blur_status = true

local action_name = wibox.widget {
    text = 'Blur Effects',
    font = 'Inter Bold 10',
    align = 'left',
    widget = wibox.widget.textbox
}

local action_status = wibox.widget {
    text = 'Off',
    font = 'Inter Regular 10',
    align = 'left',
    widget = wibox.widget.textbox
}

local action_info = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    action_name,
    action_status
}

local button_widget = wibox.widget {
    {
        id = 'icon',
        image = widget_icon_dir .. 'effects.svg',
        widget = wibox.widget.imagebox,
        resize = true
    },
    layout = wibox.layout.align.horizontal
}

local widget_button = wibox.widget {
    {
        {
            button_widget,
            margins = dpi(15),
            forced_height = dpi(48),
            forced_width = dpi(48),
            widget = wibox.container.margin
        },
        widget = clickable_container
    },
    bg = beautiful.groups_bg,
    shape = gears.shape.circle,
    widget = wibox.container.background
}

local update_widget = function()
    if blur_status then
        action_status:set_text('On')
        widget_button.bg = beautiful.primary.hue_600
    else
        action_status:set_text('Off')
        widget_button.bg = beautiful.groups_bg
    end
end

signals.connect_primary_theme_changed(function(pallet)
    if blur_status then
        widget_button.bg = pallet.hue_600
    else
        widget_button.bg = beautiful.groups_bg
    end
end)

local check_blur_status = function()
    awful.spawn.easy_async_with_shell([[bash -c "
		grep -F 'method = \"none\";' $HOME/picom.conf | tr -d '[\"\;\=\ ]'
		"]], function(stdout, _)
        if stdout:match('methodnone') then
            blur_status = false
        else
            blur_status = true
        end
        update_widget()
    end)
end

check_blur_status()

local toggle_blur = function(bIsDisabled)

    local toggle_blur_script_on =
        [[bash -c "sed -i -e 's/method = \"none\"/method = \"dual_kawase\"/g' \"$HOME/.config/picom.conf\""]]
    local toggle_blur_script_off =
        [[bash -c "sed -i -e 's/method = \"dual_kawase\"/method = \"none\"/g' \"$HOME/.config/picom.conf\""]]

    if bIsDisabled then
        print(toggle_blur_script_on)
        awful.spawn(toggle_blur_script_on, false)
    else
        print(toggle_blur_script_off)
        awful.spawn(toggle_blur_script_off, false)
    end
end

local toggle_blur_fx = function()
    blur_status = not blur_status
    toggle_blur(blur_status)
    update_widget()
end

widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
    toggle_blur_fx()
end)))

action_info:buttons(gears.table.join(awful.button({}, 1, nil, function()
    toggle_blur_fx()
end)))

local action_widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(10),
    widget_button,
    {
        layout = wibox.layout.align.vertical,
        expand = 'none',
        nil,
        action_info,
        nil
    }
}

awesome.connect_signal('widget::blur:toggle', function() toggle_blur_fx() end)

return action_widget
