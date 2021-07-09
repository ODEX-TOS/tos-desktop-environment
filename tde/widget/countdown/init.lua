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
-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-- @copyright 2021 Tom Meyers

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local dpi = require("beautiful").xresources.apply_dpi
local datetime = require('lib-tde.function.datetime')
local toHHMMSS = datetime.numberInSecToHMS
local toseconds = datetime.toSeconds

require("widget.countdown_timer_box")

local icons = require("theme.icons")
local serialize = require("lib-tde.serialize")
local STORAGE = os.getenv('HOME') .. '/.cache/tde/timers.json'

local signals = require("lib-tde.signals")

local rows  = { layout = wibox.layout.fixed.vertical }
local countdown_widget = {}
local update_widget
local data = serialize.deserialize_from_file(STORAGE)


local function toYYDDHHMMSS(seconds)
    local oneDay = 86400 -- in seconds
    if seconds > oneDay then
        local last_day_res = seconds % oneDay
        local hhmmss = toHHMMSS(last_day_res)

        local days = math.floor(seconds / oneDay)
        local weeks = math.floor(days / 7)
        local years = math.floor(weeks / 52)

        days = days % 7
        weeks = weeks % 52

        local res = ""

        if years > 1 then
            res = res .. tostring(years) .. ' ' .. i18n.translate("years") .. ' '
        elseif years == 1 then
            res = res .. tostring(years) .. ' ' .. i18n.translate("year") .. ' '
        end

        if weeks > 1 then
            res = res .. tostring(weeks) .. ' ' .. i18n.translate("weeks") .. ' '
        elseif weeks == 1 then
            res = res .. tostring(weeks) .. ' ' .. i18n.translate("week") .. ' '
        end

        if days > 1 then
            res = res .. tostring(days) .. ' ' .. i18n.translate("days") .. ' '
        elseif days == 1 then
            res = res .. tostring(days) .. ' ' .. i18n.translate("day") .. ' '
        end

        return res .. hhmmss
    end

    return toHHMMSS(seconds)
end

local function show_timer_done(msg)
    if awful.screen.focused().countdownOverlay then
        if mouse.current_client ~= nil and mouse.current_client.fullscreen then
            -- only play the timer sound
            awful.screen.focused().countdownOverlay.play()
        else
            awful.screen.focused().countdownOverlay.show(msg)
        end
    end
end

local function save(payload)
    local res = {
        countdown_items = {}
    }
    for _, v in ipairs(payload.countdown_items) do
        table.insert(res.countdown_items,
            {time = v.time, name = v.name, message = v.message}
        )
    end

    serialize.serialize_to_file(STORAGE, res)
end

countdown_widget.widget = wibox.widget {
    {
        {
            {
                {
                    id = "icon",
                    forced_height = dpi(16),
                    forced_width = dpi(16),
                    widget = wibox.widget.imagebox
                },
                valign = 'center',
                layout = wibox.container.place
            },
            {
                id = "txt",
                widget = wibox.widget.textbox
            },
            spacing = dpi(4),
            layout = wibox.layout.fixed.horizontal,
        },
        margins = dpi(4),
        layout = wibox.container.margin
    },
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(4))
    end,
    widget = wibox.container.background,
    set_text = function(self, new_value)
        self:get_children_by_id("txt")[1].text = new_value
    end,
    set_icon = function(self, new_value)
        self:get_children_by_id("icon")[1].image = new_value
    end
}

function countdown_widget:update_counter(countdowns)
    countdown_widget.widget:set_text(#countdowns)
end

local popup = awful.popup{
    bg = beautiful.background.hue_800 .. beautiful.background_transparency,
    ontop = true,
    visible = false,
    shape = gears.shape.rounded_rect,
    border_width = dpi(1),
    border_color = beautiful.primary.hue_800,
    maximum_width = dpi(400),
    offset = { y = dpi(20), x = dpi(200) },
    widget = {}
}

signals.connect_primary_theme_changed(function (pallet)
    popup.border_color = pallet.hue_800
end)


local add_button = wibox.widget {
    {
        {
            image = icons.plus,
            resize = true,
            widget = wibox.widget.imagebox
        },
        top = 11,
        left = 8,
        right = 8,
        layout = wibox.container.margin
    },
    shape = function(cr, width, height)
        gears.shape.circle(cr, width, height, dpi(12))
    end,
    widget = wibox.container.background
}

local bIsInPrompt = false

local function create_pr()
    local pr = awful.widget.prompt()

    table.insert(rows, wibox.widget {
        {
            {
                pr.widget,
                spacing = dpi(8),
                layout = wibox.layout.align.horizontal
            },
            margins = dpi(8),
            layout = wibox.container.margin
        },
        bg = beautiful.bg_modal,
        widget = wibox.container.background
    })

    return pr
end

local function add_txt_prompt(time, start, name, message, index, pr)

    -- we don't have a prompt to work with, let's create one
    if pr == nil then
        pr = create_pr()
    end

    awful.prompt.run{
        prompt = "<b>" .. i18n.translate("Message") .. "</b>: ",
        bg = beautiful.bg_modal,
        bg_cursor = beautiful.primary.hue_700,
        textbox = pr.widget,
        text = message or "",
        exe_callback = function(input_text)
            if not input_text or #input_text == 0 then return end
            table.insert(data.countdown_items, index, {time = time, start=start, name = name, message = input_text})
            save(data)
        end,
        -- make sure that cancelling the prompt also cleanly stops
        done_callback = function()
            update_widget()
            bIsInPrompt = false
        end
    }

    popup:setup(rows)
end


local function add_time_prompt(text, index)
    if bIsInPrompt then
        return
    end
    index = index or #data.countdown_items
    if index < 1 then
        index = 1
    end

    local pr = create_pr()

    bIsInPrompt = true

    awful.prompt.run{
        prompt = "<b>" .. i18n.translate("New timer") .. "</b>: ",
        bg = beautiful.bg_modal,
        bg_cursor = beautiful.primary.hue_700,
        textbox = pr.widget,
        text = text or "1m",
        exe_callback = function(input_text)
            if not input_text or #input_text == 0 then return end
            add_txt_prompt(os.time() + toseconds(input_text),
            os.time(),
            input_text, "", index, pr)
        end,
    }

    popup:setup(rows)
end

add_button:connect_signal("button::press", function()
    add_time_prompt("")
end)
add_button:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.primary.hue_800) end)
add_button:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_modal) end)

local function worker(user_args)

    local args = user_args or {}

    local icon = args.icon or icons.clock_add

    countdown_widget.widget:set_icon(icon)

    -- remove datapoints that are no longer valid, eg should have gone off in the past
    for i, item in ipairs(data.countdown_items) do
        if item.time < (os.time() - 10) then
            table.remove(data.countdown_items, i)
        end
    end

    save(data)

    function update_widget()
        if data == nil or data == '' then data = {} end
        countdown_widget:update_counter(data.countdown_items)

        popup.bg = beautiful.background.hue_800 .. beautiful.background_transparency

        for i = 0, #rows do rows[i]=nil end

        local first_row = wibox.widget {
            {
                {widget = wibox.widget.textbox},
                {
                    markup = '<span size="large" font_weight="bold" color="#ffffff">' .. i18n.translate("Timer list").. '</span>',
                    align = 'center',
                    forced_width = dpi(350), -- for horizontal alignment
                    forced_height = dpi(40),
                    widget = wibox.widget.textbox
                },
                add_button,
                spacing = dpi(8),
                layout = wibox.layout.fixed.horizontal
            },
            bg = beautiful.bg_modal,
            widget = wibox.container.background
        }

        table.insert(rows, first_row)

        for i, countdown_item in ipairs(data.countdown_items) do
            local trash_button = wibox.widget {
                {
                    image = icons.close,
                    resize = true,
                    forced_height = dpi(30),
                    forced_width = dpi(30),
                    widget = wibox.widget.imagebox,
                },
                margins = dpi(5),
                layout = wibox.container.margin
            }

            trash_button:connect_signal("button::press", function()
                table.remove(data.countdown_items, i)
                save(data)
                update_widget()
            end)

            local edit_button = wibox.widget {
                {
                    image = icons.brush,
                    resize = true,
                    forced_height = dpi(20),
                    forced_width = dpi(20),
                    widget = wibox.widget.imagebox,
                },
                margins = dpi(5),
                layout = wibox.container.margin
            }

            edit_button:connect_signal("button::press", function()
                local item = data.countdown_items[i]
                table.remove(data.countdown_items, i)
                update_widget()
                add_txt_prompt(item.time, item.start, item.name, item.message, i)
            end)

            local row = wibox.widget {
                {
                    {
                        {
                            {
                                text = "",
                                id = 'text',
                                align = 'left',
                                widget = wibox.widget.textbox
                            },
                            left = dpi(10),
                            layout = wibox.container.margin
                        },
                        {
                            {
                                text = "",
                                id = 'text',
                                align = 'right',
                                widget = wibox.widget.textbox
                            },
                            right = dpi(10),
                            layout = wibox.container.margin
                        },
                        {
                            {
                                edit_button,
                                valign = 'center',
                                layout = wibox.container.place,
                            },
                            {
                                trash_button,
                                valign = 'center',
                                layout = wibox.container.place,
                            },
                            spacing = dpi(8),
                            layout = wibox.layout.align.horizontal
                        },
                        spacing = dpi(8),
                        layout = wibox.layout.align.horizontal
                    },
                    margins = dpi(8),
                    layout = wibox.container.margin
                },
                bg = beautiful.bg_modal,
                widget = wibox.container.background
            }

            row.update_text = function ()
                row:get_children_by_id("text")[1].text = countdown_item.message or ""
                row:get_children_by_id("text")[2].text = toYYDDHHMMSS(countdown_item.time - os.time())
            end

            row.update_text()

            row:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.primary.hue_800 .. '66') end)
            row:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_modal) end)

            table.insert(rows, row)
        end

        popup:setup(rows)

        popup:connect_signal(
        "mouse::leave",
        function()
            countdown_widget.widget.bg = beautiful.transparent
            popup.visible = false
        end
        )
    end

    signals.connect_background_theme_changed(function (_)
        update_widget()
    end)

    countdown_widget.widget:buttons(
            gears.table.join(
                    awful.button({}, 1, function()
                        -- chances are people either edited the json
                        -- or another process changed it
                        data = serialize.deserialize_from_file(STORAGE) or data
                        update_widget()
                        if popup.visible then
                            countdown_widget.widget.bg = beautiful.transparent
                            popup.visible = not popup.visible
                        else
                            countdown_widget.widget.bg = beautiful.groups_bg
                            local geometry = {
                                x = mouse.coords().x,
                                y = mouse.screen.geometry.y + dpi(20),
                                width = 1,
                                height = 1
                            }
                            popup:move_next_to(geometry)
                        end
                    end)
            )
    )

    gears.timer {
        timeout   = 1,
        call_now  = false,
        autostart = true,
        callback  = function()
            for i, item in ipairs(data.countdown_items) do
                if item.time < os.time() then
                    print(item.name .. ' is finished')
                    table.remove(data.countdown_items, i)
                    table.remove(rows, i+1)
                    -- to update the rows after deletion
                    popup:setup(rows)
                    countdown_widget:update_counter(data.countdown_items)

                    show_timer_done(item.message)
                end
            end

            save(data)

            for i, row in ipairs(rows) do
                if i > 1 then
                    row.update_text()
                end
            end
        end
    }

    countdown_widget.widget:connect_signal("mouse::enter", function() countdown_widget.widget.bg = beautiful.groups_bg end)
    countdown_widget.widget:connect_signal("mouse::leave", function() if popup.visible then return end countdown_widget.widget.bg = beautiful.transparent end)

    update_widget()

    return countdown_widget.widget
end

if not gfs.file_readable(STORAGE) then
    data = {
        countdown_items = {}
    }
    save(data)
end

return worker({})