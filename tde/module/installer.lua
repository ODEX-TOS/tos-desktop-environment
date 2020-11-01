local installed = require("lib-tde.hardware-check").has_package_installed
local menubar = require("menubar")
local icons = require("theme.icons")
local desktop_icon = require("widget.desktop_icon")

local show_installer = installed("installer")

local icon = menubar.utils.lookup_icon("calamares") or icons.logo

if show_installer then
    desktop_icon.create_icon(
        icon,
        "Installer",
        0,
        function()
            print("Starting installer")
            awful.spawn("tos calamares")
        end
    )
end
