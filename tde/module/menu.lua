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
local mousedrag = require("module.mousedrag")

terminal = apps.default.terminal
web_browser = os.getenv("BROWSER") or apps.default.web_browser
file_manager = apps.default.file_manager
text_editor = apps.default.editor
editor_cmd = terminal .. " -e " .. (os.getenv("EDITOR") or "nano")

beautiful.menu_font = "Iosevka Custom Regular 10"
beautiful.menu_height = 34
beautiful.menu_width = 180
beautiful.menu_bg_focus = beautiful.primary.hue_600 -- add a bit of transparenty
beautiful.menu_bg_normal = "#00000044"
beautiful.menu_submenu = "➤"
beautiful.menu_border_width = 20
beautiful.menu_border_color = "#00000075"

-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"Hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end
	},
	{"Edit config", editor_cmd .. " " .. awesome.conffile},
	{"Restart", awesome.restart},
	{
		"Quit",
		function()
			awesome.quit()
		end
	}
}

-- Screenshot menu
local screenshot = {
	{
		"Full",
		function()
			awful.spawn.easy_async_with_shell(
				apps.bins.full_screenshot,
				function(out)
					print("Full screenshot\n" .. out)
				end
			)
		end
	},
	{
		"Area",
		function()
			awful.spawn.easy_async_with_shell(
				apps.bins.area_screenshot,
				function(out)
					print("Area screenshot\n" .. out)
				end
			)
		end
	}
}

local freedesktop = require("freedesktop")
local menubar = require("menubar")

mymainmenu =
	freedesktop.menu.build(
	{
		-- Not actually the size, but the quality of the icon
		icon_size = 48,
		before = {
			{"Terminal", terminal, menubar.utils.lookup_icon("utilities-terminal")},
			{"Web browser", web_browser, menubar.utils.lookup_icon("webbrowser-app")},
			{"File Manager", file_manager, menubar.utils.lookup_icon("system-file-manager")},
			{"Text Editor", text_editor, menubar.utils.lookup_icon("accessories-text-editor")}
			-- other triads can be put here
		},
		after = {
			{"TDE", myawesomemenu, icons.logo},
			{"Screenshot", screenshot},
			{
				"End Session",
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
mylauncher = awful.widget.launcher({image = beautiful.awesome_icon, menu = mymainmenu})

-- Embed mouse bindings
root.buttons(
	gears.table.join(
		awful.button(
			{},
			3,
			function()
				mymainmenu:toggle()
			end
		),
		awful.button(
			{},
			1,
			function()
				mymainmenu:hide()
				mousedrag.start()
			end,
			function()
				mousedrag.stop()
			end
		)
	)
)

-- Used when enabling desktop icons

--[[
for s in screen do
    freedesktop.desktop.add_icons({
		screen = s,
		open_with = 'xdg-open',
		iconsize = { width = dpi(64), height = dpi(64) },
		baseicons = {
			[1] = {
				label = "This PC",
				icon  = "computer",
				onclick = "/"
			},
			[2] = {
				label = "Home",
				icon  = "user-home",
				onclick = os.getenv("HOME")
			},
			[3] = {
				label = "Trash",
				icon  = "user-trash",
				onclick = "trash://"
			}
		},
	})
end
--]]
