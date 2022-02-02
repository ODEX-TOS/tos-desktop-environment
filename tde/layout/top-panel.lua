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
local hardware = require('lib-tde.hardware-check')
local keyboard_layout = require("widget.keyboard")
local mat_colors = require("theme.mat-colors")
local icons = require("theme.icons")

local plugins = require("lib-tde.plugin-loader")("topbar")

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
	local live_system_banner
	hardware.has_package_installed("installer", function(bInstallerInstalled)
		if not bInstallerInstalled then
			return
		end
		live_system_banner = wibox {
			ontop = true,
			visible = true,
			screen = s,
			type = 'dock',
			height = panel.height,
			width = s.geometry.width,
			x = s.geometry.x,
			y = s.geometry.y + panel.height,
			stretch = false,
			bg = mat_colors.red.hue_800 .. beautiful.background_transparency,
			fg = beautiful.fg_normal,
			cursor = 'hand1'
		}

		live_system_banner:struts
		{
			top = panel.height * 2
		}

		live_system_banner:connect_signal(
			'mouse::enter',
			function()
				local w = mouse.current_wibox
				if w then
					w.cursor = 'hand1'
				end
			end
		)

		live_system_banner:connect_signal(
			'button::press',
			function()
				awful.spawn("calamares", false)
			end
		)

		live_system_banner : setup {
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			wibox.container.margin(
				wibox.widget.imagebox(icons.warning),
				dpi(10),
				0,
				dpi(2),
				dpi(2)
			),
			wibox.widget.textbox(i18n.translate("This is a live system, no information will be saved after restarting this device. To install the full system please click me!")),
			nil
		}
	end)

	signals.connect_background_theme_changed(function(pallet)
		panel.bg = pallet.hue_800 .. beautiful.background_transparency
	end)

	signals.connect_refresh_screen(function()
		panel.x = s.geometry.x
		panel.y = s.geometry.y
		panel.width = s.geometry.width

		if live_system_banner ~= nil then
			live_system_banner.x = s.geometry.x
			live_system_banner.y = s.geometry.y + panel.height
			live_system_banner.width = s.geometry.width
		end
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
	s.control_center_toggle = require('widget.control-center-toggle')()
	s.global_search			= require('widget.global-search')()
	s.info_center_toggle 	= require('widget.info-center-toggle')()
	s.about 				= require('widget.about')(s)
	s.keyboard_layout		= keyboard_layout(s)


	local right_widget = wibox.widget {
			layout = wibox.layout.fixed.horizontal,
			spacing = dpi(5),
			wibox.widget.base.empty_widget(),
	}

	local function add_to_panel(name, index, callback)
		index = index or #right_widget.children

		if index > #right_widget.children then
			index = #right_widget.children
		end

		if index < 1 then
			index = 1
		end


		local widget = s[name]

		if widget == nil then
			return
		end

		if callback then
			widget = callback(widget)
		end

		if index ~= nil then
			right_widget:insert(index, widget)
		else
			right_widget:add(widget)
		end
	end

	add_to_panel("systray", nil, function(widget)
		return wibox.widget {
			widget,
			margins = dpi(5),
			widget = wibox.container.margin
		}
	end)

	add_to_panel("tray_toggler")

	local function add_plugin(plugin, index)
		if type(plugin) == "table" and plugin.__plugin_name ~= nil and plugin.plugin ~= nil then
			s[plugin.__plugin_name] = plugin.plugin
		elseif type(plugin) == "table" and plugin.__plugin_name ~= nil then
			s[plugin.__plugin_name] = plugin
		end

		add_to_panel(plugin.__plugin_name, index)
	end


	for _, plugin in ipairs(plugins) do
		add_plugin(plugin)
	end

	signals.connect_add_plugin(function(location, plugin)
		if location ~= "topbar" then
			return
		end

		add_plugin(plugin, 3)
	end)

	add_to_panel("keyboard_layout")
	add_to_panel("updater")
	add_to_panel("about")
	add_to_panel("control_center_toggle")
	add_to_panel("global_search")
	add_to_panel("info_center_toggle")


	hardware.hasBluetooth(function(bHasBluetooth)
		if  bHasBluetooth then
			s.bluetooth   = require('widget.bluetooth')
			add_to_panel("bluetooth", #plugins + 4)
		end
	end)


	if hardware.hasWifi() then
		s.network  = require('widget.wifi')
		add_to_panel("network", #plugins + 4)
	end

	if hardware.hasBattery() then
		s.battery = require('widget.battery')()
		add_to_panel("battery", #plugins + 4)
	end

	hardware.hasFFMPEG(function (hasFFMPEG)
		if hasFFMPEG and hardware.hasSound() then
			s.music = require('widget.music')
			add_to_panel("music", #plugins + 4)
		end
	end)




	panel : setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			layout = wibox.layout.fixed.horizontal,
			task_list(s),
			add_button
		},
		clock,
		right_widget
	}

	return panel
end

return top_panel
