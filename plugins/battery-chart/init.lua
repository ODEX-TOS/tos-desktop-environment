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
local card = require("lib-widget.card")
local progressbar = require("lib-widget.progress_bar")
local gears = require("gears")
local datetime = require("lib-tde.function.datetime")

local battery = require("lib-tde.function.battery")
local battery_initial_value = battery.getBatteryPercentage()
local bIsCharging = false

local config = require("config")

local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local signals = require("lib-tde.signals")
local mat_colors = require("theme.mat-colors")

local base_path = require('lib-tde.plugin').path()

signals.connect_battery_charging(function(isCharging)
    bIsCharging = isCharging
end)

local function rect_shape(cr, width, height)
    return gears.shape.rectbubbleh(cr, width, height, dpi(10), height/8)
end

local function create()
    local _card = card()

    local textbox = wibox.widget.textbox()
    textbox.font = beautiful.font_type .. " 55"
    textbox.align = "center"

    local hintbox = wibox.widget.textbox()
    hintbox.align = "center"

    local _width = dpi(300)

    -- Show the next 3 hours
    local steps = math.floor((3600 * 3) / config.battery_timeout)
    local percentages = {battery_initial_value}

    local colors = {
        '#000',
        '#A8A8A8'
    }

    local graph = wibox.widget {
        max_value = 100,
        min_value = 0,
        step_spacing = 0,
        widget = wibox.widget.graph,
        background_color = beautiful.background.hue_900 .. beautiful.background_transparency,
        height = dpi(200),
        width = _width,
        stack = true,
        stack_colors = colors,
        step_width = _width / steps,
    }

    local bar = progressbar()
    bar:theme_color(false)

    bar._private.progress_bar.shape = rect_shape

    bar.forced_width = dpi(650)
    bar.forced_height = _width

    local function draw_graph(percentage, step_size_in_seconds)
        step_size_in_seconds = step_size_in_seconds or config.battery_timeout
        table.insert(percentages, percentage)

        -- make sure our array doesn't grow to big, all unneeded space can be cleaned
        -- We leave 50% for the battery state and 50 percent of the space for the estimated range
        if #percentages > steps/2 then
            table.remove(percentages, 1)
        end

        graph:clear()

        for _, _percent in ipairs(percentages) do
            graph:add_value(_percent, 1, false)
            graph:add_value(0, 2, false)
        end

        -- Let's try to estimate what will happen based on the previous 5 minutes of the battery
        -- We do this by finding the average incline of the battery and then extrapolating that for the remainder of this hour
        local _steps = (5 * 60) / config.battery_timeout
        local count = 0
        local _valid_steps = 0

        for i = #percentages-_steps, #percentages, 1 do
            if percentages[i] ~= nil and percentages[i-1] ~= nil then
                count = count + (percentages[i] - percentages[i-1])
                _valid_steps = _valid_steps + 1
            end
        end

        -- we will not be providing an estimate in case we have no datapoints
        if count == 0 then return '...' end

        local average_incline =  count / _valid_steps

        -- In case the battery is at 100% or disconnected we won't be provinding an estimate
        if average_incline == 0 then return '∞'end

        -- Let's fill in the extrapolated data in the graph
        local new_percentage = percentage
        local time_in_seconds = 0
        -- make sure we are not in an infinite loop
        local i = 0
        while new_percentage > 0 and new_percentage < 100 and i < steps do
            new_percentage = new_percentage + average_incline
            i = i + 1
            graph:add_value(new_percentage, 2, false)

            if new_percentage > 0 then
                time_in_seconds = time_in_seconds + step_size_in_seconds
            end
        end

        -- In case the new_percentage is still not 0 we interpolate the time_in_seconds until it reaches 0
        if new_percentage > 0 then
            local diff = percentage - new_percentage
            local todo = new_percentage

            -- What is the ration between diff and todo
            local ratio = todo / diff
            time_in_seconds = ratio * time_in_seconds
        end

        return i18n.translate("Time until battery runs out: %s" , datetime.numberInSecToHMS(time_in_seconds))
    end

    local tooltip = ""

    awful.tooltip {
        objects = {graph},
        text = tooltip,
        mode = "inside",
        preferred_positions = {'bottom'},
        timer_function = function()
            return tooltip
        end
    }

    local function update(percentage)

        tooltip = draw_graph(percentage)

        -- Logic for the battery bar
        bar:set_value(percentage)

        local color = mat_colors.hue_green.hue_700
        local hint = ""

        -- Colorcode the battery percentage
        if percentage < 20 then
            color = mat_colors.red.hue_500
            if (not bIsCharging) then
                hint = i18n.translate("Battery is low, please charge it")
            end
        elseif percentage < 50 then
            color = mat_colors.amber.hue_500
        end

        bar:set_color(color)
        colors[1] = color

        textbox.text = tostring(math.floor(percentage)) .. '%'
        hintbox.text = hint
    end

    update(battery_initial_value)

    _card.update_body(wibox.widget {
        layout = wibox.layout.fixed.vertical,
        graph
    })

    signals.connect_battery(update)

    local rotated_battery = wibox.container.rotate(bar, "east")

    return wibox.container.place(wibox.widget{
        layout = wibox.layout.fixed.vertical,
        wibox.widget {
            rotated_battery,
            wibox.container.place(wibox.widget{
                textbox,
                hintbox,
                layout = wibox.layout.fixed.vertical
            }),
            layout  = wibox.layout.stack
        },
        spacing = dpi(10),
        _card
    })
end

return {
    icon = base_path .. 'logo.png',
    name = "Battery Graph",
    -- the settings menu expects a wibox
    widget = create()
  }