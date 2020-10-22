local os = require("os")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local rounded = require("lib-tde.widget.rounded")
local dpi = beautiful.xresources.apply_dpi
local icons = require("theme.icons")

local m = dpi(10)
local settings_index = dpi(40)
local settings_width = dpi(1100)
local settings_nw = dpi(260)

return function()
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

  local function decorate_cell(widget, flag, date)
    local props = styles[flag] or {}
    ret = widget
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
        {
          layout = wibox.container.place,
          title
        },
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
