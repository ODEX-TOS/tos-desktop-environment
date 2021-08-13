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
local signals = require('lib-tde.signals')
local dpi = beautiful.xresources.apply_dpi

local plugins = require("lib-tde.plugin-loader")("notification")


local info_center = function(s)
	-- Set the info center geometry
	local panel_width = dpi(350)

	local notif_layout = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		forced_width = dpi(panel_width),
		spacing = dpi(10),
	}

	local plugin_layout = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		forced_width = dpi(panel_width),
		spacing = dpi(10),
	}

	notif_layout:add(require('widget.notif-center')(s))

	for _, plugin in ipairs(plugins) do
		plugin_layout:add(plugin)
	end

	local _widget

	print("Info center plugins: " .. tostring(#plugins))

	if #plugins > 0 then
		_widget = wibox.widget {
			wibox.widget {
				{
					notif_layout,
					margins = dpi(10),
					widget = wibox.container.margin
				},
				nil,
				{
					plugin_layout,
					margins = dpi(10),
					widget = wibox.container.margin
				},
				spacing = dpi(10),
				layout = wibox.layout.fixed.horizontal
			},
			id = 'info_center',
			bg = beautiful.background.hue_800 .. beautiful.background_transparency,
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
			end,
			widget = wibox.container.background
		}
	else
		_widget = wibox.widget {
			wibox.widget {
				notif_layout,
				margins = dpi(10),
				widget = wibox.container.margin
			},
			id = 'info_center',
			bg = beautiful.background.hue_800 .. beautiful.background_transparency,
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
			end,
			widget = wibox.container.background
		}
	end


	signals.connect_background_theme_changed(function(pallet)
		_widget.bg = pallet.hue_800 .. beautiful.background_transparency
	end)

	local panel = awful.popup {
		widget = _widget,
		screen = s,
		type = 'dock',
		visible = false,
		ontop = true,
		width = dpi(panel_width*2),
		maximum_width = dpi(panel_width*2),
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

	s.backdrop_info_center = wibox {
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
		s.backdrop_info_center.visible = true
		s.info_center.visible = true

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
		s.info_center.visible = false
		s.backdrop_info_center.visible = false

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

	s.backdrop_info_center:buttons(
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

return info_center
