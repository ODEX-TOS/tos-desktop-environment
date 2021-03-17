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
-- For those reading this
-- This plugin is not designed to be used daily
-- Instead it is a proof of concept of what you can do with our plugin system
-- It makes your computer laggy for daily use (because a game is constantly running parallel to the rest of your system

local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local awful = require("awful")

-- list of all "sections" of the snake
local parts = {}

-- the location of the fruit
local fruit = nil

-- information about the game area
local screen_width = mouse.screen.workarea.width
local screen_height = mouse.screen.workarea.height

-- player direction offset
-- Could be a vector
local xoffset = -1
local yoffset = 0

local timer = nil

-- size of the player and fruit
local size = dpi(20)

-- check if a number is 'close' to another number
-- eg 7 and 10 have a margin of error of 3
-- 10 and 50 have a margin of error of 40
-- this function returns true when the margin is smaller that <margin>
local function margin_of_error(point1, point2, margin)
    local smaller
    local bigger
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

-- check if 2 rectangles are intersecting (rectangles of equal size)
local function intersecting(source, target)
    -- target left top point is in the source circle
    return margin_of_error(source.x, target.x, size) and margin_of_error(source.y, target.y, size)
end

-- create one "section" of the snake at a specific x and y position
-- if head and fruit define the color of the box
local function createPart(x, y, head, fruit_in)
    local bg = head or fruit_in or beautiful.accent.hue_800
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

-- append an extra part to the snake
local function add_snake_part()
    -- No parts means we are generating the head (at the center of the screen)
    if #parts == 0 then
        local box =
            createPart(
            math.floor((screen_width - size) / size) * size * 0.5,
            math.floor((screen_height - size) / size) * size * 0.5,
            beautiful.accent.hue_600
        )
        table.insert(parts, box)
    else
        -- find the location of the last element and append it after that position
        local head = parts[#parts]
        local x = head.x - (xoffset * size * 1.7)
        local y = head.y - (yoffset * size * 1.7)
        local box = createPart(x, y)
        table.insert(parts, box)
    end
end

-- create a fruit (should be called only once)
local function create_fruit()
    fruit =
        createPart(
        math.random(size, math.floor((screen_width - size) / size)) * size,
        math.random(size, math.floor((screen_height - size) / size)) * size,
        nil,
        "#FF033E"
    )
end

-- move the fruit to a new position (randomly)
local function update_fruit()
    fruit.x = math.random(size, math.floor((screen_width - size) / size)) * size
    fruit.y = math.random(size, math.floor((screen_height - size) / size)) * size
end

-- stop the game
-- and free up resources
local function stop()
    print("Stopping snake")
    if parts ~= nil then
        for _, widget in ipairs(parts) do
            widget.visible = false
        end
    end
    if fruit ~= nil then
        fruit.visible = false
    end
    parts = nil
    fruit = nil

    if timer ~= nil then
        timer:stop()
    end

    collectgarbage()
end

-- move the head into a direction
-- If we are out of bounds we wrap to the other side
-- Much like a torus
local function move_head(widget)
    widget.x = widget.x + (xoffset * size * 1.2)
    widget.y = widget.y + (yoffset * size * 1.2)
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

-- start the game with a head and a tail
add_snake_part()
add_snake_part()

-- init the fruit
create_fruit()

-- this is our main game loop (10 fps)
timer =
    gears.timer {
    timeout = 0.1,
    call_now = true,
    autostart = true,
    callback = function()
        -- in our game loop we move the head and make all the parts follow it
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
        -- if the head intersects with the fruit we gain a section and move the fruit to a new position
        if intersecting(parts[1], fruit) then
            add_snake_part()
            update_fruit()
        end
        -- TODO: check if the head is intersecting with any other snake section
        -- If that is the case the snake "crashed" in itself and the game should stop
        for i, part in ipairs(parts) do
            if not (i == 1) and intersecting(parts[1], part) then
                stop()
            end
        end
    end
}

-- input handling of the game
-- For each input (Up, Down, Right, Left) we change the vector to point in the direction we are moving
-- This will then be applied in the gameloop
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
    -- Stop the game when we press Escape
    stop_key = "Escape",
    stop_event = "release",
    stop_callback = stop
}

-- start input handling
input:start()
