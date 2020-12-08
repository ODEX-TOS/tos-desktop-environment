local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local rounded = require("lib-tde.widget.rounded")
local gears = require("gears")
local icons = require("theme.icons")
local menubar = require("menubar")
local filehandle = require("lib-tde.file")
local hardware = require("lib-tde.hardware-check")
local err = require("lib-tde.logger").error

local width = dpi(100)
local height = width

local amount = math.floor((mouse.screen.workarea.height / height) - 1)
local _count = 0

local icon_widgets = {}
local text_name = {}
local icon_timers = {}

local function create_icon(icon, name, num, callback, drag)
    _count = _count + 1
    local x = 0
    local y = 0

    if type(num) == "number" then
        x = dpi(10) + (math.floor((num / amount)) * (width + dpi(10)))
        y = dpi(36) + ((num % amount) * (height + dpi(10)))
    end

    if type(num) == "table" then
        x = num.x
        y = num.y
    end

    -- The offset used when dragging the icon
    local xoffset = 0
    local yoffset = 0
    -- To detect if a drag or a click happened
    local timercount = 0

    local box =
        wibox(
        {
            ontop = false,
            visible = true,
            x = x,
            y = y,
            type = "dock",
            bg = beautiful.background.hue_800 .. "00",
            shape = rounded(dpi(20)),
            width = width,
            height = height,
            screen = awful.screen.primary
        }
    )

    local timer =
        gears.timer {
        timeout = 1 / hardware.getDisplayFrequency(),
        call_now = false,
        autostart = false,
        callback = function()
            local coords = mouse.coords()
            box.x = coords.x - xoffset
            box.y = coords.y - yoffset
            timercount = timercount + 1
        end
    }

    local started = false

    box:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                function()
                    -- Find the offset of the mouse relative to the start of the rectangle
                    local coords = mouse.coords()
                    xoffset = coords.x - box.x
                    yoffset = coords.y - box.y
                    if not started then
                        started = true
                        print("TIMER: started")
                        timer:start()
                    end
                    timercount = 0
                end,
                function()
                    if started then
                        started = false
                        print("TIMER: stopped")
                        timer:stop()
                    end
                    if type(drag) == "function" then
                        drag(name, box.x, box.y)
                    end
                    if timercount < 10 then
                        callback()
                    end
                end
            )
        )
    )

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
    table.insert(icon_widgets, box)
    table.insert(text_name, name)
    table.insert(icon_timers, timer)
    return box
end

local function desktop_file(file, _, index, drag)
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
            awful.spawn("gtk-launch " .. filehandle.basename(file))
        end,
        drag
    )
end

local function from_file(file, index, x, y, drag)
    local name = filehandle.basename(file)
    if name:match(".desktop$") then
        desktop_file(file, name, index or {x = x, y = y}, drag)
    else
        -- can be found here https://specifications.freedesktop.org/icon-naming-spec/latest/ar01s04.html
        create_icon(
            menubar.utils.lookup_icon("text-x-generic") or icons.warning,
            name,
            index or {x = x, y = y},
            function()
                print("Opened: " .. file)
                awful.spawn("open " .. file)
            end,
            drag
        )
    end
end

local function delete(name)
    local i = -1
    for index, value in ipairs(text_name) do
        if value == name then
            i = index
        end
    end
    if i == -1 then
        print("Trying to remove: " .. name .. " from the desktop but it no longer exists", err)
    end
    icon_widgets[i].visible = false
    icon_timers[i]:stop()
    table.remove(icon_widgets, i)
    table.remove(icon_timers, i)
    table.remove(text_name, i)

    collectgarbage("collect")
end

local function location_from_name(name)
    local i = -1
    for index, value in ipairs(text_name) do
        if value == name then
            i = index
        end
    end
    if not (i == -1) then
        return {x = icon_widgets[i].x, y = icon_widgets[i].y}
    end
    return {x = nil, y = nil}
end

return {
    from_file = from_file,
    create_icon = create_icon,
    delete = delete,
    location_from_name = location_from_name,
    count = function()
        return _count
    end
}
