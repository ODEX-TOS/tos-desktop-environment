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
local signals = require("lib-tde.signals")
local profile_pic = require('lib-widget.profilebox')

local format_item = function(widget)
	local _widget = wibox.widget {
		{
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				nil,
				widget,
				nil
			},
			margins = dpi(10),
			widget = wibox.container.margin
		},
		forced_height = dpi(88),
		bg = beautiful.groups_bg,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, _G.save_state.rounded_corner/2)
		end,
		widget = wibox.container.background
	}

	signals.connect_change_rounded_corner_dpi(function(radius)
		_widget.shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, radius/2)
		end
	end)

	return _widget
end

local format_item_no_fix_height = function(widget)
	local _widget = wibox.widget {
		{
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				nil,
				widget,
				nil
			},
			margins = dpi(10),
			widget = wibox.container.margin
		},
		bg = beautiful.groups_bg,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, _G.save_state.rounded_corner/2)
		end,
		widget = wibox.container.background
	}

	signals.connect_change_rounded_corner_dpi(function(radius)
		_widget.shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, radius/2)
		end
	end)

	return _widget
end

local vertical_separator =  wibox.widget {
	orientation = 'vertical',
	forced_height = dpi(1),
	forced_width = dpi(1),
	span_ratio = 0.55,
	widget = wibox.widget.separator
}

local username = wibox.widget {
	text = "",
	widget = wibox.widget.textbox
}

local picture = profile_pic(10)

signals.connect_username(function(name)
	username.text = name
end)

signals.connect_profile_picture_changed(function(pic)
	picture.update(pic)
end)

signals.emit_request_user()
signals.emit_request_profile_pic()

local control_center_row_one = wibox.widget {
	layout = wibox.layout.align.horizontal,
	forced_height = dpi(48),
	nil,
	format_item(
		wibox.widget {
			layout = wibox.layout.align.horizontal,
			picture,
			nil,
			username
		}
	),
	{
		format_item(
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10),
				require('widget.control-center-switch')(),
				vertical_separator,
				require('widget.end-session')()
			}
		),
		left = dpi(10),
		widget = wibox.container.margin
	}
}

local main_control_row_two = wibox.widget {
	layout = wibox.layout.flex.horizontal,
	spacing = dpi(10),
	format_item_no_fix_height(
		{
			layout = wibox.layout.fixed.vertical,
			spacing = dpi(5),
			require('widget.bluetooth-toggle'),
		}
	),
	{
		layout = wibox.layout.flex.vertical,
		spacing = dpi(10),
		format_item_no_fix_height(
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				nil,
				require('widget.dont-disturb'),
				nil
			}
		),
		format_item_no_fix_height(
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				nil,
				require('widget.blur-toggle'),
				nil
			}
		)
	}
}

local main_control_row_sliders = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(10),
	format_item(
		{
			require('widget.blur-slider'),
			margins = dpi(10),
			widget = wibox.container.margin
		}
	),
	format_item(
		{
			require('widget.brightness-slider'),
			margins = dpi(10),
			widget = wibox.container.margin
		}
	),
	format_item(
		{
			require('widget.volume-slider'),
			margins = dpi(10),
			widget = wibox.container.margin
		}
	)
}

local monitor_control_row_progressbars = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	spacing = dpi(10),
	format_item(
		require('widget.cpu-meter')
	),
	format_item(
		require('widget.ram-meter')
	),
	format_item(
		require('widget.temperature-meter')
	),
	format_item(
		require('widget.harddrive-meter')
	)
}

local control_center = function(s)
	-- Set the control center geometry
	local panel_width = dpi(400)

	local _widget = wibox.widget {
		{
			{
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(10),
				control_center_row_one,
				{
					layout = wibox.layout.stack,
					{
						id = 'main_control',
						visible = true,
						layout = wibox.layout.fixed.vertical,
						spacing = dpi(10),
						main_control_row_two,
						main_control_row_sliders,
					},
					{
						id = 'monitor_control',
						visible = false,
						layout = wibox.layout.fixed.vertical,
						spacing = dpi(10),
						monitor_control_row_progressbars
					}
				}
			},
			margins = dpi(16),
			widget = wibox.container.margin
		},
		id = 'control_center',
		bg = beautiful.background.hue_800 .. beautiful.background_transparency,
		shape =function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
		end,
		widget = wibox.container.background
	}

	signals.connect_background_theme_changed(function(pallet)
		_widget.bg = pallet.hue_800 .. beautiful.background_transparency
	end)

	local panel = awful.popup {
		widget = _widget,
		screen = s,
		type = 'dock',
		visible = false,
		ontop = true,
		width = dpi(panel_width),
		maximum_width = dpi(panel_width),
		maximum_height = dpi(s.geometry.height - 38),
		bg = beautiful.transparent,
		fg = beautiful.fg_normal,
		shape = gears.shape.rectangle
	}

	awful.placement.top_right(
		panel,
		{
			honor_workarea = true,
			parent = s,
			margins = {
				top = dpi(33),
				right = dpi(5)
			}
		}
	)

	panel.opened = false

	s.backdrop_control_center = wibox {
		ontop = true,
		screen = s,
		bg = beautiful.transparent,
		type = 'utility',
		x = s.geometry.x,
		y = s.geometry.y,
		width = s.geometry.width,
		height = s.geometry.height
	}

	local open_panel = function()
		s.backdrop_control_center .visible = true
		s.control_center.visible = true


		awful.placement.top_right(
			panel,
			{
				honor_workarea = true,
				parent = s,
				margins = {
					top = dpi(33),
					right = dpi(5)
				}
			}
		)

		panel:emit_signal('opened')
	end

	local close_panel = function()
		s.control_center.visible = false
		s.backdrop_control_center.visible = false

		panel:emit_signal('closed')
	end

	-- Hide this panel when app dashboard is called.
	function panel:hide_dashboard()
		close_panel()
	end

	function panel:toggle()
		self.opened = not self.opened
		if self.opened then
			open_panel()
		else
			close_panel()
		end
	end

	s.backdrop_control_center:buttons(
		awful.util.table.join(
			awful.button(
				{},
				1,
				nil,
				function()
					panel:toggle()
				end
			)
		)
	)

	return panel
end

return control_center
