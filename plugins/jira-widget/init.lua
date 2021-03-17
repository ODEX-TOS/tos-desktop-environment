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
-- Jira Widget for Awesome Window Manager
-- Shows the number of currently assigned issues
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/jira-widget

-- @author Pavel Makhov and Tom Meyers
-- @copyright 2019 Pavel Makhov
-- @copyright 2020 Tom Meyers
-------------------------------------------------

local wibox = require("wibox")
local watch = require("awful.widget.watch")
local json = require("jira-widget.json")
local spawn = require("awful.spawn")
local naughty = require("naughty")
local gears = require("gears")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")
local clickable_container = require("widget.material.clickable-container")
local dpi = require("beautiful").xresources.apply_dpi

local HOME_DIR = os.getenv("HOME")

local host = ""
local result = {}

local GET_ISSUES_CMD =
    [[bash -c "curl -s --show-error -X GET -n '%s/rest/api/2/search?%s&fields=id,assignee,summary,status'"]]
local DOWNLOAD_AVATAR_CMD = [[bash -c "curl -n --create-dirs -o  %s/.cache/awmw/jira-widget/avatars/%s %s"]]

local function show_warning(message)
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Jira Widget",
        text = message
    }
end

local image =
    wibox.widget {
    {
        id = "c",
        widget = wibox.widget.imagebox
    },
    layout = wibox.layout.fixed.horizontal,
    set_icon = function(self, new_icon)
        self:get_children_by_id("c")[1].image = new_icon
    end
}

local button = wibox.container.margin(image, 0, dpi(5), 0, 0)

local jira_widget =
    wibox.widget {
    {
        {
            button,
            id = "b",
            layout = wibox.layout.stack
        },
        id = "a",
        margins = 4,
        layout = wibox.container.margin
    },
    {
        id = "txt",
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.fixed.horizontal,
    set_text = function(self, new_value)
        self.txt.text = new_value
    end,
    set_icon = function(_, path)
        image:set_icon(path)
    end,
    is_everything_ok = function(self, is_ok)
        if is_ok then
            image:set_opacity(1)
            image:emit_signal("widget:redraw_needed")
        else
            self.txt:set_text("")
            image:set_opacity(0.2)
            image:emit_signal("widget:redraw_needed")
        end
    end
}

local popup =
    awful.popup {
    ontop = true,
    visible = false,
    shape = gears.shape.rounded_rect,
    border_width = 1,
    border_color = beautiful.bg_focus,
    maximum_width = mouse.screen.geometry.width,
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

local number_of_issues

local warning_shown = false
local tooltip =
    awful.tooltip {
    mode = "outside",
    preferred_positions = {"bottom"}
}

local function createRow(issue, host_in, path_to_avatar)
    local row =
        wibox.widget {
        {
            {
                {
                    {
                        resize = true,
                        image = path_to_avatar,
                        forced_width = dpi(40),
                        forced_height = dpi(40),
                        widget = wibox.widget.imagebox
                    },
                    margins = 8,
                    layout = wibox.container.margin
                },
                {
                    {
                        markup = "<b>" .. issue.key .. "</b>",
                        align = "center",
                        forced_width = dpi(350), -- for horizontal alignment
                        widget = wibox.widget.textbox
                    },
                    {
                        text = issue.fields.summary,
                        widget = wibox.widget.textbox
                    },
                    {
                        text = issue.fields.status.name,
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.align.vertical
                },
                spacing = dpi(8),
                layout = wibox.layout.fixed.horizontal
            },
            margins = dpi(8),
            layout = wibox.container.margin
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }

    row:connect_signal(
        "mouse::enter",
        function(c)
            c:set_bg(beautiful.bg_focus)
        end
    )
    row:connect_signal(
        "mouse::leave",
        function(c)
            c:set_bg(beautiful.bg_normal)
        end
    )

    row:buttons(
        awful.util.table.join(
            awful.button(
                {},
                1,
                function()
                    spawn.with_shell("xdg-open " .. host_in .. "/browse/" .. issue.key)
                    popup.visible = false
                    grabber:stop()
                end
            )
        )
    )
    return row
end

local function createRowTable(issues, host_in)
    local rows = {
        {widget = wibox.widget.textbox},
        layout = wibox.layout.fixed.vertical
    }
    for _, issue in ipairs(issues) do
        local path_to_avatar = HOME_DIR .. "/.config/tde/jira-widget/jira-mark-gradient-blue.svg"
        if issue.fields.assignee.accountId ~= nil then
            path_to_avatar = os.getenv("HOME") .. "/.cache/awmw/jira-widget/avatars/" .. issue.fields.assignee.accountId

            if not gfs.file_readable(path_to_avatar) then
                spawn.easy_async(
                    string.format(
                        DOWNLOAD_AVATAR_CMD,
                        HOME_DIR,
                        issue.fields.assignee.accountId,
                        issue.fields.assignee.avatarUrls["48x48"]
                    )
                )
            end
        end
        table.insert(rows, createRow(issue, host_in, path_to_avatar))
    end
    return rows
end

local function createTable(result_in, host_in, maxelements)
    if maxelements == nil then
        maxelements = #result_in.issues
    end

    -- the partial variable hold the result set of one vertical table set
    local partialIssues = {}
    local previousTableIndex = 1
    -- arr holds the information about one vertical table set
    local arr = {}
    for index, issue in ipairs(result_in.issues) do
        -- get the index in the table
        local tableIndex = math.ceil(index / maxelements)
        if not (previousTableIndex == tableIndex) then
            table.insert(arr, createRowTable(partialIssues, host_in))
            -- reset variable for next vertical set
            partialIssues = {}
            previousTableIndex = tableIndex
        end
        table.insert(partialIssues, issue)
        print("Inserting issue: " .. issue.key .. " into " .. tableIndex)
    end
    table.insert(arr, createRowTable(partialIssues, host_in))
    local table_widget =
        wibox.widget {
        arr[1],
        arr[2],
        layout = wibox.layout.fixed.horizontal
    }
    --for _, row in ipairs(arr) do
    --   table_widget:add(
    --      {
    --         row,
    --        layout = wibox.layout.fixed.vertical
    --  }
    --)
    --end
    return table_widget
end

local function worker(args)
    args = args or {}

    local icon = args.icon or HOME_DIR .. "/.config/tde/jira-widget/jira-mark-gradient-blue.svg"
    host = args.host or show_warning("Jira host is unknown")
    local query = args.query or "jql=assignee=currentuser() AND resolution=Unresolved"

    jira_widget:set_icon(icon)

    local update_widget = function(widget, stdout, stderr, _, _)
        if stderr ~= "" then
            if not warning_shown then
                show_warning(stderr)
                warning_shown = true
                widget:is_everything_ok(false)
                tooltip:add_to_object(widget)

                widget:connect_signal(
                    "mouse::enter",
                    function()
                        tooltip.text = stderr
                    end
                )
            end
            return
        end

        warning_shown = false
        tooltip:remove_from_object(widget)
        widget:is_everything_ok(true)

        result = json.decode(stdout)

        number_of_issues = rawlen(result.issues)

        if number_of_issues == 0 then
            widget:set_visible(false)
            return
        end

        widget:set_visible(true)
        widget:set_text(number_of_issues)

        popup:setup {
            expand = "none",
            layout = wibox.layout.align.horizontal,
            createTable(result, host, 8)
        }
    end

    jira_widget:buttons(
        awful.util.table.join(
            awful.button(
                {},
                1,
                function()
                    if popup.visible then
                        popup.visible = not popup.visible
                        grabber:stop()
                    else
                        popup:move_next_to(mouse.current_widget_geometry)
                        grabber:start()
                    end
                end
            )
        )
    )
    watch(string.format(GET_ISSUES_CMD, host, query:gsub(" ", "+")), 10, update_widget, jira_widget)
    return clickable_container(wibox.container.margin(jira_widget, dpi(14), dpi(14), dpi(3), dpi(3)))
end

return worker(
    {
        host = "https://support.idalko.com"
    }
)
