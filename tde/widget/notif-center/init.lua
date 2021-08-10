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
local dpi = beautiful.xresources.apply_dpi

local notif_header = wibox.widget {
	text   = i18n.translate('Notification Center'),
	font   = 'Inter Bold 14',
	align  = 'left',
	valign = 'center',
	widget = wibox.widget.textbox
}

local notif_center = function(s)

	s.clear_all = require('widget.notif-center.clear-all')
	s.notifbox_layout = require('widget.notif-center.build-notifbox').notifbox_layout

	return wibox.widget {
		{
			{
				expand = 'none',
				layout = wibox.layout.fixed.vertical,
				spacing = dpi(10),
				{
					layout = wibox.layout.align.horizontal,
					expand = 'none',
					notif_header,
					nil,
					s.clear_all
				},
				s.notifbox_layout
			},
			margins = dpi(10),
			widget = wibox.container.margin
		},
		bg = beautiful.groups_bg,
		shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
		end,
		widget = wibox.container.background
	}
end

return notif_center