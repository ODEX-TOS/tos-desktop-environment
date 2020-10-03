
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')


-- a simple calendar

local cal = wibox.widget {
    date         = os.date('*t'),
    font         = "Iosevka Custom 11",
    spacing      = 10,
    week_numbers = false,
    start_sunday = false,
    widget       = wibox.widget.calendar.month
}

-- generate a text widget that acts like the header
header = wibox.widget {
    text   = "Calendar",
    font   = 'SFNS Display Regular 14',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- seperate the header and calendar
local separator = wibox.widget {
    orientation = 'horizontal',
    forced_height = 1,
    span_ratio = 1.0,
    opacity = 0.90,
    color = beautiful.bg_modal,
    widget = wibox.widget.separator
  }

-- the entire widget that will be included 
return wibox.widget {
    expand = 'none',
    layout = wibox.layout.fixed.vertical,
    {
      -- this section colors the header bar in a different color that the body of the widget
      -- it also gives the header rounded corners
      wibox.widget {
        wibox.container.margin(header, dpi(10), dpi(10), dpi(10), dpi(10)),
        bg = beautiful.bg_modal_title,
        shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, false, false, 6) end,
        widget = wibox.container.background,
      },
      layout = wibox.layout.fixed.vertical,
    },
    -- Body of the widget (calendar)
    {
      cal,
      bg = beautiful.bg_modal,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 6) end,
      widget = wibox.container.background
    },
  }