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
local top_panel = require('layout.top-panel')
local control_center = require('layout.control-center')
local info_center = require('layout.info-center')
local hide = require("lib-widget.auto_hide")

local bottom_panel = require('layout.bottom-panel')
local left_panel = require('layout.left-panel')
local right_panel = require('layout.right-panel')


local signals = require('lib-tde.signals')

local topBarDraw = general["top_bar_draw"] or "all"
local tagBarDraw = general["tag_bar_draw"] or "main"
local anchorTag = general["tag_bar_anchor"] or "bottom"

local function anchor(s)
	if tagBarDraw == "none" then
		return
	end

	if tagBarDraw == "main" and s.index ~= 1 then
		return
	end

	if anchorTag == "bottom" then
	  -- Create the bottom bar
	  s.bottom_panel = hide({
		  wibox = bottom_panel(s)
		})
	elseif anchorTag == "right" then
	  s.bottom_panel = hide({
		  wibox = right_panel(s, topBarDraw == "none")
	  })
	else
	  s.bottom_panel = hide({
			wibox = left_panel(s, topBarDraw == "none")
		})
	end
end

local function panel(s)
	if topBarDraw == "none" then
		top_panel(s, true)
		return
	end

	if topBarDraw == "main" and s.index ~= 1 then
		top_panel(s, true)
		return
	end

	s.top_panel = hide({ wibox = top_panel(s) })
end

signals.connect_anchor_changed(function(_anchor)
	-- we don't need to recreate the wiboxes
	if _anchor == anchorTag then
		return
	end

	anchorTag = _anchor or "bottom"

	for s in screen do
		if s.bottom_panel and s.bottom_panel.auto_hider then
			s.bottom_panel.auto_hider.remove()
			s.bottom_panel.auto_hider = nil
		end
		if s.bottom_panel ~= nil then
			s.bottom_panel.visible = false
			s.bottom_panel = nil
			collectgarbage("collect")
		end
		anchor(s)
	end
end)

-- Create a wibox panel for each screen and add it
screen.connect_signal(
	'request::desktop_decoration',
		function(s)
		s.control_center = control_center(s)
		s.info_center = info_center(s)
		s.control_center_show_again = false
		s.info_center_show_again = false

		panel(s)

		anchor(s)
	end
)

-- Hide bars when app go fullscreen
local function update_bars_visibility()
	for s in screen do
		if s.selected_tag then
			local fullscreen = s.selected_tag.fullscreen_mode
			-- Order matter here for shadow
			if s.top_panel ~= nil then
				s.top_panel.visible = not fullscreen
			end

			if s.bottom_panel ~= nil then
				s.bottom_panel.visible = not fullscreen
			end
			if s.control_center then
				if fullscreen and s.control_center.visible then
					s.control_center:toggle()
					s.control_center_show_again = true
				elseif not fullscreen and not s.control_center.visible and s.control_center_show_again then
					s.control_center:toggle()
					s.control_center_show_again = false
				end
			end
			if s.info_center then
				if fullscreen and s.info_center.visible then
					s.info_center:toggle()
					s.info_center_show_again = true
				elseif not fullscreen and not s.info_center.visible and s.info_center_show_again then
					s.info_center:toggle()
					s.info_center_show_again = false
				end
			end
		end
	end
end

tag.connect_signal(
	'property::selected',
	function(_)
		update_bars_visibility()
	end
)

client.connect_signal(
	'property::fullscreen',
	function(c)
		if c.first_tag then
			c.first_tag.fullscreen_mode = c.fullscreen
		end
		update_bars_visibility()
	end
)

client.connect_signal(
	'unmanage',
	function(c)
		if c.fullscreen then
			c.screen.selected_tag.fullscreen_mode = false
			update_bars_visibility()
		end
	end
)
