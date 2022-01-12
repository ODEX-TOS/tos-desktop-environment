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
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widget/control-center-switch/icons/'
local clickable_container = require('widget.material.clickable-container')
local icons = require('theme.icons')
local monitor_mode = false

local return_button = function()

	local widget = wibox.widget {
		{
			id = 'icon',
			image = icons.memory,
			widget = wibox.widget.imagebox,
			resize = true
		},
		layout = wibox.layout.align.horizontal
	}

	local widget_button = wibox.widget {
		{
			{
				widget,
				margins = dpi(5),
				widget = wibox.container.margin
			},
			widget = clickable_container
		},
		bg = beautiful.transparent,
		shape = gears.shape.circle,
		widget = wibox.container.background
	}

	local control_center_switch_mode = function()
		local cc_widget = awful.screen.focused().control_center.widget
		if monitor_mode then
			widget.icon:set_image(icons.memory)
			cc_widget:get_children_by_id('main_control')[1].visible = true
			cc_widget:get_children_by_id('monitor_control')[1].visible = false
		else
			widget.icon:set_image(widget_icon_dir .. 'control-center.svg')
			cc_widget:get_children_by_id('main_control')[1].visible = false
			cc_widget:get_children_by_id('monitor_control')[1].visible = true
		end
		monitor_mode = not monitor_mode
	end

	widget_button:buttons(
		gears.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					control_center_switch_mode()
				end
			)
		)
	)

	return widget_button
end

return return_button
