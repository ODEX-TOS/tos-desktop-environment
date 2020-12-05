local installed = require("lib-tde.hardware-check").has_package_installed
local menubar = require("menubar")
local icons = require("theme.icons")
local desktop_icon = require("widget.desktop_icon")
local apps = require("configuration.apps")

local show_installer = installed("installer")

local icon = menubar.utils.lookup_icon("calamares") or icons.logo
local tutorial_icon = menubar.utils.lookup_icon("preferences-desktop-theme") or icons.logo

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
end
