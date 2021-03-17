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
-------------------------------------------------
-- Docker Widget for Awesome Window Manager
-- Lists containers and allows to manage them
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/docker-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local wibox = require("wibox")
local spawn = require("awful.spawn")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")
local clickable_container = require("widget.material.clickable-container")
local dpi = require("beautiful").xresources.apply_dpi

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. "/.config/tde/docker-widget"
local ICONS_DIR = WIDGET_DIR .. "/icons/"

local LIST_CONTAINERS_CMD =
    [[bash -c "docker container ls -a -s -n %s --format '{{.Names}}::{{.ID}}::{{.Image}}::{{.Status}}::{{.Size}}'"]]

--- Utility function to show warning messages
local function show_warning(message)
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Docker Widget",
        text = message
    }
end

local popup =
    awful.popup {
    ontop = true,
    visible = false,
    shape = gears.shape.rounded_rect,
    border_width = 1,
    border_color = beautiful.bg_focus,
    maximum_width = 400,
    offset = {y = 5},
    widget = {}
}

local grabber =
    awful.keygrabber {
    keybindings = {
        awful.key {
            modifiers = {},
            key = "Escape",
            on_press = function()
                popup.visible = false
            end
        }
    },
    -- Note that it is using the key name and not the modifier name.
    stop_key = "Escape",
    stop_event = "release"
}

local widget =
    wibox.widget {
    {
        {
            id = "icon",
            widget = wibox.widget.imagebox
        },
        margins = 4,
        layout = wibox.container.margin
    },
    layout = wibox.layout.fixed.horizontal,
    set_icon = function(self, new_icon)
        self:get_children_by_id("icon")[1].image = new_icon
    end
}

local docker_widget =
    clickable_container(
    --dpi(14) is used to take different screen sizes into consideration
    wibox.container.margin(widget, dpi(14), dpi(14), dpi(3), dpi(3))
)

local parse_container = function(line)
    local name, id, image, status, how_long, size = line:match("(.*)::(.*)::(.*)::(%w*) (.*)::(.*)")
    local actual_status
    if status == "Up" and how_long:find("Paused") then
        actual_status = "Paused"
    else
        actual_status = status
    end

    how_long = how_long:gsub("%s?%(.*%)%s?", "")
    -- if how_long:find('seconds') then how_long = 'less than a minute ago' end

    local container = {
        name = name,
        id = id,
        image = image,
        status = actual_status,
        how_long = how_long,
        size = size,
        is_up = function()
            return status == "Up"
        end,
        is_paused = function()
            return actual_status:find("Paused")
        end,
        is_exited = function()
            return status == "Exited"
        end
    }
    return container
end

local status_to_icon_name = {
    Up = ICONS_DIR .. "play.svg",
    Exited = ICONS_DIR .. "square.svg",
    Paused = ICONS_DIR .. "pause.svg"
}

local function worker(args)
    args = args or {}

    local icon = args.icon or ICONS_DIR .. "docker.svg"
    local number_of_containers = args.number_of_containers or -1

    widget:set_icon(icon)

    local rows = {
        {widget = wibox.widget.textbox},
        layout = wibox.layout.fixed.vertical
    }

    local function rebuild_widget(stdout, stderr, _, _)
        if stderr ~= "" then
            show_warning(stderr)
            return
        end

        for i = 0, #rows do
            rows[i] = nil
        end

        for line in stdout:gmatch("[^\r\n]+") do
            local container = parse_container(line)

            local status_icon =
                wibox.widget {
                image = status_to_icon_name[container["status"]],
                resize = false,
                widget = wibox.widget.imagebox
            }

            local start_stop_button
            if container.is_up() or container.is_exited() then
                start_stop_button =
                    wibox.widget {
                    {
                        id = "icon",
                        image = ICONS_DIR .. (container:is_up() and "stop-btn.svg" or "play-btn.svg"),
                        opacity = 0.4,
                        resize = false,
                        widget = wibox.widget.imagebox
                    },
                    left = 2,
                    right = 2,
                    layout = wibox.container.margin
                }
                start_stop_button:connect_signal(
                    "mouse::enter",
                    function(c)
                        c:get_children_by_id("icon")[1]:set_opacity(1)
                        c:get_children_by_id("icon")[1]:emit_signal("widget::redraw_needed")
                    end
                )
                start_stop_button:connect_signal(
                    "mouse::leave",
                    function(c)
                        c:get_children_by_id("icon")[1]:set_opacity(0.4)
                        c:get_children_by_id("icon")[1]:emit_signal("widget::redraw_needed")
                    end
                )

                start_stop_button:buttons(
                    awful.util.table.join(
                        awful.button(
                            {},
                            1,
                            function()
                                local command
                                if container:is_up() then
                                    command = "stop"
                                else
                                    command = "start"
                                end

                                status_icon:set_opacity(0.2)
                                status_icon:emit_signal("widget::redraw_needed")

                                awful.spawn.easy_async(
                                    "docker " .. command .. " " .. container["name"],
                                    function(_, stderr_2)
                                        if stderr_2 ~= "" then
                                            show_warning(stderr_2)
                                        end
                                        spawn.easy_async(
                                            string.format(LIST_CONTAINERS_CMD, number_of_containers),
                                            function(stdout_3, stderr_3)
                                                rebuild_widget(stdout_3, stderr_3)
                                            end
                                        )
                                    end
                                )
                            end
                        )
                    )
                )
            else
                start_stop_button = nil
            end

            local pause_unpause_button
            if container.is_up() then
                pause_unpause_button =
                    wibox.widget {
                    {
                        id = "icon",
                        image = ICONS_DIR .. (container:is_paused() and "unpause-btn.svg" or "pause-btn.svg"),
                        opacity = 0.4,
                        resize = false,
                        widget = wibox.widget.imagebox
                    },
                    left = 2,
                    right = 2,
                    layout = wibox.container.margin
                }
                pause_unpause_button:connect_signal(
                    "mouse::enter",
                    function(c)
                        c:get_children_by_id("icon")[1]:set_opacity(1)
                        c:get_children_by_id("icon")[1]:emit_signal("widget::redraw_needed")
                    end
                )
                pause_unpause_button:connect_signal(
                    "mouse::leave",
                    function(c)
                        c:get_children_by_id("icon")[1]:set_opacity(0.4)
                        c:get_children_by_id("icon")[1]:emit_signal("widget::redraw_needed")
                    end
                )

                pause_unpause_button:buttons(
                    awful.util.table.join(
                        awful.button(
                            {},
                            1,
                            function()
                                local command
                                if container:is_paused() then
                                    command = "unpause"
                                else
                                    command = "pause"
                                end

                                status_icon:set_opacity(0.2)
                                status_icon:emit_signal("widget::redraw_needed")

                                awful.spawn.easy_async(
                                    "docker " .. command .. " " .. container["name"],
                                    function(_, stderr2)
                                        if stderr2 ~= "" then
                                            show_warning(stderr2)
                                        end
                                        spawn.easy_async(
                                            string.format(LIST_CONTAINERS_CMD, number_of_containers),
                                            function(stdout3, stderr3)
                                                rebuild_widget(stdout3, stderr3)
                                            end
                                        )
                                    end
                                )
                            end
                        )
                    )
                )
            else
                pause_unpause_button = nil
            end

            local row =
                wibox.widget {
                {
                    {
                        {
                            {
                                status_icon,
                                margins = 8,
                                layout = wibox.container.margin
                            },
                            valigh = "center",
                            layout = wibox.container.place
                        },
                        {
                            {
                                {
                                    markup = "<b>" .. container["name"] .. "</b>",
                                    widget = wibox.widget.textbox
                                },
                                {
                                    text = container["size"],
                                    widget = wibox.widget.textbox
                                },
                                {
                                    text = container["how_long"],
                                    widget = wibox.widget.textbox
                                },
                                forced_width = 180,
                                layout = wibox.layout.fixed.vertical
                            },
                            valigh = "center",
                            layout = wibox.container.place
                        },
                        {
                            {
                                start_stop_button,
                                pause_unpause_button,
                                layout = wibox.layout.align.horizontal
                            },
                            forced_width = 60,
                            valign = "center",
                            haligh = "center",
                            layout = wibox.container.place
                        },
                        spacing = 8,
                        layout = wibox.layout.align.horizontal
                    },
                    margins = 8,
                    layout = wibox.container.margin
                },
                bg = beautiful.transparent,
                widget = wibox.container.background
            }

            table.insert(rows, row)
        end

        popup:setup(rows)
    end

    docker_widget:buttons(
        awful.util.table.join(
            awful.button(
                {},
                1,
                function()
                    if popup.visible then
                        popup.visible = not popup.visible
                        grabber:stop()
                    else
                        spawn.easy_async(
                            string.format(LIST_CONTAINERS_CMD, number_of_containers),
                            function(stdout, stderr)
                                rebuild_widget(stdout, stderr)
                                popup:move_next_to(mouse.current_widget_geometry)
                                grabber:start()
                            end
                        )
                    end
                end
            )
        )
    )

    return docker_widget
end

return worker()
