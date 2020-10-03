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
-- Provides:
-- evil::weather
--      temperature (integer)
--      description (string)
--      icon_code (string)

local awful = require("awful")
local gears = require("gears")
local config = require("config")
local theme = require("theme.icons.dark-light")

local PATH_TO_ICONS = "/etc/xdg/awesome/widget/weather/icons/"

-- Configuration
local units = "metric" -- weather_units  metric(°C)/imperial(°F)

-- Don't update too often, because your requests might get blocked for 24 hours
local update_interval = config.weather_poll

-- Check units
if units == "metric" then
    weather_temperature_symbol = "°C"
elseif units == "imperial" then
    weather_temperature_symbol = "°F"
end

--  Weather script using your API KEY
local weather_details_script = "/bin/bash /etc/xdg/awesome/weather.sh"

-- Sometimes it's too slow for internet to connect so the weather widget
-- will not update until the next 20mins so this is helpful to update it
-- 20seconds after logging in.
gears.timer {
    timeout = 20,
    autostart = true,
    single_shot = true,
    callback = function()
        awful.spawn.easy_async_with_shell(
            weather_details_script,
            function(stdout)
                local icon_code = string.sub(stdout, 1, 3) or "..."
                local weather_details = string.sub(stdout, 5)
                weather_details = string.gsub(weather_details, "^%s*(.-)%s*$", "%1")
                -- Replace "-0" with "0" degrees
                weather_details = string.gsub(weather_details, "%-0", "0")
                -- Capitalize first letter of the description
                weather_details = weather_details:sub(1, 1):upper() .. weather_details:sub(2)
                local description = weather_details:match("(.*)@@")
                local temperature = weather_details:match("@@(.*)")
                if icon_code == "..." then
                    awesome.emit_signal("widget::weather", "Maybe it's 10000", "No internet connection...", "")
                else
                    awesome.emit_signal("widget::weather", temperature, description, icon_code)
                end
            end
        )
    end
}

-- Update widget every 1200 seconds/20mins
awful.widget.watch(
    weather_details_script,
    update_interval,
    function(widget, stdout)
        local icon_code = string.sub(stdout, 1, 3)
        local weather_details = string.sub(stdout, 5)
        weather_details = string.gsub(weather_details, "^%s*(.-)%s*$", "%1")
        -- Replace "-0" with "0" degrees
        weather_details = string.gsub(weather_details, "%-0", "0")
        -- Capitalize first letter of the description
        weather_details = weather_details:sub(1, 1):upper() .. weather_details:sub(2)
        local description = weather_details:match("(.*)@@")
        local temperature = weather_details:match("@@(.*)")
        if icon_code == "..." then
            awesome.emit_signal("widget::weather", "Maybe it's 10000", "No internet connection...", "")
        else
            awesome.emit_signal("widget::weather", temperature, description, icon_code)
        end
        collectgarbage("collect")
    end
)

awesome.connect_signal(
    "widget::weather",
    function(temperature, description, icon_code)
        local widgetIconName

        print("Current weather temperature: " .. temperature)
        print("Current weather description: " .. description)

        -- Set icon and color depending on icon_code
        if string.find(icon_code, "11") then
            -- icon = sun_icon
            -- color = beautiful.xcolor3
            widgetIconName = "sun_icon"
        elseif string.find(icon_code, "22") then
            -- icon = moon_icon
            -- color = beautiful.xcolor4
            widgetIconName = "moon_icon"
        elseif string.find(icon_code, "33") then
            -- icon = dcloud_icon
            -- color = beautiful.xcolor3
            widgetIconName = "dcloud_icon"
        elseif string.find(icon_code, "44") then
            -- icon = ncloud_icon
            -- color = beautiful.xcolor6
            widgetIconName = "ncloud_icon"
        elseif string.find(icon_code, "55") or string.find(icon_code, "04") then
            -- icon = cloud_icon
            -- color = beautiful.xcolor1
            widgetIconName = "cloud_icon"
        elseif string.find(icon_code, "66") or string.find(icon_code, "10") then
            -- icon = rain_icon
            -- color = beautiful.xcolor4
            widgetIconName = "rain_icon"
        elseif string.find(icon_code, "77") then
            -- icon = storm_icon
            -- color = beautiful.xcolor1
            widgetIconName = "storm_icon"
        elseif string.find(icon_code, "88") then
            -- icon = snow_icon
            -- color = beautiful.xcolor6
            widgetIconName = "snow_icon"
        elseif string.find(icon_code, "99") or string.find(icon_code, "40") then
            -- icon = mist_icon
            -- color = beautiful.xcolor5
            widgetIconName = "mist_icon"
        else
            -- icon = whatever_icon
            -- color = beautiful.xcolor2
            widgetIconName = "whatever_icon"
        end

        -- Update data. Global variables stored in widget.weather.init
        _G.weather_icon_widget.icon:set_image(theme(PATH_TO_ICONS .. widgetIconName .. ".svg"))
        _G.weather_description.text = description
        _G.weather_temperature.text = temperature
    end
)
