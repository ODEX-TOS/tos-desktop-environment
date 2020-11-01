local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")

local startx = -1
local starty = -1
local endx = -1
local endy = -1

local box = nil

local function createBox(x, y, width, height)
    local box =
        wibox(
        {
            ontop = false,
            visible = true,
            x = x,
            y = y,
            type = "dock",
            bg = beautiful.accent.hue_800 .. "44",
            border_width = dpi(1),
            border_color = beautiful.accent.hue_600,
            width = width,
            height = height,
            screen = mouse.screen
        }
    )
    return box
end

local function calculate(sx, sy, ex, ey)
    local x = 0
    local y = 0
    local width = 0
    local height = 0

    if sx < ex then
        x = sx
        width = ex - sx
    else
        x = ex
        width = sx - ex
    end
    if sy < ey then
        y = sy
        height = ey - sy
    else
        y = ey
        height = sy - ey
    end
    return {
        x = x,
        y = y,
        width = width,
        height = height
    }
end

local timer =
    gears.timer {
    timeout = 0.05,
    call_now = false,
    autostart = false,
    callback = function()
        local coords = mouse.coords()
        endx = coords.x
        endy = coords.y
        local computation = calculate(startx, starty, endx, endy)
        box.x = computation.x
        box.y = computation.y
        box.width = computation.width
        box.height = computation.height
        box.visible = true
    end
}

timer:connect_signal(
    "timeout",
    function()
        if not mouse.coords().buttons[1] then
            box.visible = false
            timer:stop()
        end
    end
)

local function start()
    local coords = mouse.coords()
    startx = coords.x
    starty = coords.y
    if box == nil then
        box = createBox(startx, starty, 1, 1)
    end
    timer:start()
end

local function stop()
    timer:stop()
    if box then
        box.visible = false
    end
end

return {
    start = start,
    stop = stop
}
