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
local dpi = require("beautiful").xresources.apply_dpi

local card = require("lib-widget.card")

local theme = require("theme.icons.dark-light")

local PATH_TO_ICONS = "/etc/xdg/tde/widget/weather/icons/"

-- Weather Updater
require("widget.weather.weather-update")

local weather_icon_widget =
  wibox.widget {
  {
    id = "icon",
    image = theme(PATH_TO_ICONS .. "whatever_icon" .. ".svg"),
    resize = true,
    forced_height = dpi(45),
    forced_width = dpi(45),
    widget = wibox.widget.imagebox
  },
  layout = wibox.layout.fixed.horizontal
}

_G.weather_icon_widget = weather_icon_widget

local weather_card = card({title="Weather & Temperature"})

local weather_description =
  wibox.widget {
  text = i18n.translate("No internet connection..."),
  font = "SFNS Display Regular 16",
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

_G.weather_description = weather_description

local weather_temperature =
  wibox.widget {
  text = i18n.translate("Try again later."),
  font = "SFNS Display Regular 12",
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

_G.weather_temperature = weather_temperature

local body =
  wibox.widget {
  expand = "none",
  layout = wibox.layout.fixed.horizontal,
  {
    wibox.widget {
      weather_icon_widget,
      margins = dpi(4),
      widget = wibox.container.margin
    },
    margins = dpi(5),
    widget = wibox.container.margin
  },
  {
    {
      layout = wibox.layout.fixed.vertical,
      weather_description,
      weather_temperature
    },
    margins = dpi(4),
    widget = wibox.container.margin
  }
}

weather_card.update_body(body)

return weather_card
