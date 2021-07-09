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

local icons = require("theme.icons")
local serialize = require("lib-tde.serialize")

local checkbox = require("lib-widget.checkbox")

local signals = require("lib-tde.signals")

local STORAGE = os.getenv('HOME') .. '/.cache/tde/todos.json'

local rows  = { layout = wibox.layout.fixed.vertical }
local todo_widget = {}
local update_widget
local data = serialize.deserialize_from_file(STORAGE)

todo_widget.widget = wibox.widget {
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

function todo_widget:update_counter(todos)
    local todo_count = 0
    for _,p in ipairs(todos) do
        if not p.status then
            todo_count = todo_count + 1
        end
    end

    todo_widget.widget:set_text(todo_count)
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

local function add_prompt(text, active, index)
    if bIsInPrompt then
        return
    end
    active = active or false
    index = index or #data.todo_items
    -- when the #data.todo_items == 0
    if index < 1 then
        index = 1
    end
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

    bIsInPrompt = true

    awful.prompt.run{
        prompt = "<b>" .. i18n.translate("New Item") .. "</b>: ",
        bg = beautiful.bg_modal,
        bg_cursor = beautiful.primary.hue_700,
        textbox = pr.widget,
        text = text or "",
        exe_callback = function(input_text)
            if not input_text or #input_text == 0 then return end
            table.insert(data.todo_items, index, {todo_item = input_text, status = active})

            serialize.serialize_to_file(STORAGE, data)
        end,
        -- make sure that cancelling the prompt also cleanly stops
        done_callback = function()
            update_widget()
            bIsInPrompt = false
        end
    }

    popup:setup(rows)
end

add_button:connect_signal("button::press", function()
    add_prompt("")
end)
add_button:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.primary.hue_800) end)
add_button:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_modal) end)

local function worker(user_args)

    local args = user_args or {}

    local icon = args.icon or icons.check

    todo_widget.widget:set_icon(icon)

    function update_widget()
        if data == nil or data == '' then data = {} end
        todo_widget:update_counter(data.todo_items)

        popup.bg = beautiful.background.hue_800 .. beautiful.background_transparency

        for i = 0, #rows do rows[i]=nil end

        local first_row = wibox.widget {
            {
                {widget = wibox.widget.textbox},
                {
                    markup = '<span size="large" font_weight="bold" color="#ffffff">' .. i18n.translate("Todo list").. '</span>',
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

        for i, todo_item in ipairs(data.todo_items) do

            local box = checkbox(todo_item.status, function(checked)
                todo_item.status = checked
                data.todo_items[i] = todo_item
                serialize.serialize_to_file(STORAGE, data)
                todo_widget:update_counter(data.todo_items)
            end)

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
                table.remove(data.todo_items, i)
                serialize.serialize_to_file(STORAGE, data)
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
                local item = data.todo_items[i]
                table.remove(data.todo_items, i)
                update_widget()
                add_prompt(item.todo_item, item.status, i)
            end)


            local move_up = wibox.widget {
                image = icons.arrow_up,
                resize = false,
                widget = wibox.widget.imagebox
            }

            move_up:connect_signal("button::press", function()
                local temp = data.todo_items[i]
                data.todo_items[i] = data.todo_items[i-1]
                data.todo_items[i-1] = temp
                serialize.serialize_to_file(STORAGE, data)
                update_widget()
            end)

            local move_down = wibox.widget {
                image = icons.arrow_down,
                resize = false,
                widget = wibox.widget.imagebox
            }

            move_down:connect_signal("button::press", function()
                local temp = data.todo_items[i]
                data.todo_items[i] = data.todo_items[i+1]
                data.todo_items[i+1] = temp
                serialize.serialize_to_file(STORAGE, data)
                update_widget()
            end)


            local move_buttons = {
                layout = wibox.layout.fixed.vertical
            }

            if i == 1 and #data.todo_items > 1 then
                table.insert(move_buttons, move_down)
            elseif i == #data.todo_items and #data.todo_items > 1 then
                table.insert(move_buttons, move_up)
            elseif #data.todo_items > 1 then
                table.insert(move_buttons, move_up)
                table.insert(move_buttons, move_down)
            end

            local row = wibox.widget {
                {
                    {
                        {
                            box,
                            valign = 'center',
                            layout = wibox.container.place,
                        },
                        {
                            {
                                text = todo_item.todo_item,
                                align = 'left',
                                widget = wibox.widget.textbox
                            },
                            left = dpi(10),
                            layout = wibox.container.margin
                        },
                        {
                            {
                                move_buttons,
                                valign = 'center',
                                layout = wibox.container.place,
                            },
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

            row:connect_signal("mouse::enter", function(c) c:set_bg(beautiful.primary.hue_800 .. '66') end)
            row:connect_signal("mouse::leave", function(c) c:set_bg(beautiful.bg_modal) end)

            table.insert(rows, row)
        end

        popup:setup(rows)

        popup:connect_signal(
        "mouse::leave",
        function()
            todo_widget.widget.bg = beautiful.transparent
            popup.visible = false
        end
        )
    end

    signals.connect_background_theme_changed(function (_)
        update_widget()
    end)

    todo_widget.widget:buttons(
            gears.table.join(
                    awful.button({}, 1, function()
                        -- chances are people either edited the json
                        -- or another process changed it
                        data = serialize.deserialize_from_file(STORAGE) or data
                        update_widget()
                        if popup.visible then
                            todo_widget.widget.bg = beautiful.transparent
                            popup.visible = not popup.visible
                        else
                            todo_widget.widget.bg = beautiful.groups_bg
                            local geometry = {
                                x = mouse.coords().x,
                                y = mouse.screen.geometry.y + dpi(20),
                                width = 10,
                                height = 10
                            }
                            popup:move_next_to(geometry)
                        end
                    end)
            )
    )

    todo_widget.widget:connect_signal("mouse::enter", function() todo_widget.widget.bg = beautiful.groups_bg end)
    todo_widget.widget:connect_signal("mouse::leave", function() if popup.visible then return end todo_widget.widget.bg = beautiful.transparent end)

    update_widget()

    return todo_widget.widget
end

if not gfs.file_readable(STORAGE) then
    data = {
        todo_items = {}
    }
    serialize.serialize_to_file(STORAGE, data)
end

return worker({})