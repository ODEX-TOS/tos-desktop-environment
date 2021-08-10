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
local gears = require('gears')
local beautiful = require('beautiful')
local signals   = require('lib-tde.signals')
local dpi = beautiful.xresources.apply_dpi
local icons = require('theme.icons')
local clickable_container = require('widget.clickable-container')
local slider = require('lib-widget.slider')

local action_name = wibox.widget {
	text = i18n.translate('Volume'),
	font = 'Inter Bold 10',
	align = 'left',
	widget = wibox.widget.textbox
}

local icon = wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = 'none',
	nil,
	{
		image = icons.volume,
		resize = true,
		widget = wibox.widget.imagebox
	},
	nil
}

local action_level = wibox.widget {
	{
		{
			icon,
			margins = dpi(5),
			widget = wibox.container.margin
		},
		widget = clickable_container,
	},
	bg = beautiful.groups_bg,
	shape = function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
	end,
	widget = wibox.container.background
}

local volume_slider = slider(0, 100, 1, _G.save_state.volume, function (value)
	signals.emit_volume(value)
end)

signals.connect_volume(function(value)
	if value ~= volume_slider.get_number() then
		volume_slider.update(value)
	end
end)

local _slider = wibox.widget {
	nil,
	volume_slider,
	nil,
	expand = 'none',
	forced_height = dpi(24),
	layout = wibox.layout.align.vertical
}

local volume_setting = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	forced_height = dpi(48),
	spacing = dpi(5),
	action_name,
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(5),
		{
			layout = wibox.layout.align.vertical,
			expand = 'none',
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				forced_height = dpi(24),
				forced_width = dpi(24),
				action_level
			},
			nil
		},
		_slider
	}
}

return volume_setting
