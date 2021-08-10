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

local dpi = require('beautiful').xresources.apply_dpi

local config_dir = require('gears').filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widget/notif-center/icons/'

local empty_notifbox = wibox.widget {
    {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5),
        {
            expand = 'none',
            layout = wibox.layout.align.horizontal,
            nil,
            {
                image = widget_icon_dir .. 'empty-notification' .. '.svg',
                resize = true,
                forced_height = dpi(35),
                forced_width = dpi(35),
                widget = wibox.widget.imagebox
            },
            nil
        },
        {
            text = i18n.translate('Empty.'),
            font = 'Inter Bold 14',
            align = 'center',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        {
            text = i18n.translate('Come back later.'),
            font = 'Inter Regular 10',
            align = 'center',
            valign = 'center',
            widget = wibox.widget.textbox
        }
    },
    margins = dpi(20),
    widget = wibox.container.margin

}

local separator_for_empty_msg = wibox.widget {
    orientation = 'vertical',
    opacity = 0.0,
    widget = wibox.widget.separator
}

-- Make empty_notifbox center
local centered_empty_notifbox = wibox.widget {
    layout = wibox.layout.align.vertical,
    forced_height = dpi(150),
    expand = 'none',
    separator_for_empty_msg,
    empty_notifbox,
    separator_for_empty_msg
}

return centered_empty_notifbox

