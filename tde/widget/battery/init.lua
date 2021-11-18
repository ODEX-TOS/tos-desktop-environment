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
local wibox = require("wibox")

local gears = require("gears")
local signals = require("lib-tde.signals")

local clickable_container = require("widget.material.clickable-container")
local dpi = require("beautiful").xresources.apply_dpi

local widget_icon_dir = "/etc/xdg/tde/widget/battery/icons/"

local theme = require("theme.icons.dark-light")

local return_button = function()
	local battery_imagebox =
		wibox.widget {
		nil,
		{
			id = "icon",
			image = theme(widget_icon_dir .. "battery-standard" .. ".svg"),
			widget = wibox.widget.imagebox,
			resize = true
		},
		nil,
		expand = "none",
		layout = wibox.layout.align.vertical
	}

	local battery_percentage_text =
		wibox.widget {
		id = "percent_text",
		text = "100%",
		font = "SF Pro Text Bold 9",
		align = "center",
		valign = "center",
		visible = false,
		widget = wibox.widget.textbox
	}

	local battery_widget =
		wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(0),
		battery_imagebox,
		battery_percentage_text
	}

	local battery_button = clickable_container(wibox.container.margin(battery_widget, dpi(8), dpi(8), dpi(8), dpi(8)))

	local battery_tooltip =
		awful.tooltip {
		objects = {battery_button},
		text = "None",
		mode = "outside",
		align = "right",
		margin_leftright = dpi(8),
		margin_topbottom = dpi(8),
		font = "Mono 10",
		preferred_positions = {"right", "left", "top", "bottom"}
	}

	-- Get battery info script
	local get_battery_info = function()
		awful.spawn.easy_async_with_shell(
			"upower -i $(upower -e | grep BAT)",
			function(stdout)
				if not stdout:match("%W") then
					battery_tooltip:set_text("No battery detected!")
					return
				end

				-- Remove new line from the last line
				battery_tooltip:set_text(stdout:sub(1, -2))
			end
		)
	end

	-- Update tooltip on startup
	get_battery_info()

	-- Update tooltip on hover
	battery_widget:connect_signal(
		"mouse::enter",
		function()
			get_battery_info()
		end
	)

	local update_battery = function(charging, battery_percentage)
		print("Battery percentage: " .. tostring(battery_percentage))

		battery_widget.spacing = dpi(5)
		battery_percentage_text.visible = true
		battery_percentage_text:set_text(tostring(math.floor(battery_percentage)) .. "%")

		local icon_name = "battery"

		if not charging then
			if battery_percentage >= 0 and battery_percentage < 10 then
				icon_name = icon_name .. "-" .. "alert-red"
			elseif battery_percentage > 10 and battery_percentage < 20 then
				icon_name = icon_name .. "-" .. "10"
			elseif battery_percentage >= 20 and battery_percentage < 30 then
				icon_name = icon_name .. "-" .. "20"
			elseif battery_percentage >= 30 and battery_percentage < 50 then
				icon_name = icon_name .. "-" .. "30"
			elseif battery_percentage >= 50 and battery_percentage < 60 then
				icon_name = icon_name .. "-" .. "50"
			elseif battery_percentage >= 60 and battery_percentage < 80 then
				icon_name = icon_name .. "-" .. "60"
			elseif battery_percentage >= 80 and battery_percentage < 90 then
				icon_name = icon_name .. "-" .. "80"
			elseif battery_percentage >= 90 and battery_percentage < 100 then
				icon_name = icon_name .. "-" .. "90"
			elseif battery_percentage == 100 then
				icon_name = icon_name .. "-fully-charged"
			end
		else
			if battery_percentage > 0 and battery_percentage < 20 then
				icon_name = icon_name .. "-charging-" .. "10"
			elseif battery_percentage >= 20 and battery_percentage < 30 then
				icon_name = icon_name .. "-charging-"  .. "20"
			elseif battery_percentage >= 30 and battery_percentage < 50 then
				icon_name = icon_name .. "-charging-"  .. "30"
			elseif battery_percentage >= 50 and battery_percentage < 60 then
				icon_name = icon_name .. "-charging-" .. "50"
			elseif battery_percentage >= 60 and battery_percentage < 80 then
				icon_name = icon_name .. "-charging-" .. "60"
			elseif battery_percentage >= 80 and battery_percentage < 90 then
				icon_name = icon_name .. "-charging-" .. "80"
			elseif battery_percentage >= 90 and battery_percentage < 100 then
				icon_name = icon_name .. "-charging-" .. "90"
			elseif battery_percentage == 100 then
				icon_name = icon_name .. "-fully-charged"
			end
		end

		battery_imagebox.icon:set_image(gears.surface(theme(widget_icon_dir .. icon_name .. ".svg")))
	end

	local last_level = 0
	local last_charge_state = false

	signals.connect_battery(function(level)
		last_level = level or -1
		update_battery(last_charge_state, last_level)
	end)

	signals.connect_battery_charging(function(isCharging)
		last_charge_state = isCharging
		update_battery(last_charge_state, last_level)
	end)

	return battery_button
end
return return_button
