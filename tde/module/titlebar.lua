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
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local signals = require('lib-tde.signals')

local mat_colors = require("theme.mat-colors")

local dpi = beautiful.xresources.apply_dpi

local drawTitleBar = general["draw_mode"] == "fast"

local pallet_index = 1

local pallets = {
    -- primary color
    {
        focus = mat_colors.red.hue_300,
        unfocus = mat_colors.red.hue_300
    },
    -- yellow
    {
        focus = mat_colors.yellow.hue_300,
        unfocus = mat_colors.yellow.hue_500
    },
    -- green
    {
        focus = mat_colors.green.hue_300,
        unfocus = mat_colors.green.hue_500
    },
    -- purple
    {
        focus = mat_colors.purple.hue_300,
        unfocus = mat_colors.purple.hue_500
    },
    -- blue
    {
        focus = mat_colors.blue.hue_300,
        unfocus = mat_colors.blue.hue_500
    },
    -- primary
    {
        focus = beautiful.primary.hue_300,
        unfocus = beautiful.primary.hue_500
    }
}


local function rounded_button(tooltip, tooltip_off, callback, bIsTooltipCB)
    tooltip     = i18n.translate(tooltip)
    tooltip_off = i18n.translate(tooltip_off)

    local pallet = pallets[pallet_index]

    pallet_index = pallet_index + 1

    if pallet_index > #pallets then
        pallet_index = 1
    end

    local size = dpi(14)

    local widget = wibox.container.background(wibox.widget.base.empty_widget())
    widget.forced_width = size
    widget.forced_height = size

    widget.shape = gears.shape.circle

    widget.bg = pallet.unfocus

    local active_tooltip_text = tooltip

    local function update_tooltip()
        local bIsTooltip = true

        if bIsTooltipCB ~= nil then
            bIsTooltip = bIsTooltipCB()
        end

        if bIsTooltip then
            active_tooltip_text = tooltip_off
        else
            active_tooltip_text = tooltip
        end
    end

    -- make the nice hover effects
    widget:connect_signal("mouse::enter", function ()
        widget.bg = pallet.focus
    end)

    widget:connect_signal("mouse::leave", function ()
        widget.bg = pallet.unfocus
    end)

    -- trigger the callback when the widget is pressed
    widget:connect_signal("button::press", function ()
        if callback then
            callback()
        end

        update_tooltip()
    end)

    awful.tooltip {
        objects        = { widget },
        mode = "outside",
        preferred_positions = "bottom",
        gaps = dpi(5),
        timer_function = function()
            return active_tooltip_text
        end
    }

    update_tooltip()

    return widget
end

client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({ }, 1, function()
            c:activate { context = "titlebar", action = "mouse_move"  }
        end),
        awful.button({ }, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize"}
        end),
    }

    local widget = wibox.widget {
        -- left
        wibox.container.margin(wibox.widget {
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(5),
            rounded_button("close", "open", function() c:kill() end),
            rounded_button("minimize", "un-minimize", function() c.minimized = not c.minimized end, function() return c.minimized end),
            rounded_button("maximize", "un-maximize", function() c.maximized = not c.maximized end, function() return c.maximized end)
        }, dpi(10),0,0,0),
        -- center
        wibox.widget {
            { -- Title
            align  = 'center',
            widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        -- right
        wibox.container.margin(wibox.widget {
            rounded_button("sticky", "un-stick", function() c.sticky = not c.sticky end, function() return c.sticky end),
            rounded_button("ontop", "disable ontop", function() c.ontop = not c.ontop end, function() return c.ontop end),
            rounded_button("floating", "tiling", function() c.floating = not c.floating end, function() return c.floating end),
            spacing = dpi(5),
            layout = wibox.layout.fixed.horizontal
        },0, dpi(10), 0,0),
        layout = wibox.layout.align.horizontal
    }

    local bar = awful.titlebar(c, {
        size      = dpi(20),
        bg = beautiful.background.hue_800 .. 'aa',}
    )

    bar.widget = widget
end)

local function update_titlebar(c)

    if c.requests_no_titlebar or not drawTitleBar then
        awful.titlebar.hide(c, "top")
        c.shape = nil
        return
    end

    if c.floating or c.titlebars_enabled or (c.screen.selected_tag.layout.name == "floating") then
        awful.titlebar.show(c, "top")
        c.shape = function (cr, w, h)
            return gears.shape.partially_rounded_rect(cr, w, h, true, true, false, false, dpi(10))
        end
    else
        awful.titlebar.hide(c, "top")
        c.shape = nil
    end
end

client.connect_signal("property::floating", function(c)
    update_titlebar(c)
end)

_G.tag.connect_signal(
    "property::layout",
    function(tag)
        local clients = tag:clients()
        for _, c in pairs(clients) do
            update_titlebar(c)
        end
    end
)

signals.connect_titlebar_redraw(function(bShouldDraw)
    drawTitleBar = bShouldDraw
    -- Lets update all client titlebars
    for _, c in ipairs(client.get()) do
        -- do something
        update_titlebar(c)
    end
end)