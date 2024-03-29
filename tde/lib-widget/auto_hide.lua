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
-- Create a new fading widget
--
-- Useful when you want to hide widgets
--
--    -- auto_hide the wibox out when not hovering over it after 1 second
--    local auto_hider = lib-widget.auto_hide(wibox, 1)
--
--
-- @author Tom Meyers
-- @copyright 2020 Tom Meyers
-- @tdewidget lib-widget.auto_hide
-- @supermodule wibox.widget.base
---------------------------------------------------------------------------

local wibox = require("wibox")
local animate = require("lib-tde.animations").createAnimObject
local gears = require("gears")
local signals = require('lib-tde.signals')
local logger = require("lib-tde.logger")

--- Create a new auto_hide widget
-- @tparam wibox args.wibox The wibox that should auto_hide when hovering
-- @tparam[opt] number args.auto_hide_time After x seconds of not being in the wibox when should the fading start
-- @staticfct auto_hide
-- @usage -- This will create a fading wibox
-- local separate = lib-widget.auto_hide({wibox = wibox, auto_hide_time = 1 })
return function(args)
    if args == nil then args = {} end
    local box = args.wibox or {}
    local auto_hide_time = args.auto_hide_time or 0.5

    if box.struts == nil then
        print("Auto Hide widget only support wiboxes as a parameter, but got: " .. tostring(box) , logger.warn)
        return box
    end

    local enabled = _G.save_state.auto_hide

    local _struts = box:struts()

    local widget = wibox {
        screen = box.screen,
        height = box.height,
        width = box.width,
        x = box.x,
        y = box.y,
        type = 'utility',
        visible = false,
        bg = "#FFFFFF00",
        ontop = true
    }

    widget:setup {
        layout = wibox.layout.align.vertical,
        wibox.widget.textbox('')
    }

    local isFading = false

    local function is_in_box(x)
        x = x or box
        return mouse.current_wibox == x
    end

    local function _enter()
        if isFading then
            box.stop_animation(true)
        end

        print("Entered auto_hide")
        isFading = true

        box.opacity = 0
        box.visible = true
        animate(
            _G.anim_speed * 2,
            box,
            {opacity = 1},
            "outCubic",
            function ()
                -- There is an edge case when disabling auto_hide that the animation is still playing
                -- In that case don't hide the widget, instead show it
                if enabled then
                    widget.visible = false
                else
                    box.opacity = 1
                end
                isFading = false
            end
        )
    end

    local function _leave()
        if isFading then
            box.stop_animation()
        end

        print("Exited auto_hide")
        box.opacity = 1
        box.visible = true
        isFading = true
        animate(
            _G.anim_speed * 2,
            box,
            {opacity = 0},
            "outCubic",
            function ()
                -- There is an edge case when disabling auto_hide that the animation is still playing
                -- In that case don't hide the widget, instead show it
                if enabled then
                    widget.visible = true
                    box.visible = false
                    box.opacity = 1
                else
                    widget.visible = false
                    box.visible = true
                    box.opacity = 1
                end
                isFading = false
            end
        )
    end

    -- debouncing the inputs by auto_hide_time seconds
    local function enter()
        _enter()
    end

    local function leave()
        gears.timer {
            timeout = auto_hide_time,
            autostart = true,
            single_shot = true,
            callback = function()
                -- if it is still in the wibox then trigger enter
                if not is_in_box() then
                    _leave()
                end
            end
        }
    end

    -- When changing the tag the taglist refreshes and sets box.visible to true
    -- This can cause incorrect behaviour when changing tags
    -- This function checks to see if the box should be visible or not
    -- based on the mouse cursor
    local function detect_box_value()
        -- don't do anything
        if isFading then
            return
        end

        if is_in_box() then
            box.visible = true
            box.opacity = 1
            widget.visible = false
        else
            box.visible = false
            box.opacity = 0
            widget.visible = true
        end
    end

    local function connect_signals()
        -- connect the signals of both wiboxes
        widget.widget:connect_signal('mouse::enter', enter)
        box.widget:connect_signal('mouse::enter', enter)
        widget.widget:connect_signal('mouse::leave', leave)
        box.widget:connect_signal('mouse::leave', leave)

        -- connect signal for tag_list changed
        box.screen:connect_signal('tag::history::update', detect_box_value)
    end

    local function disconnect_signals()
        -- connect the signals of both wiboxes
        widget.widget:disconnect_signal('mouse::enter', enter)
        box.widget:disconnect_signal('mouse::enter', enter)
        widget.widget:disconnect_signal('mouse::leave', leave)
        box.widget:disconnect_signal('mouse::leave', leave)

        -- connect signal for tag_list changed
        box.screen:disconnect_signal('tag::history::update', detect_box_value)
    end

    widget.remove = function()
        disconnect_signals()
        box.opacity = 1
        box.visible = true
        widget.visible = false
        widget = nil
        enabled = false
    end

    box.auto_hider = widget

    if enabled then
        connect_signals()
        box.visible = false
        widget.visible = true

        box:struts {
            right = 0,
            left = 0,
            top = 0,
            bottom = 0
        }
    end

    signals.connect_auto_hide(function (bIsEnabled)
        if widget == nil then
            return
        end

        print("Connected auto_hide")

        if bIsEnabled and not enabled then
            connect_signals()
            enabled = true
            detect_box_value()
            box:struts {
                right = 0,
                left = 0,
                top = 0,
                bottom = 0
            }
        else
            widget.visible = false
            box.opacity = 1
            box.visible = true
        end

        if not bIsEnabled and enabled then
            disconnect_signals()
            enabled = false
            box:struts(_struts)
        end
    end)

    return box
end
