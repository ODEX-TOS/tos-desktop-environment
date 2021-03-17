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
-- This is an example of a little bit more complex widgets

local os = require("os")
local awful = require("awful")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")
local wibox = require("wibox")
local gears = require("gears")

-- general settings for how big the
local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(800)
local settings_nw = dpi(200)

local function create()
  local view = wibox.container.margin()
  view.left = m
  view.right = m

  local title = wibox.widget.textbox("Calendar")
  title.font = beautiful.title_font
  title.forced_height = settings_index + m + m

  local close = wibox.widget.imagebox(icons.close)
  close.forced_height = settings_index
  close:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        function()
          if root.elements.settings then
            root.elements.settings.close()
          end
        end
      )
    )
  )

  local cal_container = wibox.container.background()
  cal_container.bg = beautiful.bg_modal
  cal_container.shape = rounded()
  cal_container.forced_width = settings_width - settings_nw - (m * 2)
  cal_container.forced_height = settings_width - settings_nw - (m * 2)

  local styles = {
    focus = {
      bg_color = beautiful.primary.hue_500,
      shape = rounded()
    }
  }

  local function decorate_cell(widget, flag, _)
    local props = styles[flag] or {}
    local ret = widget
    if flag == "focus" then
      ret =
        wibox.container.margin(
        wibox.widget {
          {
            widget,
            widget = wibox.container.place
          },
          shape = props.shape,
          bg = props.bg_color,
          widget = wibox.container.background
        },
        dpi(10),
        dpi(10),
        dpi(10),
        dpi(10)
      )
    end
    return ret
  end

  cal_container:setup {
    layout = wibox.container.margin,
    left = m,
    right = 40,
    {
      date = os.date("*t"),
      font = beautiful.font,
      start_sunday = false,
      long_weekdays = false,
      widget = wibox.widget.calendar.month,
      fn_embed = decorate_cell
    }
  }

  view:setup {
    layout = wibox.container.background,
    {
      layout = wibox.layout.align.vertical,
      {
        layout = wibox.layout.align.horizontal,
        nil,
        wibox.container.margin(
          {
            layout = wibox.container.place,
            title
          },
          settings_index * 2
        ),
        close
      },
      {
        layout = wibox.container.place,
        valign = "top",
        halign = "center",
        cal_container
      }
    }
  }

  return view
end

return {
  icon = icons.warning,
  name = "hello-world",
  -- the settings menu expects a wibox
  wibox = create()
}
