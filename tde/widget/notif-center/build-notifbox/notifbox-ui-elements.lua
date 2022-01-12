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
local wibox = require('wibox')
local beautiful = require('beautiful')
local naughty = require('naughty')
local gears = require('gears')

local dpi = beautiful.xresources.apply_dpi

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widget/notif-center/icons/'

local clickable_container = require('widget.material.clickable-container')

local ui_noti_builder = {}

-- Notification icon container
ui_noti_builder.notifbox_icon = function(ico_image)
    local noti_icon = wibox.widget {
        {
            id = 'icon',
            resize = true,
            forced_height = dpi(25),
            forced_width = dpi(25),
            widget = wibox.widget.imagebox
        },
        layout = wibox.layout.fixed.horizontal
    }
    noti_icon.icon:set_image(ico_image)
    return noti_icon
end

-- Notification title container
ui_noti_builder.notifbox_title = function(title)
    return wibox.widget {
        markup = title,
        font = 'Inter Bold 12',
        align = 'left',
        valign = 'center',
        widget = wibox.widget.textbox
    }
end

-- Notification message container
ui_noti_builder.notifbox_message = function(msg)
    return wibox.widget {
        markup = msg,
        font = 'Inter Regular 11',
        align = 'left',
        valign = 'center',
        widget = wibox.widget.textbox
    }
end

-- Notification app name container
ui_noti_builder.notifbox_appname = function(app)
    return wibox.widget {
        markup = app,
        font = 'Inter Bold 12',
        align = 'left',
        valign = 'center',
        widget = wibox.widget.textbox
    }
end

-- Notification actions container
ui_noti_builder.notifbox_actions = function(n)
    local actions_template = wibox.widget {
        notification = n,
        base_layout = wibox.widget {
            spacing = dpi(0),
            layout = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            id = 'text_role',
                            font = 'Inter Regular 10',
                            widget = wibox.widget.textbox
                        },
                        widget = wibox.container.place
                    },
                    widget = clickable_container
                },
                bg = beautiful.groups_bg,
                shape = gears.shape.rounded_rect,
                forced_height = 30,
                widget = wibox.container.background
            },
            margins = 4,
            widget = wibox.container.margin
        },
        style = {underline_normal = false, underline_selected = true},
        widget = naughty.list.actions
    }

    return actions_template
end

-- Notification dismiss button
ui_noti_builder.notifbox_dismiss = function()

    local dismiss_imagebox = wibox.widget {
        {
            id = 'dismiss_icon',
            image = widget_icon_dir .. 'delete.svg',
            resize = true,
            forced_height = dpi(5),
            widget = wibox.widget.imagebox
        },
        layout = wibox.layout.fixed.horizontal
    }

    local dismiss_button = wibox.widget {
        {dismiss_imagebox, margins = dpi(5), widget = wibox.container.margin},
        widget = clickable_container
    }

    local notifbox_dismiss = wibox.widget {
        dismiss_button,
        visible = false,
        bg = beautiful.groups_title_bg,
        shape = gears.shape.circle,
        widget = wibox.container.background
    }

    return notifbox_dismiss
end

return ui_noti_builder
