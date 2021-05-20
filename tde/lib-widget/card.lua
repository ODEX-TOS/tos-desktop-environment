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
-- Create a new card widget
--
--
--    -- card with a title and body
--    local card = lib-widget.card("title")
--    card.update_body(lib-widget.textbox("body"))
--
-- ![Card](../images/card.png)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.card
-- @supermodule wibox.widget.base
---------------------------------------------------------------------------

local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local header_font = "SFNS Display Regular 14"
local bg = beautiful.bg_modal
local bg_title = beautiful.bg_modal_title

local titled_card = function(title, height)
    local header =
        wibox.widget {
        text = i18n.translate(title),
        font = header_font,
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local body_widget =
        wibox.widget {
        wibox.widget.base.empty_widget(),
        bg = bg,
        shape = function(cr, rect_width, rect_height)
            gears.shape.partially_rounded_rect(cr, rect_width, rect_height, false, false, true, true, 6)
        end,
        widget = wibox.container.background,
        forced_height = height
    }

    local widget =
        wibox.widget {
        layout = wibox.layout.fixed.vertical,
        {
            bg = bg_title,
            wibox.widget {
                wibox.container.margin(header, dpi(10), dpi(10), dpi(10), dpi(10)),
                bg = bg_title,
                shape = function(cr, rect_width, rect_height)
                    gears.shape.partially_rounded_rect(cr, rect_width, rect_height, true, true, false, false, 6)
                end,
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.vertical
        },
        body_widget,
        nil,
        bg = bg
    }

    --- Update the title of the card
    -- @tparam string title The title of the card
    -- @staticfct update_title
    -- @usage -- This will change the title to hello
    -- card.update_title("hello")
    widget.update_title = function(updated_title)
        header.text = i18n.translate(updated_title)
    end

    --- Update the body of the card
    -- @tparam widget body The widget to put in the body of the card
    -- @staticfct update_body
    -- @usage -- This will change the body to world
    -- card.update_body(lib-widget.textbox("world"))
    widget.update_body = function(update_body)
        body_widget.widget = update_body
    end

    --- Update the title and body
    -- @tparam string title The title of the card
    -- @tparam widget body The widget to put in the body of the card
    -- @staticfct update
    -- @usage -- This will change the title to "hello" and the body to "world"
    -- card.update("hello", lib-widget.textbox("world"))
    widget.update = function(updated_title, update_body)
        widget.update_title(updated_title)
        widget.update_body(update_body)
    end
    return widget
end

local bare_card = function()
    local body_widget =
        wibox.widget {
        wibox.widget.base.empty_widget(),
        bg = bg,
        shape = function(cr, rect_width, rect_height)
            gears.shape.partially_rounded_rect(cr, rect_width, rect_height, true, true, true, true, 6)
        end,
        widget = wibox.container.background
    }

    --- Update the body of the card
    -- @tparam widget body The widget to put in the body of the card
    -- @staticfct update_body
    -- @usage -- This will change the body to world
    -- card.update_body(lib-widget.textbox("world"))
    body_widget.update_body = function(update_body)
        body_widget.widget = update_body
    end

    --- Update the title and body
    -- @tparam string title The title of the card
    -- @tparam widget body The widget to put in the body of the card
    -- @staticfct update
    -- @usage -- This will change the title to "hello" and the body to "world"
    -- card.update("hello", lib-widget.textbox("world"))
    body_widget.update = function(_, update_body)
        body_widget.update_body(update_body)
    end
    return body_widget
end

--- Create a new card widget
-- @tparam[opt] string title Sets the title of the card
-- @tparam[opt] number size The height of the card
-- @treturn widget The card widget
-- @staticfct card
-- @usage -- This will create a card with the title hello
-- -- card with the title hello
-- local card = lib-widget.card("hello")
return function(title, height)
    if title ~= nil then
        return titled_card(title, height)
    end
    return bare_card()
end
