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
local beautiful = require("beautiful")
local apps = require("configuration.apps")
local icons = require("theme.icons")
local hotkeys_popup = require("awful.hotkeys_popup").widget

local mousedrag = nil
local started = false

if not (general["disable_desktop"] == "1") then
	mousedrag = require("module.mousedrag")
end

local terminal = apps.default.terminal
local web_browser = os.getenv("BROWSER") or apps.default.web_browser
local file_manager = apps.default.file_manager
local text_editor = apps.default.editor

beautiful.menu_font = "Iosevka Custom Regular 10"
beautiful.menu_height = 34
beautiful.menu_width = 180
beautiful.menu_bg_focus = beautiful.primary.hue_600 -- add a bit of transparency
beautiful.menu_bg_normal = "#00000044"
beautiful.menu_submenu = "➤"
beautiful.menu_border_width = 20
beautiful.menu_border_color = "#00000075"

-- Create a launcher widget and a main menu
local myawesomemenu = {
	{
		i18n.translate("Hotkeys"),
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end
	},
	{i18n.translate("Open settings application"), function() root.elements.settings.enable_view_by_index(-1, mouse.screen) end},
	{i18n.translate("Restart"), awesome.restart},
	{
		i18n.translate("Quit"),
		function()
			awesome.quit()
		end
	}
}


local mymainmenu

local function gen_menu()
	local freedesktop = require("freedesktop")
	local menubar = require("menubar")

	local photo = menubar.utils.lookup_icon("camera-photo")

	-- Screenshot menu
	local screenshot = {
		{
			i18n.translate("Full"),
			function()
			awful.spawn.easy_async_with_shell(
				apps.bins().full_screenshot,
				function(out)
					print("Full screenshot\n" .. out)
				end
			)
		end,
		photo
	},
	{
		i18n.translate("Area"),
		function()
			awful.spawn.easy_async_with_shell(
				apps.bins().area_screenshot,
				function(out)
					print("Area screenshot\n" .. out)
				end
			)
		end,
		photo
	}
}


	mymainmenu = freedesktop.menu.build(
		{
			-- Not actually the size, but the quality of the icon
			icon_size = 48,
			before = {
				{i18n.translate("Terminal"), terminal, menubar.utils.lookup_icon("utilities-terminal")},
				{i18n.translate("Web browser"), web_browser, menubar.utils.lookup_icon("webbrowser-app")},
				{i18n.translate("File Manager"), file_manager, menubar.utils.lookup_icon("system-file-manager")},
				{i18n.translate("Text Editor"), text_editor, menubar.utils.lookup_icon("accessories-text-editor")}
				-- other triads can be put here
			},
			after = {
				{"TDE", myawesomemenu, icons.logo},
				{i18n.translate("Screenshot"), screenshot, photo},
				{
					i18n.translate("End Session"),
					function()
						print("Showing exit screen")
						_G.exit_screen_show()
					end,
					menubar.utils.lookup_icon("system-shutdown")
				}
				-- other triads can be put here
			}
		}
	)
	awful.widget.launcher({image = beautiful.awesome_icon, menu = mymainmenu})
end


-- Embed mouse bindings
root.buttons(
	gears.table.join(
		awful.button(
			{},
			3,
			function()
				-- only generate the menu when first needed
				if mymainmenu == nil then
					gen_menu()
				end
				mymainmenu:toggle()
			end
		),
		awful.button(
			{},
			1,
			function()
				if mymainmenu ~= nil then
					mymainmenu:hide()
				end
				if not (general["disable_desktop"] == "1") then
					mousedrag.start()
					started = true
				end
			end,
			function()
				if not (general["disable_desktop"] == "1") and started then
					mousedrag.stop()
				end
			end
		)
	)
)
