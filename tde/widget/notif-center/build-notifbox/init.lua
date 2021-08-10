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
local wibox = require('wibox')
local gears = require('gears')
local naughty = require('naughty')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'widget/notif-center/icons/'

local empty_notifbox = require(
                           'widget.notif-center.build-notifbox.empty-notifbox')
local notifbox_scroller = require(
                              'widget.notif-center.build-notifbox.notifbox-scroller')

local notif_core = {}

notif_core.remove_notifbox_empty = true

notif_core.notifbox_layout = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(10),
    empty_notifbox
}

notifbox_scroller(notif_core.notifbox_layout)

notif_core.reset_notifbox_layout = function()
    notif_core.notifbox_layout:reset()
    notif_core.notifbox_layout:insert(1, empty_notifbox)
    notif_core.remove_notifbox_empty = true
end

local notifbox_add = function(n, notif_icon, notifbox_color)
    if #notif_core.notifbox_layout.children == 1 and
        notif_core.remove_notifbox_empty then
        notif_core.notifbox_layout:reset(notif_core.notifbox_layout)
        notif_core.remove_notifbox_empty = false
    end

    local notifbox_box = require(
                             'widget.notif-center.build-notifbox.notifbox-builder')
    notif_core.notifbox_layout:insert(1, notifbox_box(n, notif_icon, n.title,
                                                      n.message, n.app_name,
                                                      notifbox_color))
end

local notifbox_add_expired = function(n, notif_icon, notifbox_color)
    n:connect_signal('destroyed', function(_, reason)
        if reason == 1 then notifbox_add(n, notif_icon, notifbox_color) end
    end)
end

naughty.connect_signal('added', function(n)
    local notifbox_color = beautiful.transparent
    if n.urgency == 'critical' then notifbox_color = n.bg .. '66' end

    local notif_icon = n.icon or n.app_icon
    if not notif_icon then
        notif_icon = widget_icon_dir .. 'new-notif' .. '.svg'
    end

    notifbox_add_expired(n, notif_icon, notifbox_color)
end)

return notif_core
