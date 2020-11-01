local installed = require("lib-tde.hardware-check").has_package_installed
local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local menubar = require("menubar")
local rounded = require("lib-tde.widget.rounded")
local gears = require("gears")
local icons = require("theme.icons")

local show_installer = installed("installer")

local width = dpi(100)
local height = width

local installer =
    wibox(
    {
        ontop = false,
        visible = show_installer,
        x = dpi(10),
        y = dpi(36),
        type = "icon",
        bg = beautiful.background.hue_800 .. "00",
        shape = rounded(dpi(20)),
        width = width,
        height = height,
        screen = awful.screen.primary
    }
)

installer:buttons(
    gears.table.join(
        awful.button(
            {},
            1,
            function()
                print("Starting installer")
                awful.spawn("tos calamares")
            end
        )
    )
)

local widget =
    wibox.widget {
    layout = wibox.layout.fixed.vertical,
    wibox.container.place(
        {
            image = menubar.utils.lookup_icon("calamares") or icons.logo,
            resize = true,
            forced_height = height - dpi(35),
            widget = wibox.widget.imagebox
        }
    ),
    wibox.container.place(
        {
            text = "Installer",
            halign = "center",
            valign = "top",
            font = beautiful.title_font,
            widget = wibox.widget.textbox
        }
    ),
    forced_width = width
}

widget:connect_signal(
    "mouse::enter",
    function()
        installer.bg = beautiful.background.hue_800
    end
)

widget:connect_signal(
    "mouse::leave",
    function()
        installer.bg = beautiful.background.hue_800 .. "00"
    end
)

installer:setup {
    layout = wibox.layout.flex.vertical,
    widget,
    forced_width = width
}
