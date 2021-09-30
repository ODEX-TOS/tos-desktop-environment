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
local awful = require('awful')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local icons = require('theme.icons')
local clickable_container = require('widget.clickable-container')
local slider = require("lib-widget.slider")

local filehandle = require('lib-tde.file')

local picom_file = os.getenv("HOME") .. '/.config/picom.con'

local action_name = wibox.widget {
	text = i18n.translate('Blur Strength'),
	font = 'Inter Bold 10',
	align = 'left',
	widget = wibox.widget.textbox
}

local icon = wibox.widget {
	layout = wibox.layout.align.vertical,
	expand = 'none',
	nil,
	{
		image = icons.brush,
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

-- TODO: Make it work using filehandle
local adjust_blur = function(power)

	awful.spawn.with_shell(
		[[bash -c "
		sed -i 's/.*strength = .*/    strength = ]] .. power .. [[;/g' \
		$HOME/.config/picom.conf
		"]]
	)
end

local blur_slider = slider({
	max = 25,
	default = 20,
	callback = function (value)
		adjust_blur(value)
	end
})
blur_slider.forced_height = dpi(24)


local update_slider_value = function()
	local lines = filehandle.lines(picom_file)

	for _, line in ipairs(lines) do
		local match = string.match(line, '^strength = *(%d+)')
		if match ~= nil then
			blur_slider.update(tonumber(match))
		end
	end

end

-- Update on startup
update_slider_value()

local _slider = wibox.widget {
	nil,
	blur_slider,
	nil,
	expand = 'none',
	forced_height = dpi(24),
	layout = wibox.layout.align.vertical
}

local blur_setting = wibox.widget {
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

return blur_setting
