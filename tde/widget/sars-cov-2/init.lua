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
local dpi = require("beautiful").xresources.apply_dpi
local theme = require("theme.icons.dark-light")
local common = require("lib-tde.function.common")
local split = common.split
local card = require("lib-widget.card")

local PATH_TO_ICONS = "/etc/xdg/tde/widget/sars-cov-2/icons/"

local covid_card = card("Covid-19 cases in your country")

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

local country = ""

awful.spawn.easy_async("curl -s 'https://network.odex.be/country'", function (_stdout)
  if _stdout ~= nil then
    country = common.trim(_stdout)
    local cmd = [[bash -c "curl -s 'https://corona-stats.online/]] .. country .. [[?minimal=true' | sed -r 's/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g'"]]
    print(cmd)
    watch(
      cmd,
      3600,
      function(_, stdout)
        local array = split(split(stdout, "\n")[2], "%s*")
        local infected = i18n.translate("Infected: ") .. (array[4] or i18n.translate("unknown"))
        local death = i18n.translate("Deaths: ") .. (array[7] or i18n.translate("unknown"))
        covid_deceases.text = infected
        covid_deaths.text = death
      end
    )
  end
end)

watch(
  [[curl -s https://network.odex.be/country_name]],
  3600,
  function(_, stdout)
    covid_card.update_title(i18n.translate("Covid-19 cases in ") .. stdout)
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

local body =
  wibox.widget {
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
    widget = wibox.container.margin
  }
}

covid_card.update_body(body)

return covid_card
