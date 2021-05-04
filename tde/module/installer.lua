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
local installed = require("lib-tde.hardware-check").has_package_installed
local menubar = require("menubar")
local icons = require("theme.icons")
local desktop_icon = require("widget.desktop_icon")
local apps = require("configuration.apps")

local show_installer = installed("installer")

local icon = menubar.utils.lookup_icon("calamares") or icons.logo
local tutorial_icon = menubar.utils.lookup_icon("preferences-desktop-theme") or icons.logo
local settings_icon = menubar.utils.lookup_icon("preferences-desktop-theme") or icons.logo

if show_installer then
    desktop_icon.create_icon(
        icon,
        i18n.translate("Installer"),
        0,
        function()
            print("Starting installer")
            awful.spawn("tos calamares")
        end
    )
    desktop_icon.create_icon(
        tutorial_icon,
        i18n.translate("Tutorial"),
        1,
        function()
            print("Starting tos tutorial")
            awful.spawn(apps.default.terminal .. " -e tos tutorial")
        end
    )
    desktop_icon.create_icon(
        settings_icon,
        i18n.translate("Settings"),
        1,
        function()
            print("Opening settings application")
            root.elements.settings.enable_view_by_index(-1, mouse.screen)
        end
    )
end
