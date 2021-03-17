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
local delayed_timer = require("lib-tde.function.delayed-timer")
local rounded = require("lib-tde.widget.rounded")

-- the x and y variables are used to show the current position
-- width and height are the sizes of your widget
-- fillFunc should be a function without any arguments that returns a number between 0 and 100
-- 0 indicating no resource and 100 is completly full
-- title is the text below the progress bar
-- timeout is an optional value that specifies how often to update the widget default to one second
-- bar_size is an optional value that specifies how thick the radial bar should be
local chart = function(x, y, width, height, title, fillFunc, timeout, _)
    timeout = timeout or 1

    local margin_ratio = 0.10 -- in percentage
    local bar_ratio = 0.75 -- in percentage

    local title_height = (height * bar_ratio) * (1 - margin_ratio * 2)
    local width_bar_margin_ratio = (1 - bar_ratio) / 2

    local box =
        wibox(
        {
            ontop = false,
            visible = true,
            x = x,
            y = y,
            type = "dock",
            bg = beautiful.background.hue_700 .. beautiful.background_transparency,
            border_width = 1,
            border_color = beautiful.background.hue_700 .. beautiful.background_transparency,
            width = width,
            height = height,
            shape = rounded(width * 0.1),
            screen = mouse.screen
        }
    )

    local title_widget =
        wibox.widget {
        text = title or "",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
        forced_height = title_height,
        forced_width = width
    }

    local progress_bar = wibox.widget.graph()
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.forced_width = width - (width * margin_ratio * 2)
    progress_bar.forced_height = height * bar_ratio
    progress_bar.step_width = ((width - (width * margin_ratio * 2)) / 100) + 1

    progress_bar.color = beautiful.primary.hue_500
    progress_bar.background_color = beautiful.background.hue_900

    box:setup {
        layout = wibox.layout.align.vertical,
        wibox.container.margin(
            progress_bar,
            width * width_bar_margin_ratio,
            width * width_bar_margin_ratio,
            height * margin_ratio,
            height * margin_ratio
        ),
        title_widget
    }

    delayed_timer(
        timeout,
        function()
            local res = math.floor(fillFunc())
            progress_bar:add_value(res)
        end,
        0
    )
end

-- the x and y variables are used to show the current position
-- width and height are the sizes of your widget
-- fillFunc should be a function without any arguments that returns a number between 0 and 100
-- 0 indicating no resource and 100 is completly full
-- title is the text below the progress bar
-- timeout is an optional value that specifies how often to update the widget default to one second
-- bar_size is an optional value that specifies how thick the radial bar should be
local radial = function(x, y, width, height, title, fillFunc, timeout, bar_size)
    timeout = timeout or 1
    bar_size = bar_size or 8

    local margin_ratio = 0.10 -- in percentage
    local bar_ratio = 0.75 -- in percentage

    local bar_width = width * bar_ratio
    -- bar_height is equal to bar_width in order to have a circle
    local bar_height = bar_width

    local title_height = (height - bar_height) * (1 - margin_ratio * 2)
    local width_bar_margin_ratio = (1 - bar_ratio) / 2

    local box =
        wibox(
        {
            ontop = false,
            visible = true,
            x = x,
            y = y,
            type = "dock",
            bg = beautiful.background.hue_700 .. beautiful.background_transparency,
            border_width = 1,
            border_color = beautiful.background.hue_700 .. beautiful.background_transparency,
            width = width,
            height = height,
            shape = rounded(width * 0.1),
            screen = mouse.screen
        }
    )

    local default_value = math.floor(fillFunc())

    local percentage =
        wibox.widget {
        text = default_value .. "%",
        align = "center",
        valign = "center",
        font = beautiful.title_font,
        widget = wibox.widget.textbox,
        forced_height = bar_height,
        forced_width = bar_width
    }

    local title_widget =
        wibox.widget {
        text = title or "",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
        forced_height = title_height,
        forced_width = width
    }

    local progress_bar = wibox.container.radialprogressbar()
    progress_bar.widget = percentage
    progress_bar.value = default_value
    progress_bar.min_value = 0
    progress_bar.max_value = 100
    progress_bar.border_width = bar_size
    progress_bar.color = beautiful.primary.hue_500
    progress_bar.border_color = beautiful.background.hue_900

    box:setup {
        layout = wibox.layout.align.vertical,
        wibox.container.margin(
            progress_bar,
            width * width_bar_margin_ratio,
            width * width_bar_margin_ratio,
            height * margin_ratio,
            height * margin_ratio
        ),
        title_widget
    }

    delayed_timer(
        timeout,
        function()
            local res = math.floor(fillFunc())
            progress_bar.value = res
            percentage.text = tostring(res) .. "%"
        end,
        0
    )
end

return {
    radial = radial,
    chart = chart
}
