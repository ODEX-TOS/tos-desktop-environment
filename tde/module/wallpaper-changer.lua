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

local gears = require("gears")
local signals = require("lib-tde.signals")

local function wallpaper(paper)
	_G.save_state.wallpaper.default_image = paper

	-- force save of the settings
	signals.emit_save_developer_settings()

	for s in screen do
		gears.wallpaper.maximized(paper, s)
	end
end

local function set_wallpaper(time, cycles)
	for _, v in ipairs(cycles) do
		if v.hour == time then
			wallpaper(v.image)
		end
	end
end

local function callback(mode, cycles)
	mode = mode or _G.save_state.wallpaper.cycle_mode
	cycles = cycles or _G.save_state.wallpaper.cycles

	if mode then
		local time = tonumber(os.date("%H"))
		set_wallpaper(time, cycles)
	end
end

local timer = gears.timer{
	timeout = 3600,
	autostart = false,
	call_now = true,
	callback = callback
}

local delay =  3600 - (tonumber(os.date("%M")) * 60 + tonumber(os.date("%S")))

print(string.format("Enqueuing wallpaper changer module for %s seconds", delay))

gears.timer.start_new (delay, function ()
	print("Starting wallpaper changer module")
	timer:start()
end)

local function set_latest_paper(cycles)
	cycles = cycles or _G.save_state.wallpaper.cycles

	local time = tonumber(os.date("%H"))

	local paper = _G.save_state.wallpaper.default_image
	-- find the current wallpaper needed
	for _, value in ipairs(cycles) do
		if value.hour <= time then
			paper = value.image
		end
	end

	wallpaper(paper)
end

signals.connect_enable_wallpaper_changer(function(bIsCycles, cycles)
	if not bIsCycles then return end

	set_latest_paper(cycles)
end)


screen.connect_signal(
	'request::wallpaper',
	function(s)
		if _G.save_state.wallpaper.cycle_mode then
			set_latest_paper()
		else
			if _G.save_state.wallpaper.default_image then
				gears.wallpaper.maximized(_G.save_state.wallpaper.default_image, s)
			else
				gears.wallpaper.maximized(require("beautiful").wallpaper, s)
			end
		end
	end
)