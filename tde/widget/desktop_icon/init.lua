local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local rounded = require("lib-tde.widget.rounded")
local gears = require("gears")
local icons = require("theme.icons")
local menubar = require("menubar")
local filehandle = require("lib-tde.file")

local width = dpi(100)
local height = width

local amount = math.floor((mouse.screen.workarea.height / height) - 1)

local function create_icon(icon, name, num, callback)
    local box =
        wibox(
        {
            ontop = false,
            visible = true,
            x = dpi(10) + (math.floor((num / amount)) * (width + dpi(10))),
            y = dpi(36) + ((num % amount) * (height + dpi(10))),
            type = "dock",
            bg = beautiful.background.hue_800 .. "00",
            shape = rounded(dpi(20)),
            width = width,
            height = height,
            screen = awful.screen.primary
        }
    )

    box:buttons(gears.table.join(awful.button({}, 1, callback)))

    local widget =
        wibox.widget {
        layout = wibox.layout.fixed.vertical,
        wibox.container.place(
            {
                image = icon,
                resize = true,
                forced_height = height - dpi(35),
                widget = wibox.widget.imagebox
            }
        ),
        wibox.container.place(
            {
                text = name,
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
            box.bg = beautiful.accent.hue_600 .. "99"
        end
    )

    widget:connect_signal(
        "mouse::leave",
        function()
            box.bg = beautiful.background.hue_800 .. "00"
        end
    )

    box:setup {
        layout = wibox.layout.flex.vertical,
        widget,
        forced_width = width
    }
    return box
end

local function desktop_file(file, name, index)
    local name = "Desktop file"
    local icon = "application-x-executable"
    local lines = filehandle.lines(file)
    for _, line in ipairs(lines) do
        local nameMatch = line:match("Name=(.*)")
        local iconMatch = line:match("Icon=(.*)")

        if nameMatch and name == "Desktop file" then
            name = nameMatch
        elseif iconMatch and icon == "application-x-executable" then
            icon = iconMatch
        end
    end
    create_icon(
        menubar.utils.lookup_icon(icon) or icons.warning,
        name,
        index,
        function()
            print("Opened: " .. file)
            awful.spawn("gtk-launch " .. name)
        end
    )
end

local function from_file(file, index)
    local name = filehandle.basename(file)
    if name:match("desktop$") then
        desktop_file(file, name, index)
    else
        -- can be found here https://specifications.freedesktop.org/icon-naming-spec/latest/ar01s04.html
        create_icon(
            menubar.utils.lookup_icon("text-x-generic") or icons.warning,
            name,
            index,
            function()
                print("Opened: " .. file)
                awful.spawn("open " .. file)
            end
        )
    end
end

return {
    from_file = from_file,
    create_icon = create_icon
}
