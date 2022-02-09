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
---------------------------------------------------------------------------
-- This module allow the user to spawn a menu in the location of the mouse cursor
--
-- example of the api:
--    local menu = require("widget.menu")({
--       wibox = my_wibox,
--         items = {
--            {
--               "item 1",
--               function()
--                  print("item 1 clicked")
--               end,
--               "~/icons/icon1.png",

--            },
--            {
--               "item 2",
--               function()
--                  print("item 2 clicked")
--               end,
--               "~/icons/icon2.png",
--            },
--         }
--    })
--
--
--
-- @author Tom Meyers
-- @copyright 2022 Tom Meyers
-- @tdemod lib-tde.menu
-- @supermodule wibox
---------------------------------------------------------------------------
local gears = require("gears")
local beautiful = require("beautiful")
local logger = require("lib-tde.logger")

local function menu(args)
    local box = args.wibox or mouse.current_wibox
    local items = args.items or {}
    local right_click_pressed = args.right_click_pressed or function() end
    local right_click_released = args.right_click_released or function() end

    local left_click_pressed = args.left_click_pressed or function() end
    local left_click_released = args.left_click_released or function() end

    -- Don't waist cpu cycles in case the caller incorrectly calls this function
    if box == nil or items == nil then
        logger.log_with_stacktrace(
            "Incorrect function call for menu(), please provide a wibox on which to spawn the menu and a list of items to show",
            logger.error
        )
        return
    end

    local mainMenu = awful.menu({ items = items})

    awful.widget.launcher({image = beautiful.tde_icon, menu = mainMenu})

    box:buttons(
        gears.table.join(
            awful.button(
                {},
                3,
                function()
                    right_click_pressed()
                    mainMenu:toggle()
                end,
                right_click_released
            ),
            awful.button(
                {},
                1,
                function()
                    left_click_pressed()
                    if mymainmenu ~= nil then
                        mainMenu:hide()
                    end
                end,
                left_click_released
            )
        )
    )
end

return menu