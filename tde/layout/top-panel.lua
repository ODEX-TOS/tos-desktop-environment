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
local signals = require('lib-tde.signals')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local task_list = require('widget.task-list')

local top_panel = function(s)

	local panel = wibox
	{
		ontop = true,
		screen = s,
		type = 'dock',
		height = dpi(28),
		width = s.geometry.width,
		x = s.geometry.x,
		y = s.geometry.y,
		stretch = false,
		bg = beautiful.background.hue_800 .. beautiful.background_transparency,
		fg = beautiful.fg_normal
	}

	signals.connect_background_theme_changed(function(pallet)
		panel.bg = pallet.hue_800 .. beautiful.background_transparency
	end)

	signals.connect_refresh_screen(function()
		panel.x = s.geometry.x
		panel.y = s.geometry.y
		panel.width = s.geometry.width
	end)

	panel:struts
	{
		top = dpi(28)
	}

	panel:connect_signal(
		'mouse::enter',
		function()
			local w = mouse.current_wibox
			if w then
				w.cursor = 'left_ptr'
			end
		end
	)

	s.systray = wibox.widget {
		visible = false,
		base_size = dpi(20),
		horizontal = true,
		screen = 'primary',
		widget = wibox.widget.systray
	}

	local clock 			= require('widget.clock')(s)
	local add_button 		= require('widget.open-default-app')(s)
	s.tray_toggler  		= require('widget.tray-toggle')
	s.updater 				= require('widget.package-updater')
	--s.screen_rec 			= require('widget.screen-recorder')()
	s.bluetooth   			= require('widget.bluetooth')
	s.battery     			= require('widget.battery')()
	s.network       		= require('widget.wifi')
	s.control_center_toggle = require('widget.control-center-toggle')()
	s.global_search			= require('widget.global-search')()
	s.info_center_toggle 	= require('widget.info-center-toggle')()
	s.music					= require('widget.music')
	s.about 				= require('widget.about')(s)
	s.countdown				= require('widget.countdown')

	panel : setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			layout = wibox.layout.fixed.horizontal,
			task_list(s),
			add_button
		},
		clock,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
			{
				s.systray,
				margins = dpi(5),
				widget = wibox.container.margin
			},
			s.tray_toggler,
			s.countdown,
			s.updater,
			s.screen_rec,
			s.network,
			s.bluetooth,
			s.battery,
			s.music,
			s.about,
			s.control_center_toggle,
			s.global_search,
			s.info_center_toggle
		}
	}

	return panel
end

return top_panel
