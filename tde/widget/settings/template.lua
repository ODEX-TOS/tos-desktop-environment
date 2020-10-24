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

  local title = wibox.widget.textbox("About")
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
        valign = "center",
        halign = "center",
        wibox.widget.textbox("test")
      }
    }
  }

  return view
end
