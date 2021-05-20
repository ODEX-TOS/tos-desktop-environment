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
-- Create a new inputfield widget
--
-- Useful when you want to separate widgets from each other
--
--    -- basic inputfield
--    local inputfield = lib-widget.inputfield()
--
-- ![hidden](../images/hidden-inputfield.png)
-- ![inputfield](../images/inputfield.png)
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.inputfield
-- @supermodule wibox.container.background
---------------------------------------------------------------------------
-- TODO: implement this files
-- TODO: refactor codebase to use this (network tab)

local wibox = require("wibox")
local gears = require("gears")
local clickable_container = require("widget.material.clickable-container")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local password_to_star = function(pass)
    local str = ""
    for _ = 1, #pass do
        str = str .. "*"
    end
    return str
end

local write_to_textbox = function(widget, char, active_text, hidden)
    if widget then
        active_text = active_text .. char
        if hidden then
            widget:set_text(password_to_star(active_text))
        else
            widget:set_text(active_text)
        end
    end
    return active_text
end

local delete_key = function(widget, active_text, hidden)
    if widget then
        active_text = active_text:sub(1, #active_text - 1)
        if hidden then
            widget:set_text(password_to_star(active_text))
        else
            widget:set_text(active_text)
        end
    end
    return active_text
end

local reset_textbox = function(widget, active_text, hidden)
    if widget then
        active_text = ""
        if hidden then
            widget:set_text(password_to_star(active_text))
        else
            widget:set_text(active_text)
        end
    end
    return active_text
end

--- Create a new inputfield widget
-- @tparam[opt] function typing_callback This callback gets triggered on every keystroke
-- @tparam[opt] function done_callback This callback gets triggered when the user finished typing
-- @tparam[opt] bool hidden This option tells us if we need to mask the input (with * instead of the real text)
-- @treturn widget The inputfield widget
-- @staticfct inputfield
-- @usage -- This will create a basic inputfield
-- local inputfield = lib-widget.inputfield()
return function(typing_callback, done_callback, hidden)
    local active_text = ""
    local prev_keygrabber

    local textbox = wibox.widget.textbox(active_text)
    -- TODO: allow custom fonts
    textbox.font = "SF Pro Display Bold 16"
    textbox.align = "left"
    textbox.valign = "center"

    local widget =
        wibox.widget {
        {
            {
                textbox,
                margins = dpi(5),
                widget = wibox.container.margin
            },
            widget = clickable_container
        },
        -- TODO: allow custom heights
        forced_height = dpi(30),
        bg = beautiful.groups_bg,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
        end,
        widget = wibox.container.background
    }

    local stop_grabber = function(grabber)
        grabber:stop()
        if prev_keygrabber then
            prev_keygrabber:start()
        end
        if done_callback then
            done_callback(active_text)
        end
        active_text = reset_textbox(textbox, active_text, hidden)
    end

    local input_grabber =
        awful.keygrabber {
        auto_start = true,
        stop_event = "release",
        keypressed_callback = function(_, _, key, _)
            if key == "BackSpace" then
                active_text = delete_key(textbox, active_text, hidden)
            end
            if #key == 1 then
                active_text = write_to_textbox(textbox, key, active_text, hidden)
            end
            if typing_callback then
                typing_callback(active_text)
            end
        end,
        keyreleased_callback = function(self, _, key, _)
            if key == "Escape" or key == "Return" then
                stop_grabber(self)
            end
        end
    }

    widget:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                nil,
                function()
                    -- clear the old text
                    active_text = ""
                    textbox:set_text(active_text)

                    if awful.keygrabber.is_running then
                        print("Found an existing keygrabber")
                        prev_keygrabber = awful.keygrabber.current_instance
                        prev_keygrabber:stop()
                    end

                    print("Start grabbing input for inputbox")
                    input_grabber:stop()
                    input_grabber:start()
                end
            )
        )
    )

    --- Get the current text that is in the inputfield
    -- @staticfct get_text
    -- @usage -- Get the active text in the input field
    -- local text = inputfield.get_text()
    widget.get_text = function()
        return active_text
    end

    --- Change the text in the input field, useful when you want to validate input
    -- @tparam string text the text to supply
    -- @staticfct update_text
    -- @usage -- Update the text in the inputfield
    -- inputfield.update_text("This is some new text")
    widget.update_text = function(text)
        active_text = text
        if hidden then
            textbox:set_text(password_to_star(text))
        else
            textbox:set_text(text)
        end
    end

    --- Clear the text from the inputfield, but keep the focus
    -- @staticfct clear_text
    -- @usage -- Clear the text from the inputfield
    -- inputfield.clear_text()
    widget.clear_text = function()
        active_text = reset_textbox(textbox, active_text, hidden)
    end

    --- Stop listening for keystrokes, but keep the text in the input field
    -- @staticfct stop_grabbing
    -- @usage -- Stop listening for keystrokes
    -- inputfield.stop_grabbing()
    widget.stop_grabbing = function()
        stop_grabber(input_grabber)
    end

    --- Reset the inputfield, this means stop listening and reset the text
    -- @staticfct reset
    -- @usage -- Resets the inputfield
    -- inputfield.reset()
    widget.reset = function()
        widget.stop_grabbing()
        widget.clear_text()
    end

    return widget
end
