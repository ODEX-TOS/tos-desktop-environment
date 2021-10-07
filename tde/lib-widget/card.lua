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
--    local card = lib-widget.card({title="title"})
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
local signals = require("lib-tde.signals")
local dpi = beautiful.xresources.apply_dpi

local header_font = "SFNS Display Regular 14"
local bg = beautiful.bg_modal
local bg_title = beautiful.bg_modal_title

local cards = {}

local titled_card = function(args)
    local title = args["title"]
    local height = args["height"]

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
            gears.shape.partially_rounded_rect(cr, rect_width, rect_height, false, false, true, true, _G.save_state.rounded_corner/2)
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
                    gears.shape.partially_rounded_rect(cr, rect_width, rect_height, true, true, false, false, _G.save_state.rounded_corner/2)
                end,
                widget = wibox.container.background
            },
            layout = wibox.layout.fixed.vertical
        },
        body_widget,
        nil,
        bg = bg
    }

    signals.connect_change_rounded_corner_dpi(function(radius)
        body_widget.shape = function(cr, rect_width, rect_height)
            gears.shape.partially_rounded_rect(cr, rect_width, rect_height, false, false, true, true, radius/2)
        end

        widget.shape = function(cr, rect_width, rect_height)
            gears.shape.partially_rounded_rect(cr, rect_width, rect_height, true, true, false, false, radius/2)
        end
    end)

    --- Update the title of the card (Build in translation)
    -- @tparam string title The title of the card
    -- @staticfct update_title
    -- @usage -- This will change the title to hello
    -- card.update_title("hello")
    widget.update_title = function(updated_title, ...)
        --filter out trailing whitespace in the title
        if type(updated_title) == "string" then
            updated_title = string.gsub(updated_title, '\n$', '')
        end
        header.text = i18n.translate(updated_title, ...)
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
    widget.update = function(updated_title, update_body, ...)
        widget.update_title(updated_title, ...)
        widget.update_body(update_body)
    end

    --- Highlight the card, used when to show focus
    -- @staticfct highlight
    -- @usage -- This will highlight the background of the card, simulating a 'hover'
    -- card.highlight()
    widget.highlight = function()
        local color = beautiful.primary.hue_600  .. '66'
        widget.bg = color
        body_widget.bg =  color
    end

    --- Remove the highlight of the card
    -- @staticfct unhighlight
    -- @usage -- This will unhighlight the background of the card, simulating a 'hover'
    -- card.unhighlight()
    widget.unhighlight = function()
        widget.bg = bg
        body_widget.bg =  bg
    end

    return widget
end

local bare_card = function(args)
    local height = args["height"]

    local body_widget =
        wibox.widget {
        wibox.widget.base.empty_widget(),
        bg = bg,
        shape = function(cr, rect_width, rect_height)
            gears.shape.partially_rounded_rect(cr, rect_width, rect_height, true, true, true, true, _G.save_state.rounded_corner/2)
        end,
        forced_height = height,
        widget = wibox.container.background
    }

    signals.connect_change_rounded_corner_dpi(function(radius)
        body_widget.shape = function(cr, rect_width, rect_height)
            gears.shape.partially_rounded_rect(cr, rect_width, rect_height, true, true, true, true, radius/2)
        end
    end)

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


    --- Highlight the card, used when to show focus
    -- @staticfct highlight
    -- @usage -- This will highlight the background of the card, simulating a 'hover'
    -- card.highlight()
    body_widget.highlight = function()
        local color = beautiful.primary.hue_600  .. '66'
        body_widget.bg = color
    end

    --- Remove the highlight of the card
    -- @staticfct unhighlight
    -- @usage -- This will unhighlight the background of the card, simulating a 'hover'
    -- card.unhighlight()
    body_widget.unhighlight = function()
        body_widget.bg =  bg
    end

    return body_widget
end

--- Create a new card widget
-- @tparam[opt] string args.title Sets the title of the card
-- @tparam[opt] number args.size The height of the card
-- @treturn widget The card widget
-- @staticfct card
-- @usage -- This will create a card with the title hello
-- -- card with the title hello
-- local card = lib-widget.card({title="hello"})
local card = function(args)
    if args == nil then args = {} end
    local __card
    if args["title"] ~= nil then
        __card = titled_card(args)
    else
        __card = bare_card(args)
    end

    table.insert(cards, __card)
    return __card
end

--- Return the amount of cards
-- @staticfct count
-- @usage -- Returns the amount of instantiated cards
-- lib-widget.card.count()
local function count()
    return #cards
end

return setmetatable(
    {
        card = card,
        count = count
    },
    {__call = function(_, ...)
        return card(...)
    end}
)
