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
-- Create a new button widget
--
--
--    local button = lib-widget.button({body = "Button text"})
--    local button2 = lib-widget.button({body = wibox.widget.imagebox("/path/to/image")})
--
-- ![Button](../images/button.png)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.button
-- @supermodule wibox.container.background
---------------------------------------------------------------------------

-- TODO: implement this files
-- TODO: refactor codebase to use this

local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local signals = require("lib-tde.signals")
local dpi = beautiful.xresources.apply_dpi

local buttons = {}

--- Create a new button widget
-- @tparam wibox.widget args.body The widget to put in the center (usually an icon or text)
-- @tparam function args.callback The callback function to call when the button is pressed
-- @tparam[opt] table args.pallet A colorpallet from the theme.mat-colors file
-- @tparam[opt] bool args.center Center the content of the button
-- @tparam[opt] function args.enter_callback This is called when the button receives focus
-- @tparam[opt] function args.leave_callback This is called when the button losses focus
-- @tparam[opt] bool args.update Don't update the color of the button (used in the theme settings)
-- @tparam[opt] number args.width The width of the button (If not set it is scalled to the body)
-- @treturn widget The button widget
-- @staticfct button
-- @usage -- This will create a button that is red
-- local button = lib-widget.button({ body = 'Click me', callback = function()
--    print("Clicked")
-- end, pallet = require("theme.mat-colors").red})
local btn = function(args)
    if args == nil then args = {} end

    local body = args["body"]
    local callback = args["callback"]
    local pallet = args["pallet"]
    local center = args["center"]
    local enter_callback = args["enter_callback"]
    local leave_callback = args["leave_callback"]
    local no_update = args["no_update"]
    local _width = args["width"]

    if center == nil then center = true end

    local button = wibox.container.background()
    local color = pallet or beautiful.primary
    local bIsHovered = false
    button.bg = color.hue_600
    button.shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, _G.save_state.rounded_corner/2)
    end

    button.forced_height = dpi(40)

    signals.connect_change_rounded_corner_dpi(function(radius)
        button.shape = function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, radius/2)
        end
    end)


    if type(body) == "string" then
        body = wibox.widget.textbox(i18n.translate(body))
    end

    --- Emulate a hover event
    -- @staticfct emulate_hover
    -- @usage -- Act as if the mouse hovered over the button
    -- button.emulate_hover()
    button.emulate_hover = function()
        bIsHovered = true
        button.bg = color.hue_800
        if enter_callback then
            enter_callback(button)
        end
    end

    --- Emulate a hover unfocus event
    -- @staticfct emulate_focus_loss
    -- @usage -- Act as if the mouse hovered over the button and then left
    -- button.emulate_focus_loss()
    button.emulate_focus_loss = function()
        bIsHovered = false
        button.bg = color.hue_600
        if leave_callback then
            leave_callback(button)
        end
    end

    --- Get the active theme pallet
    -- @tparam table The pallet to supply, follows the material design format
    -- @staticfct get_active_pallet
    -- @usage -- Return the active theme pallet
    -- button.get_active_pallet()
    button.get_active_pallet = function ()
        return color
    end

    button:connect_signal(
        "mouse::enter",
        function()
            button.emulate_hover()
        end
    )
    button:connect_signal(
        "mouse::leave",
        function()
            button.emulate_focus_loss()
        end
    )
    if center then
        button:setup {
            layout = wibox.container.place,
            halign = "center",
            body
        }
    else
        button:setup {
            layout = wibox.container.margin,
            body
        }
    end
    button:buttons(gears.table.join(awful.button({}, 1, callback)))

    --- Manually update the color pallet used by the button, usually used when you want the button to not follow the theming
    -- @tparam table The pallet to supply, follows the material design format
    -- @staticfct update_pallet
    -- @usage -- Update the color pallet of the button
    -- button.update_pallet(require("theme.mat-colors").yellow)
    button.update_pallet = function(new_pallet)
        color = new_pallet
        if bIsHovered then
            button.emulate_hover()
        else
            button.emulate_focus_loss()
        end
    end

    if no_update == nil or no_update == false then
        signals.connect_primary_theme_changed(
            function(theme)
                color = theme
                if bIsHovered then
                    button.emulate_hover()
                else
                    button.emulate_focus_loss()
                end
            end
        )
    end

    table.insert(buttons, button)

    button.forced_width = _width

    return button
end

--- Return the amount of buttons
-- @staticfct count
-- @usage -- Returns the amount of instantiated buttons
-- lib-widget.button.count()
local function count()
    return #buttons
end

return setmetatable(
    {
        button = btn,
        count = count
    },
    {__call = function(_, ...)
        return btn(...)
    end}
)