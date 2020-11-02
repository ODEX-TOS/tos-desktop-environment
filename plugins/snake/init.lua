local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local awful = require("awful")

local parts = {}
local fruit = nil
local screen_width = mouse.screen.workarea.width
local screen_height = mouse.screen.workarea.height

local xoffset = -1
local yoffset = 0

local size = dpi(20)

local function margin_of_error(point1, point2, margin)
    local smaller = 0
    local bigger = 0
    if point1 == point2 then
        return true
    end
    if point1 < point2 then
        smaller = point1
        bigger = point2
    else
        smaller = point2
        bigger = point1
    end
    return smaller + margin >= bigger
end

local function intersecting(source, target)
    -- target left top point is in the source circle
    return margin_of_error(source.x, target.x, size) and margin_of_error(source.y, target.y, size)
end

local function createPart(x, y, head, fruit)
    local bg = head or fruit or beautiful.accent.hue_800
    local box =
        wibox(
        {
            ontop = true,
            visible = true,
            x = x,
            y = y,
            type = "dock",
            bg = bg .. "44",
            border_width = dpi(1),
            border_color = bg,
            width = size,
            height = size,
            screen = mouse.screen
        }
    )
    return box
end

local function add_snake_part()
    if #parts == 0 then
        local box =
            createPart(
            math.floor((screen_width - size) / size) * size * 0.5,
            math.floor((screen_height - size) / size) * size * 0.5,
            beautiful.accent.hue_600
        )
        table.insert(parts, box)
    else
        local head = parts[#parts]
        local x = head.x - (xoffset * size * 1.5)
        local y = head.y - (yoffset * size * 1.5)
        local box = createPart(x, y)
        table.insert(parts, box)
    end
end

local function create_fruit()
    fruit =
        createPart(
        math.random(size, math.floor((screen_width - size) / size)) * size,
        math.random(size, math.floor((screen_height - size) / size)) * size,
        nil,
        "#FF033E"
    )
end

local function update_fruit()
    fruit.x = math.random(size, math.floor((screen_width - size) / size)) * size
    fruit.y = math.random(size, math.floor((screen_height - size) / size)) * size
end

local function stop()
    print("Stopping snake")
    for _, widget in ipairs(parts) do
        widget.visible = false
    end
    fruit.visible = false
    parts = nil
    fruit = nil
    collectgarbage()
end

local function move_head(widget)
    widget.x = widget.x + (xoffset * size)
    widget.y = widget.y + (yoffset * size)
    if widget.x < 0 then
        widget.x = screen_width
    elseif widget.x > screen_width then
        widget.x = 0
    end
    if widget.y < 0 then
        widget.y = screen_height
    elseif widget.y > screen_height then
        widget.y = 0
    end
end

add_snake_part()
add_snake_part()

create_fruit()

gears.timer {
    timeout = 0.1,
    call_now = true,
    autostart = true,
    callback = function()
        for _index, _ in ipairs(parts) do
            local index = (#parts + 1) - _index
            if not (index == 1) then
                local widget = parts[index]
                local toLoc = parts[index - 1]
                widget.x = toLoc.x
                widget.y = toLoc.y
            end
        end
        move_head(parts[1])
        if intersecting(parts[1], fruit) then
            add_snake_part()
            update_fruit()
        end
    end
}

local input =
    awful.keygrabber {
    -- Note that it is using the key name and not the modifier name.
    keybindings = {
        awful.key {
            modifiers = {},
            key = "Up",
            on_press = function()
                if yoffset == 1 then
                    return
                end
                xoffset = 0
                yoffset = -1
            end
        },
        awful.key {
            modifiers = {},
            key = "Left",
            on_press = function()
                if xoffset == 1 then
                    return
                end
                xoffset = -1
                yoffset = 0
            end
        },
        awful.key {
            modifiers = {},
            key = "Right",
            on_press = function()
                if xoffset == -1 then
                    return
                end
                xoffset = 1
                yoffset = 0
            end
        },
        awful.key {
            modifiers = {},
            key = "Down",
            on_press = function()
                if yoffset == -1 then
                    return
                end
                xoffset = 0
                yoffset = 1
            end
        }
    },
    stop_key = "Escape",
    stop_event = "release",
    stop_callback = stop
}

input:start()
