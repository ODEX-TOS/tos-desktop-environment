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
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local hardware = require("lib-tde.hardware-check")

local startx = -1
local starty = -1
local endx = -1
local endy = -1

local box = nil

local started = false

local function createBox(x, y, width, height)
    local _box =
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
    return _box
end

local function calculate(sx, sy, ex, ey)
    local x
    local y
    local width
    local height

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
    timeout = 1 / hardware.getDisplayFrequency(),
    call_now = false,
    autostart = false,
    callback = function()
        local coords = mouse.coords()
        endx = coords.x
        endy = coords.y
        local computation = calculate(startx, starty, endx, endy)

        if computation.x == nil or computation.y == nil or computation.width == nil or computation.height == nil then
            box.visible = false
            return
        end

        if computation.x < 0 or computation.y < 0 or computation.width <= 0 or computation.height <= 0 then
            box.visible = false

            return
        end

        box.x = computation.x
        box.y = computation.y
        box.width = computation.width or 1
        box.height = computation.height or 1
        box.visible = true
    end
}

timer:connect_signal(
    "timeout",
    function()
        if not mouse.coords().buttons[1] then
            box.visible = false
            if started then
                timer:stop()
                started = false
            end
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
    if not started then
        timer:start()
        started = true
    end
end

local function stop()
    if started then
        timer:stop()
        started = false
    end
    if box then
        box.visible = false
    end
end

return {
    start = start,
    stop = stop
}
