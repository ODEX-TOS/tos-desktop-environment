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
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local beautiful = require("beautiful")

local clickable_container = require("widget.material.clickable-container")

local PATH_TO_ICONS = "/etc/xdg/awesome/widget/social-media/icons/"
local theme = require("theme.icons.dark-light")

-- Generate widget with background
local genWidget = function(widgets)
  return wibox.widget {
    {
      widgets,
      bg = beautiful.bg_modal,
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 12)
      end,
      widget = wibox.container.background
    },
    margins = dpi(10),
    widget = wibox.container.margin
  }
end

social_header =
  wibox.widget {
  text = "Social Media",
  font = "SFNS Display Regular 14",
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox
}

local reddit_widget =
  wibox.widget {
  {
    id = "icon",
    image = theme(PATH_TO_ICONS .. "reddit" .. ".svg"),
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local reddit_button = clickable_container(wibox.container.margin(reddit_widget, dpi(7), dpi(7), dpi(7), dpi(7)))
reddit_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn.easy_async_with_shell(
          "xdg-open https://reddit.com",
          function(stderr)
          end,
          1
        )
      end
    )
  )
)

local facebook_widget =
  wibox.widget {
  {
    id = "icon",
    image = theme(PATH_TO_ICONS .. "facebook" .. ".svg"),
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local facebook_button = clickable_container(wibox.container.margin(facebook_widget, dpi(7), dpi(7), dpi(7), dpi(7)))
facebook_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn.easy_async_with_shell(
          "xdg-open https://facebook.com",
          function(stderr)
          end,
          1
        )
      end
    )
  )
)
local twitter_widget =
  wibox.widget {
  {
    id = "icon",
    image = theme(PATH_TO_ICONS .. "twitter" .. ".svg"),
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local twitter_button = clickable_container(wibox.container.margin(twitter_widget, dpi(7), dpi(7), dpi(7), dpi(7)))
twitter_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn.easy_async_with_shell(
          "xdg-open https://twitter.com",
          function(stderr)
          end,
          1
        )
      end
    )
  )
)
local instagram_widget =
  wibox.widget {
  {
    id = "icon",
    image = theme(PATH_TO_ICONS .. "instagram" .. ".svg"),
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local instagram_button = clickable_container(wibox.container.margin(instagram_widget, dpi(7), dpi(7), dpi(7), dpi(7)))
instagram_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn.easy_async_with_shell(
          "xdg-open https://instagram.com",
          function(stderr)
          end,
          1
        )
      end
    )
  )
)

local social_layout =
  wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  spacing = dpi(25),
  genWidget(facebook_button),
  genWidget(reddit_button),
  genWidget(twitter_button),
  genWidget(instagram_button)
}

local social =
  wibox.widget {
  expand = "none",
  layout = wibox.layout.fixed.vertical,
  {
    {
      wibox.container.margin(social_header, dpi(10), dpi(10), dpi(10), dpi(10)),
      bg = beautiful.bg_modal_title,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 6)
      end,
      widget = wibox.container.background
    },
    layout = wibox.layout.fixed.vertical
  },
  {
    {
      {
        expand = "none",
        layout = wibox.layout.align.horizontal,
        {
          layout = wibox.layout.fixed.horizontal,
          nil
        },
        social_layout,
        {
          layout = wibox.layout.fixed.horizontal,
          nil
        }
      },
      margins = dpi(5),
      widget = wibox.container.margin
    },
    forced_height = dpi(60),
    bg = beautiful.bg_modal,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 6)
    end,
    widget = wibox.container.background
  }
}

return social
