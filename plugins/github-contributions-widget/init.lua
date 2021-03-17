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
-- Github Contributions Widget for Awesome Window Manager
-- Shows the contributions graph
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/github-contributions-widget

-- @author Pavel Makhov and Tom Meyers
-- @copyright 2020 Pavel Makhov
-- @copyright 2020 Tom Meyers
-------------------------------------------------

local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi

local GET_CONTRIBUTIONS_CMD =
    [[bash -c "curl -s https://github-contributions.now.sh/api/v1/%s | jq -r '[.contributions[] | select ( .date | strptime(\"%%Y-%%m-%%d\") | mktime < now)][:%s]| .[].color'"]]

local github_contributions_widget =
    wibox.widget {
    reflection = {
        horizontal = true,
        vertical = true
    },
    widget = wibox.container.mirror
}

local function worker(args)
    args = args or {}

    local username = args.username or "F0xedb"
    local days = args.days or 60
    local empty_color = args.empty_color or beautiful.background.hue_800
    local with_border = args.with_border
    local margin_top = args.margin_top or 1

    if with_border == nil then
        with_border = true
    end

    local function hex2rgb(hex)
        if hex == "#ebedf0" then
            hex = empty_color
        end
        hex = tostring(hex):gsub("#", "")
        return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
    end

    local function get_square(color)
        local r, g, b = hex2rgb(color)

        return wibox.widget {
            fit = function(_, _, _, _)
                return dpi(7), dpi(7)
            end,
            draw = function(_, _, cr, _, _)
                cr:set_source_rgb(r / 255, g / 255, b / 255)
                cr:rectangle(0, 0, with_border and dpi(5) or dpi(7), with_border and dpi(5) or dpi(7))
                cr:fill()
            end,
            layout = wibox.widget.base.make_widget
        }
    end

    local col = {layout = wibox.layout.fixed.vertical}
    local row = {layout = wibox.layout.fixed.horizontal}
    local a = 5 - os.date("%w")
    for _ = 0, a do
        table.insert(col, get_square("#ebedf0"))
    end

    local update_widget = function(_, stdout, _, _, _)
        for colors in stdout:gmatch("[^\r\n]+") do
            if a % 7 == 0 then
                table.insert(row, col)
                col = {layout = wibox.layout.fixed.vertical}
            end
            table.insert(col, get_square(colors))
            a = a + 1
        end
        github_contributions_widget:setup(
            {
                row,
                top = margin_top,
                layout = wibox.container.margin
            }
        )
    end

    awful.spawn.easy_async(
        string.format(GET_CONTRIBUTIONS_CMD, username, days),
        function(stdout, _)
            update_widget(github_contributions_widget, stdout)
        end
    )

    return github_contributions_widget
end

return worker(
    {
        username = "F0xedb"
    }
)
