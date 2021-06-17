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
-- this file is the "daemon" part that hooks directly into TDE
-- A helper script should use this file as the following:
-- tde-client "_G.dev_widget_refresh('the.import.location.of.the.new.widget')"
-- This will update the widget that is in that file
-- you can hook this up to an inotify script to auto load the widget :)

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local filehandle = require("lib-tde.file")
local icons = require("theme.icons")
local gears = require("gears")

local m = dpi(10)
local dev_widget_update_close_height = dpi(60)

-- Create dev_widget on every screen
screen.connect_signal(
    "request::desktop_decoration",
    function(scr)
        local divercence = m * 5

        local hub =
            wibox(
            {
                ontop = true,
                visible = false,
                type = "toolbar",
                bg = beautiful.background.hue_800 .. beautiful.background_transparency,
                width = (scr.workarea.width / 2) - divercence,
                height = scr.workarea.height,
                x = scr.workarea.x + (scr.workarea.width / 2) + divercence,
                y = scr.workarea.y,
                screen = scr
            }
        )

        local view_container = wibox.layout.flex.vertical()
        view_container.spacing = m

        _G.dev_widget_side_view_refresh = function(widget_path)
            local original_path = package.path
            local require_str = "calendar-widget"

            if widget_path then
                local dir = filehandle.dirname(widget_path)
                package.path = dir .. "?.lua;" .. dir .. "?/?.lua;" .. package.path
                require_str = filehandle.basename(widget_path)
            end
            view_container:reset()
            view_container:add(require(require_str))
            hub.visible = true

            package.path = original_path
        end

        local function close_hub()
            hub.visible = false
            -- remove the widget in the container
            -- as it is a developer widget and can cause memory and cpu leaks
            view_container:reset()
            -- we also perform a garbage collection cycle as we don't know what happens with the widget
            collectgarbage("collect")
        end

        local close = wibox.widget.imagebox(icons.close)
        close.forced_height = dev_widget_update_close_height
        close:buttons(gears.table.join(awful.button({}, 1, close_hub)))

        local close_button = wibox.container.place(close, "right")

        hub:setup {
            layout = wibox.layout.fixed.vertical,
            close_button,
            view_container
        }
    end
)
