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
local clickable_container = require('widget.clickable-container')

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widget/notif-center/icons/'

local notifbox_core = require('widget.notif-center.build-notifbox')
local reset_notifbox_layout = notifbox_core.reset_notifbox_layout

local clear_all_imagebox = wibox.widget {
	{
		image = widget_icon_dir .. 'clear_all.svg',
		resize = true,
		forced_height = dpi(17),
		forced_width = dpi(17),
		widget = wibox.widget.imagebox,
	},
	layout = wibox.layout.fixed.horizontal
}

local clear_all_button = wibox.widget {
	{
		clear_all_imagebox,
		margins = dpi(5),
		widget = wibox.container.margin
	},
	widget = clickable_container
}

clear_all_button:buttons(
	gears.table.join(
		awful.button(
			{},
			1,
			nil,
			function()
				reset_notifbox_layout()
			end
		)
	)
)

local clear_all_button_wrapped = wibox.widget {
	nil,
	{
		clear_all_button,
		bg = beautiful.transparent,
		shape = gears.shape.circle,
		widget = wibox.container.background
	},
	nil,
	expand = 'none',
	layout = wibox.layout.align.vertical
}

return clear_all_button_wrapped