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
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local theme = require("theme.icons.dark-light")
local split = require("lib-tde.function.common").split

local beautiful = require("beautiful")

local PATH_TO_ICONS = "/etc/xdg/tde/widget/sars-cov-2/icons/"

local covid_header =
  wibox.widget {
  text = i18n.translate("Covid-19 cases in your country"),
  font = "SFNS Display Regular 14",
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox
}

local covid_deceases =
  wibox.widget {
  text = i18n.translate("No internet connection..."),
  font = "SFNS Display Regular 16",
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

local covid_deaths =
  wibox.widget {
  text = i18n.translate("Can't retreive deaths."),
  font = "SFNS Display Regular 12",
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox
}

watch(
  [[bash -c "curl -s https://corona-stats.online/$(curl https://ipapi.co/country/)?minimal=true | sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g'"]],
  3600,
  function(_, stdout)
    local array = split(split(stdout, "\n")[2], "%s*")
    local infected = i18n.translate("Infected: ") .. (array[4] or i18n.translate("unknown"))
    local death = i18n.translate("Deaths: ") .. (array[7] or i18n.translate("unknown"))
    covid_deceases.text = infected
    covid_deaths.text = death
  end
)

watch(
  [[curl -s https://ipapi.co/country_name]],
  3600,
  function(_, stdout)
    covid_header.text = i18n.translate("Covid-19 cases in ") .. stdout
  end
)

local covid_icon_widget =
  wibox.widget {
  {
    id = "icon",
    image = theme(PATH_TO_ICONS .. "corona" .. ".svg"),
    resize = true,
    forced_height = dpi(45),
    forced_width = dpi(45),
    widget = wibox.widget.imagebox
  },
  layout = wibox.layout.fixed.horizontal
}

local weather_report =
  wibox.widget {
  --expand = "none",
  layout = wibox.layout.fixed.vertical,
  bg = beautiful.bg_modal,
  wibox.widget {
    wibox.container.margin(covid_header, dpi(5), dpi(5), dpi(3), dpi(3)),
    bg = beautiful.bg_modal_title,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 6)
    end,
    widget = wibox.container.background
  },
  {
    {
      expand = "none",
      layout = wibox.layout.fixed.horizontal,
      {
        wibox.widget {
          covid_icon_widget,
          margins = dpi(4),
          widget = wibox.container.margin
        },
        margins = dpi(5),
        widget = wibox.container.margin
      },
      {
        {
          layout = wibox.layout.fixed.vertical,
          covid_deceases,
          covid_deaths
        },
        margins = dpi(4),
        bg = beautiful.bg_modal,
        widget = wibox.container.margin
      }
    },
    bg = beautiful.bg_modal,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 6)
    end,
    widget = wibox.container.background
  }
}

return weather_report
