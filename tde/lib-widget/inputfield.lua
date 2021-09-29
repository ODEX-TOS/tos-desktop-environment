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
local escape = require("gears.string").xml_escape

local cursor_index = 1

local password_to_star = function(pass)
    local str = ""
    for _ = 1, #pass do
        str = str .. "*"
    end
    return str
end

local update_text = function(text, widget, bIsPassword, draw_location)
    if draw_location == nil then
        draw_location = true
    end

    if bIsPassword then
        text = password_to_star(text)
    end

    if not draw_location then
        widget:set_text(text)
        return
    end

    local before = ""
    local markup = ""
    local after = ""
    if text == "" then
        markup = string.format("<span background='%s' foreground='%s'>|</span>", beautiful.primary.hue_500, beautiful.primary.hue_500)
    end

    -- lets loop over the string and find the index
    for i = 1, #text do
        local char = text:sub(i,i)
        if i < cursor_index then
            before = before .. char
        elseif cursor_index == 0 and i == 1 then
            markup = string.format("<span background='%s' foreground='%s'>|</span>%s", beautiful.primary.hue_500, beautiful.primary.hue_500, char)
        elseif i == cursor_index and i == #text then
            markup = string.format("%s<span background='%s' foreground='%s'>|</span>", char, beautiful.primary.hue_500, beautiful.primary.hue_500)
        elseif i == cursor_index then
            markup = string.format("%s<span background='%s'>%s</span>", char, beautiful.primary.hue_500, text:sub(i+1,i+1))
        elseif i > cursor_index+1 or i == 1 then
            after = after .. char
        end
    end

    -- lets begin by drawing the text and add a <span bg="beautiful.primary.hue_500">char</span> to the text
    widget:set_markup(escape(before) .. markup .. escape(after))
end

local write_to_textbox = function(widget, char, active_text, hidden)
    if widget then
        local new_text = active_text:sub(1, cursor_index) .. char .. active_text:sub(cursor_index+1, #active_text)
        active_text = new_text
        cursor_index = cursor_index + string.len(char)

        if cursor_index > string.len(active_text) then
            cursor_index = string.len(active_text)
        end

        update_text(active_text, widget, hidden)
    end
    return active_text
end

local delete_key = function(widget, active_text, hidden)
    if widget then
        cursor_index = cursor_index - 1
        if cursor_index < 0 then
            cursor_index = 0
        end
        active_text = active_text:sub(1, cursor_index) .. active_text:sub(cursor_index+2, #active_text)
        update_text(active_text, widget, hidden)
    end
    return active_text
end

local delete_ahead_key = function(widget, active_text, hidden)
    if widget then
        active_text = active_text:sub(1, cursor_index) .. active_text:sub(cursor_index+2, #active_text)
        update_text(active_text, widget, hidden)
    end
    return active_text
end


local reset_textbox = function(widget, active_text, hidden, has_focus)
    if has_focus == nil then
        has_focus = true
    end
    if widget then
        if cursor_index > string.len(active_text) then
            cursor_index = string.len(active_text)
        end
        update_text(active_text, widget, hidden, has_focus)
    end
    return active_text
end

--- Create a new inputfield widget
-- @tparam[opt] function typing_callback This callback gets triggered on every keystroke
-- @tparam[opt] function done_callback This callback gets triggered when the user finished typing
-- @tparam[opt] function start_callback This callback gets triggered when focus is received
-- @tparam[opt] bool hidden This option tells us if we need to mask the input (with * instead of the real text)
-- @tparam[opt] function isvalid Passes in the name of the key, it should return if the key is valid or not for the given inputfield
-- @treturn widget The inputfield widget
-- @staticfct inputfield
-- @usage -- This will create a basic inputfield
-- local inputfield = lib-widget.inputfield()
return function(typing_callback, done_callback, start_callback, hidden, isvalid)
    local active_text = ""
    local prev_keygrabber

    local textbox = wibox.widget.textbox(active_text)
    -- TODO: allow custom fonts
    textbox.font = "SF Pro Display Bold 16"
    textbox.align = "left"
    textbox.valign = "center"

    if isvalid == nil then
        isvalid = function(_, _)
            return true
        end
    end

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
        if prev_keygrabber and prev_keygrabber ~= grabber then
            prev_keygrabber:start()
        end
        if done_callback then
            done_callback(active_text)
        end
    end

    local is_running = false

    local input_grabber =
        awful.keygrabber {
        auto_start = false,
        stop_event = "release",
        keypressed_callback = function(_, mod, key, _)
            if key == "BackSpace" then
                active_text = delete_key(textbox, active_text, hidden)
            elseif key == "Delete" then
                active_text = delete_ahead_key(textbox, active_text, hidden)
            elseif key == "Left" then
                cursor_index = cursor_index - 1
                if cursor_index < 0 then
                    cursor_index = 0
                end
                update_text(active_text, textbox, hidden)
            elseif key == "Right" then
                cursor_index = cursor_index + 1
                if cursor_index > string.len(active_text) then
                    cursor_index = string.len(active_text)
                end
                update_text(active_text, textbox, hidden)
            elseif mod[1] == "Control" or mod[2] == "Control" and key == "v" then
                local paste_text = selection()
                for i = 1, #paste_text do
                    local c = paste_text:sub(i,i)
                    active_text = write_to_textbox(textbox, c, active_text, hidden)
                end
            elseif #key == 1 and isvalid(key, active_text) then
                active_text = write_to_textbox(textbox, key, active_text, hidden)
            end

            if typing_callback then
                typing_callback(active_text)
            end
        end,
        start_callback = function (_)
            is_running = true
            active_text = reset_textbox(textbox, active_text, hidden, is_running)
        end,
        stop_callback = function ()
            is_running = false
            active_text = reset_textbox(textbox, active_text, hidden, is_running)
        end,
        keyreleased_callback = function(self, _, key, _)
            if key == "Escape" or key == "Return" then
                stop_grabber(self)
            end
        end
    }

    input_grabber["__inputfield__grabber__focus_loss"] = function ()
        active_text = reset_textbox(textbox, active_text, hidden, false)
    end

    local function start()
         if awful.keygrabber.current_instance ~= nil then
             print("Found an existing keygrabber")
             prev_keygrabber = awful.keygrabber.current_instance
             prev_keygrabber:stop()
             if prev_keygrabber["__inputfield__grabber__focus_loss"] ~= nil then
                 prev_keygrabber["__inputfield__grabber__focus_loss"]()
             end
         end

         print("Start grabbing input for inputbox")
         if start_callback then
             start_callback()
         end
         if not is_running then
            input_grabber:start()
         end
    end

    widget:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                nil,
                start
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
        widget.clear_text()
        for i = 1, #text do
            local c = text:sub(i,i)
            active_text = write_to_textbox(textbox, c, active_text, hidden)
        end

        update_text(active_text, textbox, hidden, false)
    end

    --- Clear the text from the inputfield, but keep the focus
    -- @staticfct clear_text
    -- @usage -- Clear the text from the inputfield
    -- inputfield.clear_text()
    widget.clear_text = function()
        active_text = ""
        cursor_index = 1
        active_text = reset_textbox(textbox, active_text, hidden, is_running)
    end

    --- Stop listening for keystrokes, but keep the text in the input field
    -- @staticfct stop_grabbing
    -- @usage -- Stop listening for keystrokes
    -- inputfield.stop_grabbing()
    widget.stop_grabbing = function()
        stop_grabber(input_grabber)
    end

    --- Force a user to gain focus to this input field
    -- @staticfct focus
    -- @usage -- Start listening for keystrokes
    -- inputfield.focus()
    widget.focus = function ()
        if awful.keygrabber.is_running then
            print("Found an existing keygrabber")
            prev_keygrabber = awful.keygrabber.current_instance
            prev_keygrabber:stop()
            if prev_keygrabber["__inputfield__grabber__focus_loss"] ~= nil then
                prev_keygrabber["__inputfield__grabber__focus_loss"]()
            end
        end

        if not is_running then
           input_grabber:start()
        end
    end

    --- Lose focus
    -- @staticfct unfocus
    -- @usage -- Remove the focus from this
    -- inputfield.unfocus()
    widget.unfocus = function()
        stop_grabber(input_grabber)
        active_text = reset_textbox(textbox, active_text, hidden, false)
    end

    --- Reset the inputfield, this means stop listening and reset the text
    -- @staticfct reset
    -- @usage -- Resets the inputfield
    -- inputfield.reset()
    widget.reset = function()
        widget.clear_text()
        widget.stop_grabbing()
    end

    return widget
end
