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
local beautiful = require("beautiful")
local gears = require("gears")
local signals = require("lib-tde.signals")

local function build(widget)
	local container =
		wibox.widget {
		widget,
		widget = wibox.container.background,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, _G.save_state.rounded_corner/3)
		end,
	}

	signals.connect_change_rounded_corner_dpi(function(radius)
        container.shape = function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, radius/3)
        end
    end)

	local old_cursor, old_wibox

	container:connect_signal(
		"mouse::enter",
		function()
			container.bg = beautiful.groups_bg
			-- no idea how to get the wibox from this signal's arguments...
			local w = mouse.current_wibox
			if w then
				old_cursor, old_wibox = w.cursor, w
				w.cursor = "hand1"
			end
		end
	)

	container:connect_signal(
		"mouse::leave",
		function()
			container.bg = beautiful.transparent
			if old_wibox then
				old_wibox.cursor = old_cursor
				old_wibox = nil
			end
		end
	)

	container:connect_signal(
		"button::press",
		function()
			container.bg = beautiful.groups_title_bg
		end
	)

	container:connect_signal(
		"button::release",
		function()
			container.bg = beautiful.groups_bg
		end
	)

	return container
end

return build
